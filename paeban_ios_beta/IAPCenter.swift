//
//  IAPCenter.swift
//  paeban_ios_beta
//
//  Created by elijah on 2017/9/27.
//  Copyright © 2017年 尚義 高. All rights reserved.
//

import Foundation
import StoreKit

enum transaction_resule{
    case seccess
    case fail
}

protocol IAPCenterDelegate {
    func product_info_return(product_list:Array<SKProduct>?)
    func transaction_verifying(transaction_id:String?)
    func transaction_exchanging(transaction_id:String?)
    func transaction_complete(result:transaction_resule, transaction_id:String?)
    func internet_error()
    func verify_fail(verify_fail_list:Array<String>)
}

public class IAPCenter:NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver, webSocketActiveCenterDelegate{
    var delegate:IAPCenterDelegate?
    var product_id_list:Array<String> = []

    // MARK: setting
    let IAP_URL_PATH = "iap/"
    enum HTTP_REQUEST_MODE:String{
        case get_product_id_list = "get_product_id_list"
        case send_transaction = "send_transaction"
    }
    enum HTTP_SEND_DIC_KEY:String {
        case transaction_list = "transaction_list"
    }
    enum HTTP_RESPONSE_DIC_KEY:String {
        case product_id_list = "product_id_list"
    }
    
    // MARK: system
    override init() {
        super.init()
        basic_setup()
        wsActive.web_socket_reconnected_delegate_list.append(self)
    }
    func basic_setup(){
        // 加入監聽交易列隊
        SKPaymentQueue.default().add(self)
        get_product_id_list { (product_id_list:Array<String>?) in
            if product_id_list != nil{
                self.product_id_list = product_id_list!
            }
        }
    }
    
    // MARK: operate func
    func get_product_info(){
        if product_id_list.isEmpty{
            self.get_product_id_list(after: { (return_list:Array<String>?) in
                if return_list != nil{
                    self.product_id_list = return_list!
                    self.requestProductInfo(product_id_list: return_list!)
                }
                else{
                    self.delegate?.product_info_return(product_list: nil)
                }
            })
        }
        else{
            self.requestProductInfo(product_id_list: product_id_list)
        }
    }
    func buy_product(product:SKProduct){
        let payment = SKMutablePayment(product: product)
        payment.applicationUsername = userData.id!
        SKPaymentQueue.default().add(payment)
    }
    func re_send_transaction(){
        guard send_verify_forbidden != true else{
            return
        }
        print_trans_id()
    }
    func send_transaction(){
        guard send_verify_forbidden != true else{
            return
        }
        let exchanged_yet_transaction_list = sql_database.get_exchanged_yet_transaction_list()
        // transaction_list 的內容物格式
        // ["transaction_id":transaction_id,"transaction_token":transaction_token,"application_username",application_username]
        if !exchanged_yet_transaction_list.isEmpty{
            let _temp_dic = [HTTP_SEND_DIC_KEY.transaction_list.rawValue: exchanged_yet_transaction_list]
            HttpRequestCenter().http_request(url: IAP_URL_PATH, data_mode: HTTP_REQUEST_MODE.send_transaction.rawValue, form_data_dic: _temp_dic as Dictionary<String, AnyObject>) { (result_dic) in
                guard self.receiver_verify_forbidden != true else{
                    self.explanation_result(result: nil)
                    return
                }
                self.explanation_result(result: result_dic)
                self.retry_after_10sec()
            }
        }
    }
    func recive_iap_websocket(msg:Dictionary<String,AnyObject>){
        // fly remove print(msg)
        print(msg)
        explanation_result(result: ["result_list":[msg] as AnyObject])
    }
    func get_coin_from_server(){
        HttpRequestCenter().request_user_data_v2("get_coin", send_dic: [:]){(return_dic:Dictionary<String, AnyObject>?) in
            if return_dic != nil{
                sql_database.update_coin(input_dic: return_dic!)
            }
        }
    }
    func get_coin_from_local() -> Int?{
        return sql_database.get_coin()
    }
    
    // MARK: internal func
    private func get_product_id_list(after:@escaping (_ product_id_list:Array<String>?)->Void){
        HttpRequestCenter().http_request(url: IAP_URL_PATH, data_mode: HTTP_REQUEST_MODE.get_product_id_list.rawValue, form_data_dic: [:]) { (result_dic:Dictionary<String, AnyObject>?) in
            if result_dic != nil{
                let product_id_list = result_dic![HTTP_RESPONSE_DIC_KEY.product_id_list.rawValue]! as! Array<String>
                after(product_id_list)
            }
            else{
                after(nil)
                print("get_product_id_list http_error!!!")
            }
        }
    }
    private func requestProductInfo(product_id_list:Array<String>){
        if SKPaymentQueue.canMakePayments() {
            let productIdentifiers = NSSet(array: product_id_list)
            let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
            productRequest.delegate = self
            productRequest.start()
        }
        else {
            delegate?.product_info_return(product_list: nil)
        }
    }
    
    private func print_trans_id(){
        print("-----print_trans_id-----")
        let ttt = SKPaymentQueue.default().transactions
        for c in ttt{
            print(c.transactionIdentifier ?? "transactionIdentifier nil")
        }
    }
    private func explanation_result(result:Dictionary<String,AnyObject>?){
        // fly remove print
        print(result)
        // dic keys
        let RESULT_LIST = "result_list"
        let RESULT = "result"
        let TRANSACTION_ID = "transaction_id"
        let FAIL_VERIFY_TRANSACTION_LIST = "fail_verify_transaction_list"
        enum result_type:String{
            case verifying = "verifying"
            case exchanging = "exchanging"
            case success = "success"
            case verify_fail = "verify_fail"
            case iap_exchange_fail = "iap_exchange_fail"
        }
        // vars
        var need_alert_varify_fail = false
        // main function
        guard result != nil else {
            delegate?.internet_error()
            return
        }
        let result_list = result![RESULT_LIST] as! Array<Dictionary<String,AnyObject>>
        for c in result_list{
            if c[RESULT]! as! String == result_type.verifying.rawValue{
                delegate?.transaction_verifying(transaction_id: c[TRANSACTION_ID] as? String)
            }
            else if c[RESULT]! as! String == result_type.exchanging.rawValue{
                delegate?.transaction_exchanging(transaction_id: c[TRANSACTION_ID] as? String)
            }
            else if c[RESULT]! as! String == result_type.verify_fail.rawValue{
                delegate?.transaction_complete(result: .fail, transaction_id: c[TRANSACTION_ID] as? String)
            }
            else if c[RESULT]! as! String == result_type.iap_exchange_fail.rawValue{
                delegate?.transaction_complete(result: .fail, transaction_id: c[TRANSACTION_ID] as? String)
            }
            else{
                //fail
                if c[RESULT]! as! String == result_type.verify_fail.rawValue{
                    delegate?.transaction_complete(result: .fail, transaction_id: c[TRANSACTION_ID] as? String)
                }
                //success
                else{
                    self.finish_transaction_by_id(transaction_id: c[TRANSACTION_ID] as! String)
                    let result = sql_database.update_transaction_complete(transaction_id:c[TRANSACTION_ID] as! String)
                    if result == true{
                        delegate?.transaction_complete(result: .seccess, transaction_id: c[TRANSACTION_ID] as? String)
                    }
                    // fly 或許再多一個點數變動確認的函數
                }
                if let fail_verify_transaction_list_anyobj = c[FAIL_VERIFY_TRANSACTION_LIST]{
                    let fail_verify_transaction_list = fail_verify_transaction_list_anyobj as! Array<String>
                    for c in fail_verify_transaction_list{
                        sql_database.write_verify_fail_transaction(transaction_id: c)
                    }
                    if !fail_verify_transaction_list.isEmpty{need_alert_varify_fail = true}
                }
            }
        }
        if need_alert_varify_fail{
            let fail_list = sql_database.get_verify_fail_transaction_list()
            delegate?.verify_fail(verify_fail_list: fail_list)
        }
    }
    private func retry_after_10sec(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            let transaction_line = SKPaymentQueue.default().transactions
            if !transaction_line.isEmpty{
                self.re_send_transaction()
            }
        }
    }
    
    // MARK: tools
    private func save_transaction_token(transaction_id:String, application_username:String?){
        let receipt_url = Bundle.main.appStoreReceiptURL
        do{
            let receipt_data = try Data(contentsOf: receipt_url!, options: Data.ReadingOptions.alwaysMapped)
            let receipt_string = receipt_data.base64EncodedString(options: [])
            sql_database.write_transaction(transaction_id: transaction_id, token: receipt_string, application_username: (application_username == nil ? "":userData.id!))
            
        }
        catch{
            print("save_transaction_token ERROR")
            // a110482
            // restore trans
        }
    }
    private func finish_transaction_by_id(transaction_id:String){
        let transaction_line = SKPaymentQueue.default().transactions
        for c in transaction_line{
            if c.transactionIdentifier == transaction_id{
                SKPaymentQueue.default().finishTransaction(c)
                break
            }
        }
    }
    
    
    
    
    // MARK: delegate
    ///
    ///
    /// - Parameters:
    ///   - request:
    ///   - response:
    public func wsReconnected() {
        send_transaction()
        print("IAP wsReconnected")
    }
    public func wsOnMsg(_ msg: Dictionary<String, AnyObject>) {
        //pass
    }
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse){
        print(response)
        if response.products.count != 0 {
            var return_list:Array<SKProduct> = []
            for product in response.products {
                print(product.productIdentifier)
                return_list.append(product)
            }
            delegate?.product_info_return(product_list: return_list)
        }
        else {
            delegate?.product_info_return(product_list: nil)
        }
    }
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]){
        for transaction in transactions{
            switch transaction.transactionState {
            case SKPaymentTransactionState.purchased:
                print("---------seccess")
                save_transaction_token(transaction_id: transaction.transactionIdentifier!, application_username: transaction.payment.applicationUsername)
                send_transaction()
                //fly remove finishTransction
                SKPaymentQueue.default().finishTransaction(transaction)
            case SKPaymentTransactionState.failed:
                print("----------fail")
                SKPaymentQueue.default().finishTransaction(transaction)
                delegate?.transaction_complete(result: .fail, transaction_id: nil)
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("------------")
    }
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("交易錯誤!!!")
        print(error)
    }
    // MARK:debug_tool
        // 查看交易列隊數量
    func show_transaction_line(){
        print("準備列印交易序列")
        var result_str = ""
        let trans_line = SKPaymentQueue.default().transactions
        for c in trans_line{
            result_str = "\(result_str)\(c.transactionIdentifier!)\n"
        }
        if result_str == ""{
            print("交易序列空白")
        }
        print("==開始列印交易序列==")
        print(result_str)
    }
        // 查看交易資料庫狀態
    func show_transaction_database(){
        sql_database.show_transaction_database()
    }
        // 禁止發送驗證到server
    var send_verify_forbidden = false
    func switch_send_verify_forbidden(){
        switch send_verify_forbidden{
        case true:
            send_verify_forbidden = false
        default:
            send_verify_forbidden = true
        }
        print("send_verify_forbidden:\(send_verify_forbidden)")
    }
        // 禁止接收驗證訊號
    var receiver_verify_forbidden = false
    func switch_receiver_verify_forbidden(){
        switch receiver_verify_forbidden{
        case true:
            receiver_verify_forbidden = false
        default:
            receiver_verify_forbidden = true
        }
        print("receiver_verify_forbidden:\(receiver_verify_forbidden)")
    }
        // 列印當前禁止項目設定值
    func show_forbidden_setting(){
        print("預設值是兩者皆為false時全功能正常運作")
        print("send_verify_forbidden:\(send_verify_forbidden)")
        print("receiver_verify_forbidden:\(receiver_verify_forbidden)")
    }
}

class PaidService{
    // dic keys
    let RESULT = "result"
    //let MSG_TYPE = "msg_type"
    let IMG = "img"
    let CLIENT_ID = "client_id"
    // result_type
    //let IAP_VERIFY = "iap_verify"
    let HAVE_BEEN_UNLOCKED = "have_been_unlocked"
    let INSUFFICIENT_COIN = "insufficient_coin"
    let UN_KNOW_ERROR_20001 = "un_know_error_20001"
    let SUCCESS = "success"
    let HTTP_ERROR = "http_error"
    let FREE_EXTRA_TOPIC_WILL_OUT = "free_extra_topic_will_out"
    
    var client_id:String?
    var after:((_ result:String)->Void)?
    
    // MARK:解鎖照片
    func unlock_img_process(client_id:String, after:@escaping (_ result:String)->Void){
        let send_dic = ["client_id": client_id]
        let IAP_URL_PATH = "iap/"
        self.client_id = client_id
        self.after = after
        HttpRequestCenter().http_request(url: IAP_URL_PATH, data_mode: "unlock_img", form_data_dic: send_dic as Dictionary<String,AnyObject>, InViewAct: {(result_dic:Dictionary<String,AnyObject>?) -> Void in
            DispatchQueue.main.async {
                guard result_dic != nil else{
                    after(self.HTTP_ERROR)
                    return
                }
                if result_dic![self.RESULT] as! String == self.SUCCESS{
                    let img = result_dic![self.IMG] as! String
                    let client_id = result_dic![self.CLIENT_ID] as! String
                    sql_database.update_unlock_img(client_id:client_id, img_str:img)
                    after(self.SUCCESS)
                }
                else if result_dic![self.RESULT] as! String == self.HAVE_BEEN_UNLOCKED{
                    let img = result_dic![self.IMG] as! String
                    let client_id = result_dic![self.CLIENT_ID] as! String
                    sql_database.update_unlock_img(client_id:client_id, img_str:img)
                    after(self.HAVE_BEEN_UNLOCKED)
                }
                else if result_dic![self.RESULT] as! String == self.INSUFFICIENT_COIN{
                    after(self.INSUFFICIENT_COIN)
                }
                else{
                    after(self.UN_KNOW_ERROR_20001)
                }
            }
        })
    }
    func unlock_img_result_explanation(result:String, view_controller:UIViewController, completion:(()->Void)?){
        // 要求view controller 是為了跳alert
        if result == self.HTTP_ERROR{
            let alert = UIAlertController(title: alert_string().error, message: alert_string().internet_error_do_you_want_retry, preferredStyle: .alert)
            let confirm_btn = UIAlertAction(title: alert_string().confirm, style: .default, handler: { (act) in
                self.unlock_img_process(client_id:self.client_id!, after: self.after!)
            })
            let cancel_btn = UIAlertAction(title: alert_string().cancel, style: .default, handler: nil)
            alert.addAction(confirm_btn)
            alert.addAction(cancel_btn)
            view_controller.present(alert, animated: true, completion: completion)
        }
        else if result == self.SUCCESS{
            let alert = UIAlertController(title: alert_string().notice, message: alert_string().transaction_success, preferredStyle: .alert)
            let confirm_btn = UIAlertAction(title: alert_string().confirm, style: .default, handler: nil)
            alert.addAction(confirm_btn)
            view_controller.present(alert, animated: true, completion: completion)
        }
        else if result == self.FREE_EXTRA_TOPIC_WILL_OUT{
            let alert = UIAlertController(title: alert_string().notice, message: alert_string().free_extra_topic_will_out, preferredStyle: .alert)
            let confirm_btn = UIAlertAction(title: alert_string().confirm, style: .default, handler: nil)
            alert.addAction(confirm_btn)
            view_controller.present(alert, animated: true, completion: completion)
        }
        else if result == self.HAVE_BEEN_UNLOCKED{
            let alert = UIAlertController(title: alert_string().notice, message: alert_string().have_been_unlocked, preferredStyle: .alert)
            let confirm_btn = UIAlertAction(title: alert_string().confirm, style: .default, handler: nil)
            alert.addAction(confirm_btn)
            view_controller.present(alert, animated: true, completion: completion)
        }
        else if result == self.INSUFFICIENT_COIN{
            let alert = UIAlertController(title: alert_string().notice, message: alert_string().insufficient_coin, preferredStyle: .alert)
            let confirm_btn = UIAlertAction(title: alert_string().confirm, style: .default, handler: nil)
            alert.addAction(confirm_btn)
            view_controller.present(alert, animated: true, completion: completion)
        }
        else{
            let alert = UIAlertController(title: alert_string().error, message: alert_string().unknow_error_20001, preferredStyle: .alert)
            let confirm_btn = UIAlertAction(title: alert_string().confirm, style: .default, handler: nil)
            alert.addAction(confirm_btn)
            view_controller.present(alert, animated: true, completion: completion)
        }
    }
    
    func unlock_distance(complete:@escaping (_ result_dic:Dictionary<String,AnyObject>?)->Void){
        let IAP_URL_PATH = "iap/"
        HttpRequestCenter().http_request(url: IAP_URL_PATH, data_mode: "unlock_distance", form_data_dic:[:]) { (result_dic) in
            complete(result_dic)
        }
    }

}















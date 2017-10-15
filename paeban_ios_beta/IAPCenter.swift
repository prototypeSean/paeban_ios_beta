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
    func transaction_complete(result:transaction_resule, transaction_id:String?)
}

public class IAPCenter:NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver{
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
    }
    func basic_setup(){
        // 加入監聽交易列隊
        SKPaymentQueue.default().add(self)
        print("5555")
        print(SKPaymentQueue.default().transactions)
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
        // fly applicationUsername = userId
        payment.applicationUsername = "110482"
        SKPaymentQueue.default().add(SKPayment(product: product))
    }
    func re_exchang_point(){
        print_trans_id()
    }
    func send_transaction(){
        let exchanged_yet_transaction_list = sql_database.get_exchanged_yet_transaction_list()
//        ["transaction_id":transaction_id,
//         "transaction_token":transaction_token]
        let _temp_dic = [HTTP_SEND_DIC_KEY.transaction_list.rawValue: exchanged_yet_transaction_list]
        HttpRequestCenter().http_request(url: IAP_URL_PATH, data_mode: HTTP_REQUEST_MODE.send_transaction.rawValue, form_data_dic: _temp_dic as Dictionary<String, AnyObject>) { (result_dic) in
            //code
        }
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
    
    // MARK: delegate
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse){
        if response.products.count != 0 {
            var return_list:Array<SKProduct> = []
            for product in response.products {
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
                delegate?.transaction_complete(result: .seccess, transaction_id: transaction.transactionIdentifier)
            case SKPaymentTransactionState.failed:
                print("----------fail")
                delegate?.transaction_complete(result: .fail, transaction_id: transaction.transactionIdentifier)
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("------------")
    }
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("---------")
        print(error)
    }
}

















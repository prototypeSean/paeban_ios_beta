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
    override init() {
        super.init()
        basic_setup()
    }
    // system
    func basic_setup(){
        // 加入監聽交易列隊
        SKPaymentQueue.default().add(self)
        get_product_id_list { (product_id_list:Array<String>?) in
            if product_id_list != nil{
                self.product_id_list = product_id_list!
            }
        }
    }
    
    // MARK: oprate func
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
        SKPaymentQueue.default().add(SKPayment(product: product))
    }
    
    
    // MARK: internal func
    private func get_product_id_list(after:@escaping (_ product_id_list:Array<String>?)->Void){
        HttpRequestCenter().http_request(url: "iap/", data_mode: "get_product_id_list", form_data_dic: [:]) { (result_dic:Dictionary<String, AnyObject>?) in
            if result_dic != nil{
                let product_id_list = result_dic!["product_id_list"]! as! Array<String>
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
                delegate?.transaction_complete(result: .seccess, transaction_id: transaction.transactionIdentifier)
                SKPaymentQueue.default().finishTransaction(transaction)
            case SKPaymentTransactionState.failed:
                delegate?.transaction_complete(result: .fail, transaction_id: transaction.transactionIdentifier)
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }
}

















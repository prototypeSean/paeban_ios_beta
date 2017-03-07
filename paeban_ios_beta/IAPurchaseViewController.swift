//
//  IAPurchaseViewController.swift
//  paeban_ios_beta
//
//  Created by elijah on 2017/3/2.
//  Copyright © 2017年 尚義 高. All rights reserved.
//

import UIKit
import StoreKit

class IAPurchaseViewController: UIViewController ,SKProductsRequestDelegate, SKPaymentTransactionObserver{
    let VERIFY_RECEIPT_URL = "https://buy.itunes.apple.com/verifyReceipt"
    let ITMS_SANDBOX_VERIFY_RECEIPT_URL = "https://sandbox.itunes.apple.com/verifyReceipt"
    
    let product_ids = ["vip_1_month","vip_3_month"]
    var tableView = UITableView()
    let productIdentifiers = Set(["vip_1_month","vip_3_month"])

    var product: SKProduct?
    var productsArray = Array<SKProduct>()
    var productDict:NSMutableDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SKPaymentQueue.default().add(self)
    }
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.global(qos: .background).async {
            sleep(1)
            DispatchQueue.main.async {
                self.stt()
            }
        }
    }
    func onSelectRechargePackages(productId: String){
        //先判断是否支持内购
        if(SKPaymentQueue.canMakePayments()){
            buyProduct(product: productDict[productId] as! SKProduct)
        }
        else{
            print("============不支持内购功能")
        }
        
    }
    func buyProduct(product: SKProduct){
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    func stt(){
//        let productID:NSSet = NSSet(object: "vip_1_month")
//        let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
//        productsRequest.delegate = self
//        productsRequest.start()
        print(SKPaymentQueue.canMakePayments())
        let request = SKProductsRequest(productIdentifiers:
            self.productIdentifiers)
        request.delegate = self
        request.start()
        
    }
    func productsRequest (_ request: SKProductsRequest, didReceive response: SKProductsResponse){
        for c in response.products{
            print(c.productIdentifier)
        }
        if !response.invalidProductIdentifiers.isEmpty{
            print("fail")
            print(response.invalidProductIdentifiers)
        }
        print("===fin===")
        print(request.debugDescription)
        print(response.invalidProductIdentifiers)
    }
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!){
    
    }
    func verifyPruchase(){}
    func restorePurchase(){
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]){}
    
    
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]){}
    
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error){}
    
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue){}
    
    
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]){}
    
    
}














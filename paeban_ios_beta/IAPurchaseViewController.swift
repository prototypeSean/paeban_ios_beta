//
//  IAPurchaseViewController.swift
//  paeban_ios_beta
//
//  Created by elijah on 2017/3/2.
//  Copyright © 2017年 尚義 高. All rights reserved.
//

import UIKit
import StoreKit

class IAPurchaseViewController: UIViewController, UITableViewDataSource,UITableViewDelegate ,SKProductsRequestDelegate, SKPaymentTransactionObserver{
    let VERIFY_RECEIPT_URL = "https://buy.itunes.apple.com/verifyReceipt"
    let ITMS_SANDBOX_VERIFY_RECEIPT_URL = "https://sandbox.itunes.apple.com/verifyReceipt"
    
    let product_ids:Array<String> = ["vip_1_month","vip_3_month"]
    var tableView = UITableView()
    

    var product: SKProduct?
    var productsArray = Array<SKProduct>()
    var productDict:NSMutableDictionary!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.bounds = self.view.bounds
        tableView.center = self.view.center
        tableView.backgroundColor = UIColor.blue
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        SKPaymentQueue.default().add(self)
    }
    override func viewDidAppear(_ animated: Bool) {
        self.request_product_list()
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
    func request_product_list(){
        print(SKPaymentQueue.canMakePayments())
        let productIdentifiers = Set(product_ids)
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
        
    }
    func buyActions(selectedProduct:SKProduct) {
        
        let actionSheetController = UIAlertController(title: "確認購買".localized(withComment: "IAPurchaseViewController"), message: String(format: NSLocalizedString("購買%@ ?", comment: "IAPurchaseViewController"), selectedProduct.localizedTitle), preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let buyAction = UIAlertAction(title: "購買".localized(withComment: "IAPurchaseViewController"), style: UIAlertActionStyle.destructive) { (action) -> Void in
            let payment = SKPayment(product: selectedProduct)
            SKPaymentQueue.default().add(payment)
        }
        
        let cancelAction = UIAlertAction(title: "取消".localized(withComment: "IAPurchaseViewController"), style: UIAlertActionStyle.cancel) { (action) -> Void in
            
        }
        
        actionSheetController.addAction(buyAction)
        actionSheetController.addAction(cancelAction)
        
        present(actionSheetController, animated: true, completion: nil)
    }
    //delegate table view
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let product = productsArray[indexPath.row]
        cell.textLabel?.text = product.localizedTitle
        cell.detailTextLabel?.text = String(describing: product.price)
        cell.backgroundColor = UIColor.red
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        buyActions(selectedProduct: productsArray[indexPath.row])
    }
    
    //delegate in purchase
    func productsRequest (_ request: SKProductsRequest, didReceive response: SKProductsResponse){
        if !response.products.isEmpty{
            print("請求產品成功")
            for products_data in response.products{
                productsArray.append(products_data)
            }
        }
        
        if !response.invalidProductIdentifiers.isEmpty{
            print("無效產品序號")
            print(response.invalidProductIdentifiers)
        }
        self.tableView.reloadData()
    }
    
    func verifyPruchase(){}
    func restorePurchase(){
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]){
        for transaction in transactions {
            print("==========paymentQueue============")
            switch transaction.transactionState {
            case SKPaymentTransactionState.purchased:
                print("Transaction completed successfully.")
                SKPaymentQueue.default().finishTransaction(transaction)
                
                
            case SKPaymentTransactionState.failed:
                print("Transaction Failed");
                SKPaymentQueue.default().finishTransaction(transaction)
                
            default:
                print("==========paymentQueue============ffffff")
            }
            
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]){}
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error){
        print("=========================================2")
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue){
        print("=========================================3")
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]){
        print("=========================================4")
    }
    
    
}














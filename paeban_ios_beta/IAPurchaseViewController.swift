//
//  IAPurchaseViewController.swift
//  paeban_ios_beta
//
//  Created by elijah on 2017/3/2.
//  Copyright © 2017年 尚義 高. All rights reserved.
//

import UIKit
import StoreKit

class IAPurchaseViewController: UIViewController, SKProductsRequestDelegate {
    var productIDs: Array<String> = []
    var productsArray: Array<SKProduct> = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        productIDs.append("baeban_point_100")
        requestProductInfo()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsArray.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    
    
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count != 0 {
            for product in response.products {
                productsArray.append(product)
            }
            print(productsArray)
            //tblProducts.reloadData()
        }
        else {
            print("There are no products.")
        }
    }
    
    func requestProductInfo() {
        if SKPaymentQueue.canMakePayments() {
            let productIdentifiers = NSSet(array: productIDs)
            let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
            
            productRequest.delegate = self
            productRequest.start()
        }
        else {
            print("Cannot perform In App Purchases.")
        }
    }
    
    

}

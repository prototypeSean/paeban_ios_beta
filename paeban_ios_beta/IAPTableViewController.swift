//
//  IAPTableViewController.swift
//  paeban_ios_beta
//
//  Created by elijah on 2017/9/30.
//  Copyright © 2017年 尚義 高. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class IAPTableViewController:UITableViewController, IAPCenterDelegate{

    // MARK: vars
    var product_list:Array<SKProduct> = []
    var transition_ing = false
    
    // MARK: system
    override func viewDidLoad() {
        super.viewDidLoad()
        iap_center?.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        if product_list.isEmpty{
            iap_center?.get_product_info()
        }
        else{
            self.tableView.reloadData()
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return product_list.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = product_list[indexPath.row]
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor.gray
        cell.textLabel?.text = data.localizedTitle
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !transition_ing{
            iap_center?.buy_product(product: product_list[indexPath.row])
            transition_ing = true
        }
        else{
            let alert = UIAlertController(title: "警告", message: "尚有交易進行中，請稍後再試", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: tools
    private func save_transaction_token(transaction_id:String?){
        
    }
    
    // MARK: delegate
    func product_info_return(product_list: Array<SKProduct>?) {
        if product_list != nil{
            self.product_list = product_list!
            self.tableView.reloadData()
        }
        else{
            let alert = UIAlertController(title: "錯誤", message: "請求商品網路錯誤，是否重試", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "確定", style: .default, handler: { (act:UIAlertAction) in
                iap_center?.get_product_info()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func transaction_complete(result:transaction_resule, transaction_id:String?) {
        switch result {
        case .seccess:
            print("01")
        default:
            print("01")
        }
    }
}









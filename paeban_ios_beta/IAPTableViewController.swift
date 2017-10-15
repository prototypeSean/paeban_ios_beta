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

    
    
    // MARK: system
    var product_list:Array<SKProduct> = []
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
        add_load_view()
        if !transition_ing{
            iap_center?.buy_product(product: product_list[indexPath.row])
            set_loading_view_title(text: "正在啟動交易")
            transition_ing = true
        }
        else{
            let alert = UIAlertController(title: "警告", message: "尚有交易進行中，請稍後再試", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .default, handler: {(act) -> Void in
                iap_center?.re_exchanged_point()
                self.set_loading_view_title(text: "正在完成上一次交易")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: tools
    private func save_transaction_token(transaction_id:String){
        let receipt_url = Bundle.main.appStoreReceiptURL
        do{
            let receipt_data = try Data(contentsOf: receipt_url!, options: Data.ReadingOptions.alwaysMapped)
            let receipt_string = receipt_data.base64EncodedString(options: [])
            sql_database.write_transaction(transaction_id: transaction_id, token: receipt_string)
        }
        catch{
            print("save_transaction_token ERROR")
            // a110482
            // restore trans
        }
    }
    
    // MARK: transition delegate
    var transition_ing = false
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
            set_loading_view_title(text: "正在進行點數轉換")
            save_transaction_token(transaction_id: transaction_id!)
            // a110482
            // 取得並送給server驗證
        case .fail:
            remove_loading_view()
            let alert = UIAlertController(title: "交易失敗", message: "本次交易並未扣款", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        transition_ing = false
    }

    // MARK: loading view
    var loading_view = UIView()
    var loading_view_title = UILabel()
    func add_load_view(){
        loading_view.frame = CGRect(x: 0, y: 0, width: self.navigationController!.view.bounds.width,
                                     height: self.navigationController!.view.bounds.height)
        loading_view.backgroundColor = UIColor.gray
        loading_view.alpha = 0.7
        loading_view_title.center = loading_view.center
        loading_view_title.bounds = CGRect(x: 0, y: loading_view.bounds.midY, width: loading_view.bounds.width, height: 30)
        loading_view_title.textAlignment = .center
        loading_view.addSubview(loading_view_title)
        tabBar_pointer!.view.addSubview(loading_view)
    }
    func set_loading_view_title(text:String){
        loading_view_title.text = text
    }
    func remove_loading_view(){
        loading_view.removeFromSuperview()
    }
}









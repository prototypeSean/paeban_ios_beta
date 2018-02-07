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
            set_loading_view_title(text: alert_string().initiate_transaction)
            transition_ing = true
        }
        else{
            let alert = UIAlertController(title: alert_string().warning, message: alert_string().transactioning_please_try_later, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: alert_string().confirm, style: .default, handler: {(act) -> Void in
                // fly 可能可以直接用 send_transaction（）
                iap_center?.send_transaction()
                self.set_loading_view_title(text: alert_string().trying_to_complete_last_transaction)
            }))
            self.present(alert, animated: true, completion: nil)
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
            let alert = UIAlertController(title: alert_string().error, message: alert_string().internet_error_do_you_want_retry, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: alert_string().cancel, style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: alert_string().confirm, style: .default, handler: { (act:UIAlertAction) in
                iap_center?.get_product_info()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func transaction_verifying(transaction_id:String?){
        self.set_loading_view_title(text:alert_string().verifying)
    }
    func transaction_exchanging(transaction_id:String?){
        self.set_loading_view_title(text: alert_string().exchanging_point)
    }
    func transaction_complete(result:transaction_resule, transaction_id:String?) {
        switch result {
        case .seccess:
            let alert = UIAlertController(title: alert_string().notice, message: alert_string().transaction_success, preferredStyle: .alert)
            let confirm_btn = UIAlertAction(title: alert_string().confirm, style: .default, handler: nil)
            alert.addAction(confirm_btn)
            self.present(alert, animated: true, completion: nil)
        case .fail:
            let alert = UIAlertController(title: alert_string().warning, message: alert_string().transaction_fail, preferredStyle: .alert)
            let confirm_btn = UIAlertAction(title: alert_string().confirm, style: .default, handler: { (action) in
                iap_center?.send_transaction()
            })
            let cancel_btn = UIAlertAction(title: alert_string().cancel, style: .default, handler: nil)
            alert.addAction(confirm_btn)
            alert.addAction(cancel_btn)
            self.present(alert, animated: true, completion: nil)
        case .cancel: break
            //pass
        }
        remove_loading_view()
        transition_ing = false
    }
    func internet_error(){
        let alert = UIAlertController(title: alert_string().error, message: alert_string().internet_error_do_you_want_retry, preferredStyle: .alert)
        let confirm_btn = UIAlertAction(title: alert_string().confirm, style: .default) { (action) in
            iap_center?.send_transaction()
        }
        let cancel_btn = UIAlertAction(title: alert_string().cancel, style: .default, handler: nil)
        alert.addAction(confirm_btn)
        alert.addAction(cancel_btn)
        self.present(alert, animated: true, completion: nil)
    }
    func verify_fail(verify_fail_list:Array<String>){
        var fail_list_string = ""
        for c in verify_fail_list{
            fail_list_string = "\(fail_list_string)\n\(c)"
        }
        let alert = UIAlertController(title: alert_string().error, message: "\(alert_string().the_following_are_veriry_fail_list)\(fail_list_string)", preferredStyle: .alert)
        let confirm_btn = UIAlertAction(title: alert_string().confirm, style: .default, handler: nil)
        alert.addAction(confirm_btn)
        self.present(alert, animated: true, completion: nil)
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
        DispatchQueue.main.async {
            self.loading_view_title.text = text
        }
    }
    func remove_loading_view(){
        DispatchQueue.main.async {
            self.loading_view.removeFromSuperview()
        }
    }

}









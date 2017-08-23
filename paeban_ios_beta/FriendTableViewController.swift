//
//  FriendTableViewController.swift
//  paeban_ios_beta
//
//  Created by 工作用 on 2016/9/4.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit
class FriendTableViewController: UITableViewController,FriendInvitedCellTableViewCell_delegate {
    var model:FriendTableViewMedol?
    var segue_data_index:Int?
    var segue_data:Dictionary<String,AnyObject> = [:]
    @IBAction func ok_btn(_ sender: AnyObject) {
        let cell = sender.superview??.superview as! UITableViewCell
        let indexPath = self.tableView.indexPath(for: cell)
        ok_btn_click(click_row: indexPath!.row)
    }
    @IBAction func test_priv_msg(_ sender: Any) {
        let cmd_dic = ["msg_type":"cmd", "text":"test_priv_msg"]
        socket.write(data: json_dumps(cmd_dic as NSDictionary))
    }
    var delete_alot_switch = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model = FriendTableViewMedol(with: self)
        //wsActive.wasd_FriendTableViewMedol = model
        //self.tableView.gestureRecognizerShouldBegin(self.tableView.gestureRecognizers) = false
        // 讓整個VIEW往上縮起tabbar的高度
        //model?.synchronize_friend_table()
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, (self.tabBarController?.tabBar.frame)!.height, 0);
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !during_auto_leap{
            self.tableView.reloadData()
            model?.chat_view = nil
            model?.getFrientList()
            synchronize_friend_table {
                self.model?.getFrientList()
                self.model?.chat_view?.set_guest_img()
            }
            getInviteList()
            self.update_badges()
        }
    }
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return model!.friendsList.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.model?.friendsList[indexPath.row].cell_type == "friend"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendTableViewCell", for: indexPath)
            let cell2 = model!.getCell((indexPath as NSIndexPath).row, cell:cell)
            return cell2
        }
        else if self.model?.friendsList[indexPath.row].cell_type == "list"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendInvitedListTableViewCell", for: indexPath)
            let cell2 = model!.getCell((indexPath as NSIndexPath).row, cell:cell)
            return cell2
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendInvitedCellTableViewCell", for: indexPath)
            let cell2 = model!.getCell((indexPath as NSIndexPath).row, cell:cell)
            return cell2
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "friendConBox"{
            
            let topicViewCon = segue.destination as! FriendChatUpViewController
            var getSegueData:Dictionary<String, AnyObject>
            
            if let index = (self.tableView.indexPathForSelectedRow as NSIndexPath?)?.row{
                getSegueData = model!.getSegueData(index)
            }
            else{
                getSegueData = self.segue_data
            }
            topicViewCon.setID = userData.id
            topicViewCon.setName = userData.name
            topicViewCon.setImg = userData.img
            topicViewCon.clientId = getSegueData["clientId"] as? String
            topicViewCon.clientName = getSegueData["clientName"] as? String
            topicViewCon.clientImg = getSegueData["clientImg"] as? UIImage
            topicViewCon.title = "好友"
            model?.chat_view = topicViewCon
            topicViewCon.reset_during_auto_leap()
            getSegueData = [:]
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if model?.friendsList[indexPath.row].cell_type == "list"{
            if need_to_extend(index: indexPath.row){
                //伸
                let befort_collapse_int = model?.friendsList.count
                model?.add_invite_list_to_table()
                let after_collapse_int = model?.friendsList.count
                if after_collapse_int! > befort_collapse_int!{
                    
                    
                    var insert_index_list:Array<IndexPath> = []
                    for index_s in 0..<(model?.friendsList.count)!{
                        if model?.friendsList[index_s].cell_type == "invite"{
                            let index_path = IndexPath(row: index_s, section: 0)
                            insert_index_list.append(index_path)
                        }
                        
                    }
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: insert_index_list, with: UITableViewRowAnimation.automatic)
                    self.tableView.endUpdates()
                    //self.tableView.reloadData()
                }
                else{
                    self.tableView.reloadData()
                }
            }
            else{
                //收
                let befort_collapse_int = model?.friendsList.count
                model?.remove_invite_list_to_table()
                let after_collapse_int = model?.friendsList.count
                if befort_collapse_int! > after_collapse_int!{
                    
                    var insert_index_list:Array<IndexPath> = []
                    for index_s in 0..<(befort_collapse_int! - after_collapse_int!){
                        let index_path = IndexPath(row: index_s + 1, section: 0)
                        insert_index_list.append(index_path)
                    }
                    self.tableView.beginUpdates()
                    self.tableView.deleteRows(at: insert_index_list, with: UITableViewRowAnimation.automatic)
                    self.tableView.endUpdates()
                    
                    
                }
                else{
                    self.tableView.reloadData()
                }
            }
            //收
        }
        else if model?.friendsList[indexPath.row].cell_type == "friend"{
            model?.friendsList[indexPath.row].read_msg = true
            self.tableView.reloadData()
        }
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if model?.friendsList[indexPath.row].cell_type == "list"{
            return false
        }
        return true
    }
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if model?.friendsList[indexPath.row].cell_type == "invite"{
            let ok_btn = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "\u{2713}\n確認") { (UITableViewRowAction, IndexPath) in
                let target_obj = self.model?.friendsList[IndexPath.row]
                self.friend_confirm(answer: "yes", friend_id: (target_obj?.id)!)
                let temp_input_dic:Dictionary<String,AnyObject> = [
                    "client_id": target_obj?.id as AnyObject,
                    "client_name": target_obj?.name as AnyObject,
                    "img_name": target_obj?.photoHttpStr as AnyObject,
                    "is_real_pic": target_obj?.isRealPhoto as AnyObject,
                    "sex": target_obj?.sex as AnyObject
                ]
                sql_database.insert_friend(input_dic: temp_input_dic)
                self.model?.remove_cell_enforce(with: (self.model?.friendsList[IndexPath.row].id)!)
                self.model?.getFrientList()
            }
            //let img2 = UIImage(named: "check")
            ok_btn.backgroundColor = UIColor(red:0.00, green:0.67, blue:0.52, alpha:1.0)
            
            let del_btn = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "\u{2715}\n刪除") { (UITableViewRowAction, IndexPath) in
                self.friend_confirm(answer: "no", friend_id: (self.model?.friendsList[IndexPath.row].id)!)
                self.model?.remove_cell_enforce(with: (self.model?.friendsList[IndexPath.row].id)!)
            }
            
            return [del_btn, ok_btn]
        }
        else if model?.friendsList[indexPath.row].cell_type == "friend"{
            let delete_btn = UITableViewRowAction(style: .default, title: "刪除", handler: { (action, index_path) in
                let alert = UIAlertController(title: "警告", message: "是否要刪除該用戶", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "確定", style: .default, handler: { (act) in
                    let friend_id = self.model?.friendsList[indexPath.row].id
                    sql_database.remove_friend_process(username_in: friend_id!)
                    self.model?.remove_friend(id: friend_id!)
                    self.update_badges()
                }))
                self.present(alert, animated: true, completion: nil)
                
            })
            return [delete_btn]
        }
        else{
            return []
        }
    }
    
    
    
    // MARk: internal func
    func pop_to_root_view(){
        let parent = self.parent as! UINavigationController
        parent.popToRootViewController(animated: false)
    }
    func autoLeap(segeu_data:Dictionary<String,String>){
        // 飛行
        if !segeu_data.isEmpty && recive_apns_switch{
            if let segue_user_id = segeu_data["user_id"]{
                if let friend_name = sql_database.get_friend_name(friend_id:segue_user_id){
                    self.segue_data["clientId"] = segue_user_id as AnyObject
                    self.segue_data["clientName"] = friend_name as AnyObject
                    if let img = sql_database.get_friend_img(friend_id: segue_user_id){
                        self.segue_data["clientImg"] = img
                    }
                    self.performSegue(withIdentifier: "friendConBox", sender: nil)
                }
            }
            notificationSegueInf = [:]
            
            
//            var targetData_Dickey:Array<FriendStanderType>.Index?
//            var while_pertect = 5000
//            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
//                while targetData_Dickey == nil && while_pertect >= 0{
//                    var break_flag = false
//                    targetData_Dickey = self.model?.friendsList.index(where: { (FriendStanderType) -> Bool in
//                        if FriendStanderType.id == segue_user_id{
//                            return true
//                        }
//                        else{return false}
//                    })
//                    
//                    
//                    if targetData_Dickey != nil{
//                        DispatchQueue.main.async {
//                            
//                            notificationSegueInf = [:]
//                            self.segue_data_index = targetData_Dickey
//                            self.performSegue(withIdentifier: "friendConBox", sender: nil)
//                            break_flag = true
//                            recive_apns_switch = false
//                        }
//                    }
//                    if break_flag{
//                        break
//                    }
//                    usleep(100000)
//                        while_pertect -= 100
//                    }
//                }
        }
    }
    func getInviteList(){
        let send_dic:NSDictionary = [
            "none": "none"
        ]
        HttpRequestCenter().friend_function(msg_type: "get_invite_list", send_dic: send_dic) { (return_dic) in
            if !return_dic.isEmpty{
                DispatchQueue.main.async {
                    self.model?.addInviteList(input_dic: return_dic)
                    self.model?.updateModel()
                }
                
            }
        }
    }
    func update_badges(){
        let tab_bar = self.parent?.parent as! TabBarController
        DispatchQueue.main.async {
            tab_bar.update_badges()
        }
    }
    
    
    
    // MARK: event for cell button
    func ok_btn_click(click_row:Int){
        // fly “這是哪裡的按鈕？？？”
        print("click")
    }
    func friend_confirm(answer:String, friend_id:String){
        let send_dic:NSDictionary = [
            "msg_type":"friend_confirm",
            "friend_id":friend_id,
            "answer":answer
        ]
        socket.write(data: json_dumps(send_dic))
    }
    
    // MARK: delegate -> cell
    func slide_left(row_id: String) {
        model?.remove_cell(with: row_id)
    }
    func need_to_extend(index:Int) -> Bool{
        if (model?.friendsList.count)! > index + 1{
            if model?.friendsList[index + 1].cell_type == "friend"{
                return true
            }
            else{
                return false
            }
        }
        else{
            return true
        }
    }
    
}









//
//  FriendTableViewController.swift
//  paeban_ios_beta
//
//  Created by 工作用 on 2016/9/4.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

class FriendTableViewController: UITableViewController,webSocketActiveCenterDelegate {
    var model:FriendTableViewMedol?
    var segue_data_index:Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        model = FriendTableViewMedol(with: self)
        wsActive.wasd_ForFriendTableViewController = self
    }
    override func viewWillAppear(_ animated: Bool) {
        //autoLeap()
        self.tableView.reloadData()
        //getInvitwList()
    }
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return model!.getDataCount()
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
                getSegueData = model!.getSegueData(self.segue_data_index!)
            }
            topicViewCon.setID = userData.id
            topicViewCon.setName = userData.name
            topicViewCon.setImg = userData.img
            topicViewCon.clientId = getSegueData["clientId"] as? String
            topicViewCon.clientName = getSegueData["clientName"] as? String
            topicViewCon.clientImg = getSegueData["clientImg"] as? UIImage
            topicViewCon.title = "好友"
        }
    }
    
    // MARK:delegate -> websocket
    func wsOnMsg(_ msg:Dictionary<String,AnyObject>){
        let msgtype = msg["msg_type"] as! String
        if msgtype == "online"{
            self.tableView.reloadData()
        }
        else if msgtype == "off_line"{
            self.tableView.reloadData()
        }
        else if msgtype == "new_member"{
            self.tableView.reloadData()
        }
    }
    
    // MARk: internal func
    func autoLeap(){
        if notificationSegueInf != [:] && recive_apns_switch{
            let parent = self.parent as! UINavigationController
            parent.popToRootViewController(animated: false)
            let segue_user_id = notificationSegueInf["user_id"]
            var targetData_Dickey:Array<FriendStanderType>.Index?
            
            var while_pertect = 5000
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                while targetData_Dickey == nil && while_pertect >= 0{
                    var break_flag = false
                    targetData_Dickey = self.model?.friendsList.index(where: { (FriendStanderType) -> Bool in
                        if FriendStanderType.id == segue_user_id{
                            return true
                        }
                        else{return false}
                    })
                    
                    
                    if targetData_Dickey != nil{
                        DispatchQueue.main.async {
                            
                            notificationSegueInf = [:]
                            self.segue_data_index = targetData_Dickey
                            print("=========segue=======")
                            self.performSegue(withIdentifier: "friendConBox", sender: nil)
                            break_flag = true
                            recive_apns_switch = false
                        }
                    }
                    if break_flag{
                        break
                    }
                    usleep(100000)
                        while_pertect -= 100
                    }
                }
                print("end...")
                //self.segueData = nil
                notificationSegueInf = [:]
            
        }
    }
    func getFrientList(){
        let send_dic:NSDictionary = [
            "none": "none"
        ]
        HttpRequestCenter().friend_function(msg_type: "get_friend_list", send_dic: send_dic) { (return_dic) in
            //code
        }
    }
    func getInvitwList(){
        let send_dic:NSDictionary = [
            "none": "none"
        ]
        HttpRequestCenter().friend_function(msg_type: "get_invite_list", send_dic: send_dic) { (return_dic) in
            if !return_dic.isEmpty{
                DispatchQueue.main.async {
                    self.model?.addInviteList(input_dic: return_dic)
                }
                
            }
        }
    }
    
}









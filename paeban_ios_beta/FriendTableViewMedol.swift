//
//  FriendTableViewMedol.swift
//  paeban_ios_beta
//
//  Created by 工作用 on 2016/9/4.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import Foundation
import UIKit

class FriendTableViewMedol:webSocketActiveCenterDelegate{
    var friendsList:Array<FriendStanderType>{
        get{
            return myFriendsList
        }
        set{
            myFriendsList = newValue
        }
    }
    var chat_view:FriendChatUpViewController?
    var invite_list:Array<FriendStanderType> = []
    var friend_list_database:Array<FriendStanderType> = []
    
    func getDataCount() -> Int{
        return friendsList.count
    }
    var targetVC:FriendTableViewController
    
    init(with view_controller:FriendTableViewController) {
        self.targetVC = view_controller
        wsActive.wasd_FriendTableViewMedol = self
    }
    
    func getCell(_ index:Int,cell:UITableViewCell) -> UITableViewCell {
        let data = friendsList[index]
        if data.cell_type == "friend"{
            let cell2 = cell as! FriendTableViewCell
            if data.photo == nil{
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    if data.photoHttpStr != nil && data.photoHttpStr != ""{
                        let url = "https://www.paeban.com/media/\(data.photoHttpStr!)"
                        HttpRequestCenter().getHttpImg(url, getImg: { (get_img) in
                            if let user_index = self.friendsList.index(where: { (target) -> Bool in
                                if target.photoHttpStr == data.photoHttpStr!{
                                    return true
                                }
                                return false
                            }){
                                self.friendsList[user_index].photo = get_img
                                DispatchQueue.main.async {
                                    self.targetVC.tableView.beginUpdates()
                                    self.targetVC.tableView.reloadRows(at: [IndexPath(row: user_index as Int, section: 0)], with: UITableViewRowAnimation.none)
                                    self.targetVC.tableView.endUpdates()
                                }
                            }
                        })
                    }
                    
                }

                
            }
            cell2.photo.image = data.photo
            cell2.truePhoto.image = UIImage(named:"True_photo")!.withRenderingMode(.alwaysTemplate)
            if data.isRealPhoto!{
                cell2.truePhoto.tintColor = UIColor.white
            }
            else{
                cell2.truePhoto.tintColor = UIColor.clear
            }
            cell2.name.text = data.name
            cell2.last_line.text = data.lastLine
            if data.read_msg == false, data.last_speaker != userData.name{
                if data.last_speaker != userData.name{
                    cell2.last_line.textColor = UIColor(red:0.99, green:0.38, blue:0.27, alpha:1.0)
                }
                else{
                    cell2.last_line.textColor = nil
                }
            }
            else{
                cell2.last_line.textColor = nil
            }
            cell2.onlineImg.layoutIfNeeded()
            cell2.onlineImg.layer.borderWidth = 1
            cell2.onlineImg.layer.borderColor = UIColor.white.cgColor
            let cr = (cell2.onlineImg.frame.size.width)/2
            cell2.onlineImg.layer.cornerRadius = cr
            cell2.onlineImg.clipsToBounds = true

            cell2.onlineImg.image = UIImage(named:"online")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            if data.online!{
                cell2.onlineImg.tintColor = UIColor(red:0.15, green:0.88, blue:0.77, alpha:1.0)
            }
            else{
                cell2.onlineImg.tintColor = UIColor.lightGray
            }
            let thePhotoLayer:CALayer = cell2.photo.layer
            thePhotoLayer.masksToBounds = true
            thePhotoLayer.cornerRadius = 6

            return cell2
        }
            
        else if data.cell_type == "invite"{
            let cell2 = cell as! FriendInvitedCellTableViewCell
            if data.photo == nil{
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    if data.photoHttpStr != nil && data.photoHttpStr != ""{
                        let url = "https://www.paeban.com/media/\(data.photoHttpStr!)"
                        HttpRequestCenter().getHttpImg(url, getImg: { (get_img) in
                            if let user_index = self.friendsList.index(where: { (target) -> Bool in
                                if target.photoHttpStr == data.photoHttpStr!{
                                    return true
                                }
                                return false
                            }){
                                self.friendsList[user_index].photo = get_img
                                DispatchQueue.main.async {
                                    self.targetVC.tableView.beginUpdates()
                                    self.targetVC.tableView.reloadRows(at: [IndexPath(row: user_index as Int, section: 0)], with: UITableViewRowAnimation.none)
                                    self.targetVC.tableView.endUpdates()
                                }
                            }
                        })
                    }
                    
                }
//                if !data.online_checked{
//                    data.online_checked = true
//                    let send_dic:NSDictionary = [
//                        "msg_type":"check_online",
//                        "check_id":data.id!
//                    ]
//                    socket.write(data: json_dumps(send_dic))
//                }
                
            }
            
            cell2.photo.image = data.photo
            cell2.id = data.id
            cell2.true_photo.image = UIImage(named:"True_photo")
            if data.isRealPhoto!{
                cell2.true_photo.tintColor = UIColor.white
            }
            else{
                cell2.true_photo.tintColor = UIColor.clear
            }
            cell2.name.text = data.name
            cell2.online.image = UIImage(named:"online")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            if data.online!{
                cell2.online.tintColor = UIColor(red:0.15, green:0.88, blue:0.77, alpha:1.0)
            }
            else{
                cell2.online.tintColor = UIColor.lightGray
            }
            let thePhotoLayer:CALayer = cell2.photo.layer
            thePhotoLayer.masksToBounds = true
            thePhotoLayer.cornerRadius = 6
            cell2.delegate = targetVC
            // cell delete button
            
            
            return cell2
        }
            
        else if data.cell_type == "list"{
            let cell2 = cell as! FriendInvitedListTableViewCell
            cell2.invited_count.text = String(describing: data.invite_list_count!)
            return cell2
        }
        else{
            return cell
        }
    }
    
    func getSegueData(_ index:Int) -> Dictionary<String,AnyObject>{
        var returnDic:Dictionary<String,AnyObject> = [:]
        let dataSouse = friendsList[index]
        returnDic["clientId"] = dataSouse.id as AnyObject?
        returnDic["clientName"] = dataSouse.name as AnyObject?
        returnDic["clientImg"] = dataSouse.photo
        return returnDic
    }
    func getFrientList(){
        let send_dic:NSDictionary = [
            "none": "none"
        ]
        HttpRequestCenter().friend_function(msg_type: "get_friend_list", send_dic: send_dic) { (return_dic) in
            DispatchQueue.main.async {
                print("get_friend_list")
                let return_list = turnToFriendStanderType_v2(friend_dic: return_dic)
                for cell_s in return_list{
                    if self.check_if_list_need_to_update_or_add(new_obj: cell_s){
                        self.replace_singel_cell_or_add(new_obj: cell_s)
                    }
                }
            }
        }
    }
    func check_if_list_need_to_update_or_add(new_obj:FriendStanderType) -> Bool{
        if let friend_cell_index = myFriendsList.index(where: {(element) -> Bool in
            if element.id == new_obj.id{
                return true
            }
            return false
        }){
            let old_obj = myFriendsList[friend_cell_index]
            if old_obj.lastLine == new_obj.lastLine{
                return false
            }
            return true
        }
        return true
    }
    func replace_singel_cell_or_add(new_obj:FriendStanderType){
        if let friend_index = self.friendsList.index(where: { (element) -> Bool in
            if element.id == new_obj.id{
                return true
            }
            return false
        }){
            myFriendsList.remove(at: friend_index as Int)
            myFriendsList.insert(new_obj, at: friend_index as Int)
            let index_path = IndexPath(row: friend_index, section: 0)
            targetVC.tableView.beginUpdates()
            targetVC.tableView.reloadRows(at: [index_path], with: .none)
            targetVC.tableView.endUpdates()
        }
        else{
            //friend
            self.add_new_friend_cell(new_obj: new_obj)
        }
    }
    func add_new_friend_cell(new_obj:FriendStanderType){
        var cell_index = 0
        for cell_s in friendsList{
            if cell_s.cell_type != "friend"{
                break
            }
            cell_index += 1
        }
        myFriendsList.insert(new_obj, at: cell_index)
        let index_path = IndexPath(row: cell_index, section: 0)
        targetVC.tableView.beginUpdates()
        targetVC.tableView.insertRows(at: [index_path], with: .left)
        targetVC.tableView.endUpdates()
    }
    func replace_friend_cell(){
        for friend_cell_s in self.friend_list_database{
            if let friend_cell_index = self.friendsList.index(where: { (element) -> Bool in
                if element.id == friend_cell_s.id{
                    return true
                }
                return false
            }){
                myFriendsList.remove(at: friend_cell_index as Int)
                myFriendsList.insert(friend_cell_s, at: friend_cell_index as Int)
                let index_path = IndexPath(row: friend_cell_index as Int, section: 0)
                targetVC.tableView.beginUpdates()
                targetVC.tableView.reloadRows(at: [index_path], with: .none)
                targetVC.tableView.endUpdates()
            }
        }
    }
    func turnToMessage3(_ inputDic:Dictionary<String,AnyObject>) -> JSQMessage3{
        let returnObj = JSQMessage3(senderId: inputDic["senderId"] as! String,
                                    displayName: inputDic["displayName"] as! String,
                                    text: inputDic["text"] as! String)
        returnObj?.topicId = inputDic["topicId"] as? String
        returnObj?.topicTempid = inputDic["topicTempid"] as? String
        returnObj?.isRead = inputDic["isRead"] as? Bool
        return returnObj!
    }
    func addInviteList(input_dic:Dictionary<String,AnyObject>){
        var temp_invite_list:Array<FriendStanderType> = []
        for input_dic_keys in input_dic.keys{
            let input_dic_data = input_dic[input_dic_keys] as! Dictionary<String,AnyObject>
            let add_data = FriendStanderType()
            add_data.cell_type = "invite"
            add_data.id = input_dic_keys
            add_data.name = input_dic_data["name"] as? String
            add_data.isRealPhoto = input_dic_data["isRealPhoto"] as? Bool
            add_data.online = false
            add_data.photoHttpStr = input_dic_data["photoHttpStr"] as? String
            add_data.sex = input_dic_data["sex"] as? String
            temp_invite_list.append(add_data)
        }
        self.invite_list = temp_invite_list
    }
    func table_view_state() -> Int{
        var extend_btn_state:Int = 0
        // 1.原本沒有伸展按鈕
        // 2.有伸展按鈕但沒打開
        // 3.有伸展按鈕且有打開
        // 判斷現在狀況
        if let list_index = friendsList.index(where: { (target:FriendStanderType) -> Bool in
            if target.cell_type == "list"{
                return true
            }
            return false
        }){
            let list_index_int = list_index as Int
            if friendsList.count > list_index_int + 1{
                if friendsList[list_index_int + 1].cell_type == "invite"{
                    extend_btn_state = 3
                }
                else{
                    extend_btn_state = 2
                }
            }
            else{extend_btn_state = 2}
        }
        else{extend_btn_state = 1}
        
        return extend_btn_state
    }
    func add_list_extend_btn(){
        let list_extend_btn = FriendStanderType()
        list_extend_btn.cell_type = "list"
        list_extend_btn.invite_list_count = self.invite_list.count
        friendsList.insert(list_extend_btn, at: 0)
    }
    func add_invite_list_to_table() {
        for invite_cell in invite_list{
            friendsList.insert(invite_cell, at: 1)
        }
    }
    func remove_list_btn(){
        if friendsList[(friendsList.count - 1)].cell_type == "list"{
            friendsList.remove(at: (friendsList.count - 1))
        }
    }
    func remove_invite_list_to_table(){
        var new_friendsList:Array<FriendStanderType> = []
        for cells in friendsList{
            if cells.cell_type != "invite"{
                new_friendsList.append(cells)
            }
        }
        friendsList = new_friendsList
    }
    func remove_cell(with id:String){
        if targetVC.delete_alot_switch{
            remove_cell_enforce(with: id)
        }
    }
    func remove_cell_enforce(with id:String){
        if let remove_id_index = invite_list.index(where: { (target) -> Bool in
            if target.id == id{
                return true
            }
            return false
        }){
            let remove_id_index_int = remove_id_index as Int
            invite_list.remove(at: remove_id_index_int)
        }
        
        updateModel()
    }
    
    func updateModel() {
        
        let extend_btn_state:Int = table_view_state()
        
        // 1.原本沒有伸展按鈕
        // 2.有伸展按鈕但沒打開
        // 3.有伸展按鈕且有打開
        if extend_btn_state == 1{
            if !self.invite_list.isEmpty{
                add_list_extend_btn()
                targetVC.tableView.reloadData()
            }
        }
        else if extend_btn_state == 2{
            var new_friendsList = friendsList
            for cell_index in 0..<new_friendsList.count{
                if new_friendsList[cell_index].cell_type == "list"{
                    new_friendsList.remove(at: cell_index)
                    break
                }
            }
            friendsList = new_friendsList
            add_list_extend_btn()
            targetVC.tableView.reloadData()
            
        }
        else if extend_btn_state == 3{
            remove_invite_list_to_table()
            var new_friendsList = friendsList
            for cell_index in 0..<new_friendsList.count{
                if new_friendsList[cell_index].cell_type == "list"{
                    new_friendsList.remove(at: cell_index)
                    break
                }
            }
            friendsList = new_friendsList
            if !invite_list.isEmpty{
                add_list_extend_btn()
                add_invite_list_to_table()
            }
            targetVC.tableView.reloadData()
        }
    }
    func update_online(){
        
    }
    func add_friend(id:String, name:String, photoHttpStr:String, isRealPhoto:Bool, online:Bool){
        let friend_obj = FriendStanderType()
        friend_obj.cell_type = "friend"
        friend_obj.id = id
        friend_obj.name = name
        friend_obj.photoHttpStr = photoHttpStr
        friend_obj.online = online
        friend_obj.isRealPhoto = isRealPhoto
        
        let index_path = IndexPath(row: friendsList.count, section: 0)
        friendsList.append(friend_obj)
        targetVC.tableView.beginUpdates()
        targetVC.tableView.insertRows(at: [index_path], with: .left)
        targetVC.tableView.endUpdates()
    }
    func add_singo_invite_cell(msg:Dictionary<String, AnyObject>){
        let invite_obj = FriendStanderType()
        invite_obj.cell_type = "invite"
        invite_obj.id = msg["sender_id"] as? String
        invite_obj.name = msg["sender_name"] as? String
        invite_obj.photoHttpStr = msg["sender_pic"] as? String
        invite_obj.isRealPhoto = msg["isRealPhoto"] as? Bool
        invite_obj.online = false
        invite_list.append(invite_obj)        
        updateModel()
        
    }
    
    // delegate
    func change_online_state(change_id:String, state:Bool){
        if let update_online_index = friendsList.index(where: { (target) -> Bool in
            if target.id == change_id{
                return true
            }
            return false
        }){
            let update_online_index_path = IndexPath(row: update_online_index as Int, section: 0)
            friendsList[update_online_index].online = state
            targetVC.tableView.beginUpdates()
            targetVC.tableView.reloadRows(at: [update_online_index_path], with: UITableViewRowAnimation.none)
            targetVC.tableView.endUpdates()
        }
    }
    
    func wsOnMsg(_ msg: Dictionary<String, AnyObject>) {
        if let msg_type:String =  msg["msg_type"] as? String{
            if msg_type == "check_online"{
                let check_id = msg["check_id"] as! String
                let online = msg["online"] as! Bool
                change_online_state(change_id: check_id, state: online)
                
            }
            else if msg_type == "off_line"{
                let check_id = msg["user_id"] as! String
                change_online_state(change_id: check_id, state: false)
            }
            else if msg_type == "new_member"{
                let check_id = msg["user_id"] as! String
                change_online_state(change_id: check_id, state: true)
            }
            else if msg_type == "friend_confirm_success"{
                if msg["answer"] as! String == "yes"{
                    print(msg)
                    self.add_friend(id: msg["friend_id"] as! String,
                                    name: msg["friend_name"] as! String,
                                    photoHttpStr: msg["friend_pic"] as! String,
                                    isRealPhoto: msg["isRealPhoto"] as! Bool,
                                    online: msg["online"] as! Bool
                    )
                }
            }
            else if msg_type == "friend_confirm"{
                add_singo_invite_cell(msg: msg)
                fast_alter(inviter: (msg["sender_name"] as? String)!, nav_controller: targetVC.parent as! UINavigationController)
            }
            else if msg_type == "priv_msg"{
                let resultDic_msg_id:Dictionary<String,AnyObject> = msg["result_dic"] as! Dictionary<String,AnyObject>
                for resultDic in resultDic_msg_id.values{
                    let sender_name = resultDic["sender_name"] as! String
                    let msg_text = resultDic["private_text"] as! String
                    let last_line = "\(sender_name):  \(msg_text)"
                    
                    let client_id = self.find_client_id(
                        id_1: resultDic["sender_id"]! as! String,
                        id_2: resultDic["receiver_id"]! as! String
                    )
                    if let friend_cell_index = friendsList.index(where: { (element) -> Bool in
                        if element.id == client_id{
                            return true
                        }
                        return false
                    }){
                        friendsList[friend_cell_index].lastLine = last_line
                        //print(chat_view?.clientId)
                        //print(client_id)
                        if chat_view?.clientId == client_id{
                            if sender_name != userData.name{
                                friendsList[friend_cell_index].read_msg = true
                            }
                            else{
                                friendsList[friend_cell_index].read_msg = false
                            }
                            
                        }
                        else{
                            friendsList[friend_cell_index].read_msg = false
                        }
                        let index_path = IndexPath(row: friend_cell_index, section: 0)
                        targetVC.tableView.beginUpdates()
                        targetVC.tableView.reloadRows(at: [index_path], with: .none)
                        targetVC.tableView.endUpdates()
                    }
                }
                
                
            }
            
        }
    }
    func wsReconnected(){
    }
    func find_client_id(id_1:String, id_2:String) -> String{
        if id_1 == userData.id{
            return id_2
        }
        return id_1
    }
    
    
}








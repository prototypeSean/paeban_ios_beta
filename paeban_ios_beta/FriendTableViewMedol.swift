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
    var invite_list:Array<FriendStanderType> = []
    
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
            cell2.photo.image = data.photo
            cell2.truePhoto.image = UIImage(named:"True_photo")
            if data.isRealPhoto!{
                cell2.truePhoto.tintColor = UIColor.white
            }
            else{
                cell2.truePhoto.tintColor = UIColor.clear
            }
            cell2.name.text = data.name
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
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                if !data.online_checked{
                    data.online_checked = true
                    let send_dic:NSDictionary = [
                        "msg_type":"check_online",
                        "check_id":data.id!
                    ]
                    socket.write(data: json_dumps(send_dic))
                }
            }
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
                                    self.targetVC.tableView.reloadRows(at: [IndexPath(row: user_index as Int, section: 0)], with: UITableViewRowAnimation.automatic)
                                    self.targetVC.tableView.endUpdates()
                                }
                            }
                        })
                    }
                    
                }
                if !data.online_checked{
                    data.online_checked = true
                    let send_dic:NSDictionary = [
                        "msg_type":"check_online",
                        "check_id":data.id!
                    ]
                    socket.write(data: json_dumps(send_dic))
                }
                
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
            if friendsList.count == list_index_int + 1{
                extend_btn_state = 2
            }
            else{extend_btn_state = 3}
        }
        else{extend_btn_state = 1}
        return extend_btn_state
    }
    func add_list_extend_btn(){
        let list_extend_btn = FriendStanderType()
        list_extend_btn.cell_type = "list"
        list_extend_btn.invite_list_count = self.invite_list.count
        friendsList = friendsList + [list_extend_btn]
    }
    func add_invite_list_to_table() {
        friendsList += invite_list
    }
    func remove_invite_list_to_table(){
        if let list_btn_index = friendsList.index(where: { (target) -> Bool in
            if target.cell_type == "list"{
                return true
            }
            return false
        }){
            
            var new_friendsList = friendsList
            let list_btn_index_int = list_btn_index as Int
            for remove_position_rev in 1 ..< friendsList.count{
                let remove_position = friendsList.count - remove_position_rev
                if remove_position > list_btn_index_int{
                    new_friendsList.remove(at: remove_position)
                }
                else{
                    break
                }
            }
            friendsList = new_friendsList
        
        }
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
            new_friendsList.remove(at: friendsList.count - 1)
            friendsList = new_friendsList
            add_list_extend_btn()
            targetVC.tableView.reloadData()
            
        }
        else if extend_btn_state == 3{
            remove_invite_list_to_table()
            var new_friendsList = friendsList
            new_friendsList.remove(at: friendsList.count - 1)
            friendsList = new_friendsList
            add_list_extend_btn()
            add_invite_list_to_table()
            targetVC.tableView.reloadData()
        }
    }
    func update_online(){
        
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
            targetVC.tableView.reloadRows(at: [update_online_index_path], with: UITableViewRowAnimation.automatic)
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
        }
    }
    
}








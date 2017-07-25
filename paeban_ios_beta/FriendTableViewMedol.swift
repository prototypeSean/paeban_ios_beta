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
    var friendsList:Array<FriendStanderType> = []
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
    // code 2.0
    func getFrientList(){
        friendsList = []
        friend_list_database = []
        let result_dic = sql_database.get_friend_list()
        let new_table_data = turnToFriendStanderType_v3(friend_list:result_dic)
        renew_friend_list_database(input_list: new_table_data)
        //update_imgs_from_server()
        update_online_state()
    }
    func renew_friend_list_database(input_list:Array<FriendStanderType>){
        friend_list_database = input_list.sorted(by: { (ele1, ele2) -> Bool in
            if ele1.time != nil && ele2.time != nil{
                if ele1.time! > ele2.time!{
                    return true
                }
            }
            return false
        })
        updateModel()
    }
    func turnToFriendStanderType_v3(friend_list:Array<Dictionary<String,AnyObject>>) -> Array<FriendStanderType>{
        var return_list:Array<FriendStanderType> = []
        for friend_data in friend_list{
            let temp_cell = FriendStanderType()
            temp_cell.id = friend_data["client_id"] as? String
            temp_cell.cell_type = "friend"
            temp_cell.name = friend_data["client_name"] as? String
            temp_cell.isRealPhoto = friend_data["isRealPhoto"] as? Bool
            temp_cell.photoHttpStr = friend_data["img_name"] as? String
            temp_cell.sex = friend_data["sex"] as? String
            temp_cell.read_msg = friend_data["is_read"] as? Bool
            if friend_data["img"] != nil{
                temp_cell.photo = base64ToImage(friend_data["img"] as! String)
            }
            let lastLine = friend_data["lastLine"] as? String
            let last_speaker_name = friend_data["last_speaker_name"] as? String
            if last_speaker_name != nil && lastLine != nil{
                temp_cell.lastLine = "\(lastLine!)"
                temp_cell.last_speaker = last_speaker_name
                temp_cell.time = friend_data["time"] as? Double
            }
            return_list.append(temp_cell)
        }
        return_list.sort { (fs1, fs2) -> Bool in
            if fs1.time != nil && fs2.time != nil{
                if fs1.time! > fs2.time!{
                    return true
                }
                return false
            }
            else if fs1.time != nil && fs2.time == nil{
                return true
            }
            return false
        }
        return return_list
    }
    func update_imgs_from_server(){
        var cell_index = 0
        let res_friend_list_database:Array<FriendStanderType> = friend_list_database.reversed()
        let last_change_index = res_friend_list_database.index { (ele:FriendStanderType) -> Bool in
            if ele.photo == nil{
                return true
            }
            return false
        }
        
        for cells in friend_list_database{
            if cells.photo == nil{
                let url = "\(local_host)media/\(cells.photoHttpStr!)"
                HttpRequestCenter().getHttpImg(url, getImg: { (img) in
                    sql_database.update_friend_img(
                        username_in: cells.id!,
                        img: imageToBase64(image: img, optional: "withHeader"),
                        img_name: cells.photoHttpStr!
                    )
                    if last_change_index != nil{
                        if cell_index == Int(last_change_index!) {
                            let result_dic = sql_database.get_friend_list()
                            let new_table_data = self.turnToFriendStanderType_v3(friend_list:result_dic)
                            self.renew_friend_list_database(input_list: new_table_data)
                        }
                    }
                    
                })
            }
            cell_index += 1
        }
    }
    
    func update_online_state(){
        var client_id_list:Array<String> = []
        for cell_datas in friendsList{
            if cell_datas.cell_type == "friend"{
                client_id_list.append(cell_datas.id!)
            }
        }
        HttpRequestCenter().inquire_online_state(client_id_list: client_id_list) { (return_dic:Dictionary<String, AnyObject>) in
            if !return_dic.isEmpty{
                let return_dic_copy = return_dic as! Dictionary<String,Bool>
                for cell_datas in self.friendsList{
                    if cell_datas.cell_type == "friend"{
                        if let online_state = return_dic_copy[cell_datas.id!]{
                            cell_datas.online = online_state
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.updateModel()
                }
            }
        }
    }
    // code 2.0
    
    
    func getCell(_ index:Int,cell:UITableViewCell) -> UITableViewCell {
        let data = friendsList[index]
        if data.cell_type == "friend"{
            let cell2 = cell as! FriendTableViewCell
            if data.photo == nil{
                // fly
                print("NILLLLLLLLL")
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    if data.photoHttpStr != nil && data.photoHttpStr != ""{
                        let url = "\(local_host)media/\(data.photoHttpStr!)"
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
            cell2.lastspeaker.text = data.last_speaker
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
                    cell2.last_line.textColor = UIColor(red:0.97, green:0.49, blue:0.31, alpha:1.0)
                }
                else{
                    cell2.last_line.textColor = UIColor(red:0.30, green:0.30, blue:0.30, alpha:1.0)
                }
            }
            else{
                cell2.last_line.textColor = UIColor(red:0.30, green:0.30, blue:0.30, alpha:1.0)
            }
            cell2.onlineImg.layoutIfNeeded()
            cell2.onlineImg.layer.borderWidth = 1
            cell2.onlineImg.layer.borderColor = UIColor.white.cgColor
            let cr = (cell2.onlineImg.frame.size.width)/2
            cell2.onlineImg.layer.cornerRadius = cr
            cell2.onlineImg.clipsToBounds = true

            cell2.onlineImg.image = UIImage(named:"online")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            if data.online != nil{
                if data.online!{
                    cell2.onlineImg.tintColor = UIColor(red:0.15, green:0.88, blue:0.77, alpha:1.0)
                }
                else{
                    cell2.onlineImg.tintColor = UIColor.lightGray
                }
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
                        let url = "\(local_host)media/\(data.photoHttpStr!)"
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
    func getFrientList_old(){
        HttpRequestCenter().request_user_data("get_friend_list_v2", send_dic: [:], InViewAct: { (return_dic) in
            var request_friend_detail_dic:Dictionary<String,String> = [:]
            var update_seitch = false
            for friend_data in return_dic{
                let value = friend_data.value as! Dictionary<String,String>
                if sql_database.check_friend_id(username_in: friend_data.key){
                    if !sql_database.check_friend_name(username_in: friend_data.key, user_full_name_in: value["user_full_name"]!){
                        sql_database.update_friend_full_name(username_in: friend_data.key, user_full_name_in: value["user_full_name"]!)
                        update_seitch = true
                    }
                    if !sql_database.check_friend_image_name(username_in: friend_data.key, img_name: value["image_name"]!){
                        self.updata_friend_img(username_in: friend_data.key, url: value["image_name"]!)
                    }
                }
                else{
//                    sql_database.insert_friend(username_in: friend_data.key, user_full_name_in: value["user_full_name"]!, img_name: value["image_name"]!)
                    request_friend_detail_dic[friend_data.key] = value["image_name"]!
                    self.updata_friend_img(username_in: friend_data.key, url: value["image_name"]!)
                }
                self.get_friend_detail(send_dic: request_friend_detail_dic)
            }
            if update_seitch{
                self.updateModel()
            }
        })
//        (msg_type: "get_friend_list", send_dic: [:]) { (return_dic) in
//            DispatchQueue.main.async {
//                let return_list = turnToFriendStanderType_v2(friend_dic: return_dic)
//                self.friend_list_database = return_list
//                self.updateModel()
//                //self.targetVC.tableView.reloadData()
//            }           
//        }
    }
    func get_friend_detail(send_dic:Dictionary<String,String>){
        HttpRequestCenter().request_user_data("get_friend_detail", send_dic: send_dic) { (return_dic) in
            //code
        }
    }
    func updata_friend_img(username_in:String,url:String){
        HttpRequestCenter().getHttpImg("\(image_url_host)\(url)") { (img) in
            let img_base64 = imageToBase64(image: img, optional: "withHeader")
            sql_database.update_friend_img(username_in: username_in, img: img_base64, img_name: url)
            DispatchQueue.main.async {
                self.updateModel()
            }
        }
        
        
    }
    func check_if_list_need_to_update_or_add(new_obj:FriendStanderType) -> Bool{
        if let friend_cell_index = friendsList.index(where: {(element) -> Bool in
            if element.id == new_obj.id{
                return true
            }
            return false
        }){
            let old_obj = friendsList[friend_cell_index]
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
            friendsList.remove(at: friend_index as Int)
            friendsList.insert(new_obj, at: friend_index as Int)
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
        friendsList.insert(new_obj, at: cell_index)
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
                friendsList.remove(at: friend_cell_index as Int)
                friendsList.insert(friend_cell_s, at: friend_cell_index as Int)
            }
            else{
                friendsList.append(friend_cell_s)
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
            if !check_already_friend(client_id: input_dic_keys){
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
        }
        self.invite_list = temp_invite_list
    }
    func check_already_friend(client_id:String) -> Bool{
        // named by DK
        // 驗證邀請清單內有無已是好友的人，有的話自動回覆server確認邀請
        if let _ = friend_list_database.index(where: { (ele:FriendStanderType) -> Bool in
            if ele.id == client_id{
                return true
            }
            return false
        }){
            // 送出同意訊號
            let send_dic:NSDictionary = [
                "msg_type":"friend_confirm",
                "friend_id":client_id,
                "answer": "yes"
            ]
            socket.write(data: json_dumps(send_dic))
            return true
        }
        else{
            return false
        }
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
    func remove_friend(id:String){
        if let remove_id_index = friendsList.index(where: { (target) -> Bool in
            if target.id == id{
                return true
            }
            return false
        }){
            print(remove_id_index)
            let remove_id_index_int = remove_id_index as Int
            friendsList.remove(at: remove_id_index_int)
        }
        targetVC.tableView.reloadData()
    }
    
    func updateModel() {
        
        let extend_btn_state:Int = table_view_state()
        
        // 1.原本沒有伸展按鈕
        // 2.有伸展按鈕但沒打開
        // 3.有伸展按鈕且有打開
        
        //fly
        print("table_view_state: \(extend_btn_state)")
        if extend_btn_state == 1{
            if !self.invite_list.isEmpty{
                add_list_extend_btn()
            }
            replace_friend_cell()
            targetVC.tableView.reloadData()
            //fly
            print(friendsList)
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
    func add_friend(id:String, name:String, photoHttpStr:String, isRealPhoto:Bool, online:Bool, sex:String){
        let temp_input_dic:Dictionary<String,AnyObject> = [
            "client_id": id as AnyObject,
            "client_name": name as AnyObject,
            "img_name": photoHttpStr as AnyObject,
            "is_real_pic" : isRealPhoto as AnyObject,
            "sex" : sex as AnyObject
        ]
        
        sql_database.insert_friend(input_dic: temp_input_dic)
        getFrientList()
//        let friend_obj = FriendStanderType()
//        friend_obj.cell_type = "friend"
//        friend_obj.id = id
//        friend_obj.name = name
//        friend_obj.photoHttpStr = photoHttpStr
//        friend_obj.online = online
//        friend_obj.isRealPhoto = isRealPhoto
//        
//        let index_path = IndexPath(row: friendsList.count, section: 0)
//        friendsList.append(friend_obj)
//        targetVC.tableView.beginUpdates()
//        targetVC.tableView.insertRows(at: [index_path], with: .left)
//        targetVC.tableView.endUpdates()
    }
    func add_singo_invite_cell(msg:Dictionary<String, AnyObject>){
        let invite_obj = FriendStanderType()
        invite_obj.cell_type = "invite"
        invite_obj.id = msg["sender_id"] as? String
        invite_obj.name = msg["sender_name"] as? String
        invite_obj.photoHttpStr = msg["sender_pic"] as? String
        invite_obj.isRealPhoto = msg["isRealPhoto"] as? Bool
        invite_obj.online = false
        invite_obj.sex = msg["sex"] as? String
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
                                    online: msg["online"] as! Bool,
                                    sex: msg["sex"] as! String
                    )
                }
            }
            else if msg_type == "friend_confirm"{
                add_singo_invite_cell(msg: msg)
                fast_alter(inviter: (msg["sender_name"] as? String)!, nav_controller: targetVC.parent as! UINavigationController)
            }
            else if msg_type == "priv_msg" && false{
                // working 改成從本地資料庫讀取  從另一個delegate
                let resultDic:Dictionary<String,AnyObject> = msg["result_dic"] as! Dictionary<String,AnyObject>
                let sender_name = resultDic["sender_name"] as! String
                let msg_text = resultDic["private_text"] as! String
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
                    friendsList[friend_cell_index].lastLine = msg_text
                    friendsList[friend_cell_index].last_speaker = sender_name
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
                    let temp_cell_obj = friendsList[friend_cell_index]
                    friendsList.remove(at: friend_cell_index)
                    friendsList.insert(temp_cell_obj, at: 0)
                    self.targetVC.tableView.reloadData()
                }
                else{
                    synchronize_friend_table(after: nil)
                }
                getFrientList()
                
            }
            
        }
    }
    func wsReconnected(){
        //synchronize_friend_table()
    }
    func find_client_id(id_1:String, id_2:String) -> String{
        if id_1 == userData.id{
            return id_2
        }
        return id_1
    }
    func new_client_topic_msg(sender: String) {
        print("new_client_topic_msg++++")
        self.getFrientList()
        self.updateModel()
        targetVC.update_badges()
    }
    
}








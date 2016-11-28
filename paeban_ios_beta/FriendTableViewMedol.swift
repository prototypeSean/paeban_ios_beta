//
//  FriendTableViewMedol.swift
//  paeban_ios_beta
//
//  Created by 工作用 on 2016/9/4.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import Foundation
import UIKit

class FriendTableViewMedol{
    var friendsList:Array<FriendStanderType>{
        get{
            return myFriendsList
        }
        set{
            myFriendsList = newValue
            targetVC.tableView.reloadData()
        }
    }
    var invite_list:Array<FriendStanderType> = []
    
    func getDataCount() -> Int{
        return friendsList.count
    }
    var targetVC:FriendTableViewController
    
    init(with view_controller:FriendTableViewController) {
        self.targetVC = view_controller
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
            return cell2
        }
        else if data.cell_type == "invuted"{
            return cell
        }
        else if data.cell_type == "list"{
            return cell
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
            if friendsList.count == list_index_int - 1{
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
        friendsList.append(list_extend_btn)
    }
    func add_invite_list_to_table() {
        friendsList += invite_list
    }
    func updateModel() {
        let extend_btn_state:Int = table_view_state()
        // 1.原本沒有伸展按鈕
        // 2.有伸展按鈕但沒打開
        // 3.有伸展按鈕且有打開
        if extend_btn_state == 1{
            if !self.invite_list.isEmpty{
                add_list_extend_btn()
            }
        }
        else if extend_btn_state == 2{
            friendsList.remove(at: friendsList.count - 1)
            add_list_extend_btn()
        }
        else if extend_btn_state == 3{
            friendsList.remove(at: friendsList.count - 1)
            add_list_extend_btn()
            add_invite_list_to_table()
        }
    }
    
}








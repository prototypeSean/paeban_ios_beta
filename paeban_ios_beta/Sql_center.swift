//
//  Sql_center.swift
//  paeban_ios_beta
//
//  Created by 工作用 on 2017/1/8.
//  Copyright © 2017年 尚義 高. All rights reserved.
//

import Foundation
import SQLite

public class SQL_center{
    let print_part_log_switch = false
    var sql_db:Connection?
    // private var
    let private_text = Expression<String?>("private_text")
    var private_table = Table("private_msg")
    
    // topic var
    var topic_content = Table("topic_content")
    let id = Expression<Int64>("id")
    let topic_id = Expression<String?>("topic_id")
    let topic_text = Expression<String?>("topic_text")
    let sender = Expression<String?>("sender")
    let receiver = Expression<String?>("receiver")
    let time = Expression<Double?>("time")
    let is_read = Expression<Bool?>("is_read")
    let is_send = Expression<Bool?>("is_send")
    let id_server = Expression<String?>("id_server")
    let battery = Expression<String?>("battery")
    // user data
    let user_data_table = Table("user_data_table")
    let user_id = Expression<String>("user_id")
    let user_name = Expression<String>("user_name")
    let img = Expression<String?>("img")
    let img_name = Expression<String>("img_name")
    // user_img
    let user_img_table = Table("user_img_table")
    let user_img_level = Expression<String>("user_img_level")
    // version
    var version_table = Table("version_table")
    let version_number = Expression<String?>("version_number")
    // leave_topic var
    var leave_topic = Table("leave_topic")
    // leave_topic_master
    var leave_topic_master = Table("leave_topic_master")
    let client_id = Expression<String?>("client_id")
    // black_list
    let black_list_table = Table("black_list")
    let username = Expression<String>("username")
    // friend_list
    let user_full_name = Expression<String>("user_full_name")
    let friend_list_table = Table("friend_list")
    let friend_image = Expression<String?>("friend_image")
    let friend_image_file_name = Expression<String?>("friend_image_file_name")
    // mytopic
    let my_topic = Table("my_topic")
    let topic_title = Expression<String?>("topic_title")
    let tags = Expression<String?>("tags")
    //recent_topic
    let recent_topic = Table("recent_topic")
    let active = Expression<Bool>("active")
    // tmp_client_data
    let tmp_client_Table = Table("tmp_client_data")
    let tmp_client_name = Expression<String?>("tmp_client_name")
    let tmp_client_img = Expression<String?>("tmp_client_img")
    let tmp_client_img_name = Expression<String?>("tmp_client_img_name")
    let tmp_client_sex = Expression<String?>("tmp_client_sex")
    let tmp_client_real_pic = Expression<Bool?>("tmp_client_real_pic")
    let tmp_client_level = Expression<Int64?>("tmp_client_level")
    //recent
    // ignore_list
    let ignore_list = Table("ignore_list")

    func insert_private_msg_mega_ver(input_list:Array<Dictionary<String, AnyObject>>, persent_report:@escaping ()->Void){
        do{
            try sql_db?.transaction {
                for input_dic in input_list{
                    let id_server_input = input_dic["id_server"]! as? String
                    let is_read_input = input_dic["is_read"]! as? Bool
                    let is_send_input = true
                    let time_string = input_dic["time"]! as! String
                    let time_input = time_transform_to_since1970(time_string:time_string)
                    let insert = self.private_table.insert(
                        self.private_text <- input_dic["private_text"]! as? String,
                        self.sender <- input_dic["sender_id"]! as? String,
                        self.receiver <- input_dic["receiver_id"]! as? String,
                        self.time <- time_input,
                        self.is_read <- is_read_input,
                        self.is_send <- is_send_input,
                        self.id_server <- id_server_input
                    )
                    try self.sql_db!.run(insert)
                    persent_report()
                }
            }
        }
        catch{
            print(error)
            print("error!!!!")
        }
    }
    func insert_topic_msg_mega_ver(input_list:Array<Dictionary<String, AnyObject>>, persent_report:@escaping ()->Void){
        do{
            try sql_db!.transaction {
                for topic_content_data_s in input_list{
                    if topic_content_data_s["sender"] as? String == userData.id{
                        self.insert_self_topic_content(input_dic: topic_content_data_s, option: .server)
                    }
                    else{
                        self.insert_client_topic_content_from_server(input_dic: topic_content_data_s, check_state: .checked)
                    }
                    persent_report()
                }
            }
        }
        catch{
            print("ERROR!!!!! insert_topic_msg_mega_ver")
            print(error)
        }
    }
    func insert_topic_msg_mega_ver_v2(input_list:Array<Dictionary<String, AnyObject>>, persent_report:@escaping ()->Void){
        do{
            try sql_db!.transaction {
                for input_dic in input_list{
                    let time_in = time_transform_to_since1970(time_string: input_dic["time"]! as! String)
                    let insert = self.topic_content.insert(
                        self.topic_id <- input_dic["topic_id"]! as? String,
                        self.topic_text <- input_dic["topic_content"]! as? String,
                        self.sender <- input_dic["sender"]! as? String,
                        self.receiver <- input_dic["receiver"]! as? String,
                        self.time <- time_in,
                        self.is_read <- input_dic["is_read"] as? Bool,
                        self.is_send <- true,
                        self.id_server <- input_dic["id_server"]! as? String
                        //battery <- input_dic["battery"] as? String
                    )
                    try self.sql_db!.run(insert)
                    persent_report()
                }
            }
        }
        catch{
            print("ERROR!!!!! insert_topic_msg_mega_ver")
            print(error)
        }
    }
    
    func establish_all_table(version:String){
        self.establish_version(version: version)
        self.establish_private_msg_table()
        self.establish_topic_content_table()
        //self.establish_leave_topic_table()
        //self.establish_leave_topic_master_table()
        self.establish_black_list()
        self.establish_friend_list()
        self.establish_my_topic()
        self.establish_tmp_client_data()
        self.establish_recent_topic()
        self.establish_user_data()
        self.establish_ignore_list()
    }
    func remove_all_table(){
        let table_list = [
            topic_content,
            private_table,
            version_table,
            leave_topic,
            leave_topic_master,
            friend_list_table,
            black_list_table,
            my_topic,
            tmp_client_Table,
            recent_topic,
            user_data_table,
            recent_topic,
            ignore_list
        ]
        for tables in table_list{
            do{
                try sql_db?.run(tables.drop())
            }
            catch{
                print("資料庫錯誤")
                print(error)
            }
        }
    }
    func check_database_is_empty() -> Bool{
        do{
            if try (sql_db?.scalar(my_topic.count))! > 0{
                return false
            }
            else if try (sql_db?.scalar(private_table.count))! > 0{
                return false
            }
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
        
        return true
    }
    func connect_sql(){
        let urls = FileManager.default
            .urls(
                for: .documentDirectory,
                in: .userDomainMask)
        let sqlitePath = urls[urls.count-1].absoluteString
            + "sqlite3.db"
        do{
            self.sql_db = try Connection(sqlitePath)
            print("資料庫連線成功")
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
    }
    // ignore_list
    func establish_ignore_list(){
        do{
            try sql_db?.run(ignore_list.create { t in
                t.column(id, primaryKey: true)
                t.column(topic_id)
                t.column(username)
                t.column(is_send)
            })
            print("表單建立成功friend_list_table")
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
    }
    func add_ignore_list(topic_id_in:String, client_id:String){
        do{
            let insert = ignore_list.insert(
                topic_id <- topic_id_in,
                username <- client_id,
                is_send <- false
            )
            try sql_db!.run(insert)
        }
        catch{
            print("ERROR!!! add_ignore_list")
            print(error)
        }
    }
    func get_un_send_ignore_list() -> Array<Dictionary<String,String>>{
        // topic_id client_id id
        var result_list:Array<Dictionary<String,String>> = []
        let query = ignore_list.filter(is_send == false)
        do{
            for datas in try sql_db!.prepare(query){
                let temp_dic = [
                    "topic_id": datas[topic_id]!,
                    "client_id": datas[username],
                    "id_local": String(datas[id])
                ]
                result_list.append(temp_dic)
            }
            return result_list
        }
        catch{
            print("ERROR!!! get_un_send_ignore_list")
            print(error)
        }
        return []
    }
    func check_is_in_ignore_list(topic_id_in:String, client_id:String) -> Bool{
        return false
    }
    func update_ignore_list_is_send(is_send_list:Array<String>){
        var is_send_list_int64:Array<Int64> = []
        for send_id_s in is_send_list{
            is_send_list_int64.append(Int64(send_id_s)!)
        }
        let query = ignore_list.filter(is_send_list_int64.contains(id))
        let update = query.update(is_send <- true)
        do{
            try sql_db!.run(update)
        }
        catch{
            print("ERROR!!!! update_ignore_list_is_send")
            print(error)
        }
    }
    func get_ignore_topic_id_list() -> Array<String>{
        let my_topic_id_list = get_my_topics_server_id()
        let query = ignore_list.filter(!my_topic_id_list.contains(topic_id))
        var return_list:Array<String> = []
        do{
            for ignore_objs in try sql_db!.prepare(query){
                return_list.append(ignore_objs[topic_id]!)
            }
            return return_list
        }
        catch{
            print("ERROR!!! get_ignore_topic_id_list")
            print(error)
            return []
        }
    }
    func get_ignore_client_id_list() -> Dictionary<String,Array<String>>{
        var return_dic:Dictionary<String,Array<String>> = [:]
        let my_topic_id_list = get_my_topics_server_id()
        do{
            for my_topic_id_s in my_topic_id_list{
                return_dic[my_topic_id_s] = []
                let query = ignore_list.filter(topic_id == my_topic_id_s)
                for ignore_objs in try sql_db!.prepare(query){
                    return_dic[my_topic_id_s]?.append(ignore_objs[username])
                }
            }
            print(return_dic)
            return return_dic
        }
        catch{
            print("ERROR!!! get_ignore_client_id_list")
            print(error)
            return [:]
        }
        
    }
    func calculate_ignore_list(){
        let my_topic_id_list = get_my_topics_server_id()
        let topic_content_topic_ids_query = topic_content.filter(!my_topic_id_list.contains(topic_id)).select(distinct: topic_id)
        var topic_content_topic_ids_list:Array<String> = []
        do{
            for topic_content_topic_ids in try sql_db!.prepare(topic_content_topic_ids_query){
                topic_content_topic_ids_list.append(topic_content_topic_ids[topic_id]!)
            }
            if !topic_content_topic_ids_list.isEmpty{
                for topic_id_s in topic_content_topic_ids_list{
                    if !check_is_in_recent_topic(check_topic_id: topic_id_s){
                        let temp_topic_content_obj_query = topic_content.filter(topic_id == topic_id_s).order(id.asc).limit(1)
                        if try sql_db!.scalar(temp_topic_content_obj_query.count) > 0{
                            let temp_topic_content_obj = try sql_db!.prepare(temp_topic_content_obj_query).first(where: { (row) -> Bool in
                                return true
                            })
                            var client_id_ins = temp_topic_content_obj![sender]!
                            if client_id_ins == userData.id{
                                client_id_ins = temp_topic_content_obj![receiver]!
                            }
                            add_ignore_list(topic_id_in: topic_id_s, client_id: client_id_ins)
                        }
                    }
                }
            }
        }
        catch{
            print("ERROR!!! calculate_ignore_list")
            print(error)
        }
        
    }
    
    // friend_list
    func establish_friend_list(){
        do{
            try sql_db?.run(friend_list_table.create { t in
                t.column(id, primaryKey: true)
                t.column(username)
                t.column(user_full_name)
                t.column(friend_image)
                t.column(friend_image_file_name)
                t.column(tmp_client_real_pic)
                t.column(tmp_client_sex)
            })
            print("表單建立成功friend_list_table")
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
    }
    func insert_friend(input_dic:Dictionary<String,AnyObject>){
        do{
            let client_id_var = input_dic["client_id"] as! String
            if (try sql_db!.scalar(friend_list_table.filter(username == client_id_var).count)) == 0{
                // 是全新資料
                let insert = friend_list_table.insert(
                    username <- input_dic["client_id"] as! String,
                    user_full_name <- input_dic["client_name"] as! String,
                    friend_image_file_name <- input_dic["img_name"] as? String,
                    tmp_client_real_pic <- input_dic["is_real_pic"] as? Bool,
                    tmp_client_sex <- input_dic["sex"] as? String
                )
                try sql_db!.run(insert)
            }
            else{
                let target_obj = try sql_db!.prepare(friend_list_table.filter(username == client_id_var)).first(where: { (row) -> Bool in
                    return true
                })
                if (input_dic["client_name"] as! String) != target_obj![user_full_name]{
                    try sql_db!.run(friend_list_table.filter(username == client_id_var).update(user_full_name <- input_dic["client_name"] as! String))
                }
                if (input_dic["img_name"] as! String) != target_obj![friend_image_file_name]{
                    try sql_db!.run(friend_list_table.filter(username == client_id_var).update(
                        friend_image_file_name <- input_dic["img_name"] as? String,
                        friend_image <- nil
                    ))
                }
            }
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
        
    }
    func update_friend_img(username_in:String,img:String,img_name:String){
        do{
            let query = friend_list_table.filter(username == username_in)
            let update = query.update(
                friend_image <- img,
                friend_image_file_name <- img_name
            )
            try sql_db?.run(update)
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
    }
    func update_friend_full_name(username_in:String, user_full_name_in:String){
        do{
            let query = friend_list_table.filter(username == username_in)
            let update = query.update(user_full_name <- user_full_name_in)
            try sql_db?.run(update)
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
    }
    func check_friend_id(username_in:String) -> Bool{
        do{
            let query = friend_list_table.filter(
                username == username_in
            )
            if (try sql_db?.scalar(query.count)) != nil{
                return true
            }
            return false
        }
        catch{
            print("資料庫錯誤")
            print(error)
            return false
        }
    }
    func check_friend_name(username_in:String, user_full_name_in:String) -> Bool{
        do{
            let query = friend_list_table.filter(
                username == username_in
            )
            if let user_data = try sql_db?.prepare(query).first(where: { (roe) -> Bool in
                return true
            }){
                if user_data[user_full_name] == user_full_name_in{
                    return true
                }
            }
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
        return false
    }
    func check_friend_image_name(username_in:String,img_name:String) -> Bool{
        do{
            let query = friend_list_table.filter(
                username == username_in
            )
            let data = try sql_db!.prepare(query).first(where: { (row) -> Bool in
                return true
            })
            if data != nil{
                let img_name_db = data?[friend_image_file_name]
                if img_name_db == img_name{
                    return true
                }
            }
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
        return false
    }
    func remove_friend(username_in:String){
        do{
            let query = friend_list_table.filter(username == username_in)
            try sql_db!.run(query.delete())
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
        
    }
    func get_friend_list() -> Array<Dictionary<String,AnyObject>>{
        do{
            var return_list:Array<Dictionary<String,AnyObject>> = []
            let black_list = get_black_list()
            print(black_list)
            let query = friend_list_table.filter(!black_list.contains(username))
            for friend_datas in try sql_db!.prepare(query){
                print(friend_datas[username])
                var temp_dic:Dictionary<String,AnyObject> = [
                    "client_id": friend_datas[username] as AnyObject,
                    "client_name": friend_datas[user_full_name] as AnyObject,
                    "sex": friend_datas[tmp_client_sex]! as AnyObject,
                    "isRealPhoto": friend_datas[tmp_client_real_pic]! as AnyObject,
                    "img_name": friend_datas[friend_image_file_name] as AnyObject
                ]
                let private_msg_query = private_table.filter(
                    sender == friend_datas[username] ||
                    receiver == friend_datas[username]
                ).order(id.desc)
                if let private_msg_obj = try sql_db!.prepare(private_msg_query).first(where: { (row) -> Bool in
                    return true
                }){
                    temp_dic["lastLine"] = private_msg_obj[private_text]! as AnyObject
                    temp_dic["last_speaker"] = private_msg_obj[sender]! as AnyObject
                    temp_dic["time"] = private_msg_obj[time]! as AnyObject
                    temp_dic["is_read"] = private_msg_obj[is_read]! as AnyObject
                    if private_msg_obj[sender]! == userData.id{
                        temp_dic["last_speaker_name"] = userData.name! as AnyObject?
                    }
                    else{
                        temp_dic["last_speaker_name"] = friend_datas[user_full_name] as AnyObject?
                    }
                }
                if friend_datas[friend_image] != nil{
                    temp_dic["img"] = friend_datas[friend_image]! as AnyObject
                }
                return_list.append(temp_dic)
            }
            return return_list
        }
        catch{
            print("get_friend_list ERROR")
            print(error)
        }
        return []
    }
    
    
    
    // black_list
    func establish_black_list(){
        do{
            try sql_db?.run(black_list_table.create { t in
                t.column(id, primaryKey: true)
                t.column(username, unique:true)
                t.column(is_send)
            })
            print("表單建立成功")
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
    }
    func insert_black_list(username_in:String){
        do{
            let insert = black_list_table.insert(
                username <- username_in,
                is_send <- false
            )
            try sql_db!.run(insert)
        }
        catch{
            print("資料庫錯誤insert_black_list")
            print(error)
        }
    }
    func insert_black_list_from_server(username_in:String){
        do{
            let insert = black_list_table.insert(
                username <- username_in,
                is_send <- true
            )
            try sql_db!.run(insert)
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
    }
    func get_black_list() -> Array<String>{
        var return_list:Array<String> = []
        do{
            for names in try sql_db!.prepare(black_list_table) {
                return_list.append(names[username])
            }
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
        return return_list
    }
    func get_un_send_block_list() -> Array<String>{
        var return_list:Array<String> = []
        let query = black_list_table.filter(is_send == false)
        do{
            for names in try sql_db!.prepare(query) {
                return_list.append(names[username])
            }
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
        return return_list
    }
    func remove_black(username_in:String){
        do{
            let query = black_list_table.filter(username == username_in)
            try sql_db!.run(query.delete())
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
    }
    func ckeck_user_is_blocked(client_id_in:String) -> Bool{
        do{
            let query = black_list_table.filter(username == client_id_in)
            if let query_count = try sql_db?.scalar(query.count){
                if query_count == 0{
                    return false
                }
                else{
                    return true
                }
            }
            else{
                return false
            }
        }
        catch{
            print("ERROR!!! ckeck_user_is_blocked")
            print(error)
            return false
        }
    }
    func update_is_send_data(success_list:Array<String>){
        do{
            for client_id_s in success_list{
                let query = black_list_table.filter(username == client_id_s)
                let update = query.update(is_send <- true)
                try sql_db!.run(update)
            }
        }
        catch{
            print("ERROR!!! update_is_send_data")
            print(error)
        }
    }
    func print_block(){
        do{
            print("---print_block----")
            for c in try sql_db!.prepare(black_list_table){
                print(c[username])
            }
            
        }
        catch{
            //pass
        }
    }
    
    // mytopic
    func establish_my_topic(){
        do{
            try sql_db?.run(my_topic.create { t in
                t.column(id, primaryKey: true)
                t.column(topic_title)
                t.column(topic_id)
                t.column(is_send) // 開房有沒有開成功
                t.column(tags)
                t.column(active) // 是否準備關房  ＝false就是要關了  關成功整筆資料會殺掉
            })
            print("表單建立成功")
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
    }
    func insert_my_topic_from_server(topic_id_in:String,topic_title_in:String){
        do{
            let insert = my_topic.insert(
                topic_id <- topic_id_in,
                topic_title <- topic_title_in,
                is_send <- true,
                active <- true
            )
            try sql_db?.run(insert)
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
        
    }
    func insert_my_topic_from_local(topic_title_in:String,topic_tag_string_in:String) -> String?{
        do{
            let insert = my_topic.insert(
                topic_title <- topic_title_in,
                is_send <- false,
                tags <- topic_tag_string_in,
                active <- true
            )
            try sql_db!.run(insert)
            let query = my_topic.order(id.desc).limit(1)
            if let query_s = try sql_db!.prepare(query).first(where: { (row) -> Bool in
                return true
            }){
                return String(describing: query_s[id])
            }
            
        }
        catch{
            print("sql error")
            print(error)
        }
        return nil
    }
    func updata_my_topic_id(topic_id_in:String,id_local:String){
        do{
            let id_local_int = Int64(id_local)!
            let query = my_topic.filter(id == id_local_int)
            let update = query.update(topic_id <- topic_id_in)
            try sql_db!.run(update)
        }
        catch{
            print("sql error")
            print(error)
        }
    }
    func update_my_topic(local_topic_id_in:String,topic_id_in:String){
        do{
            let query = my_topic.filter(id == Int64(Int(local_topic_id_in)!))
            let update = query.update(topic_id <- topic_id_in)
            try sql_db?.run(update)
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
    }
    func delete_all_my_topic(){
        do{
            try sql_db!.run(my_topic.delete())
        }
        catch{
            print("sql error")
            print(error)
        }
    }
    func turn_my_topic_active_state_to_false(topic_id_ins:String){
        let query = my_topic.filter(topic_id == topic_id_ins)
        let update = query.update(active <- false)
        do{
            try sql_db!.run(update)
        }
        catch{
            print("ERROR turn_my_topic_active_state_to_false")
            print(error)
        }
    }
    func delete_my_topic(local_id:String?,topic_id_in:String?){
        do{
            if local_id != nil{
                let query = my_topic.filter(id == Int64(Int(local_id!)!))
                let del = query.delete()
                try sql_db?.run(del)
            }
            else if topic_id_in != nil{
                let query = my_topic.filter(topic_id == topic_id_in!)
                let del = query.delete()
                try sql_db?.run(del)
            }
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
    }
    func delete_my_topic_by_list(topic_id_list:Array<String>){
        let query = my_topic.filter(topic_id_list.contains(topic_id))
        do{
            try sql_db!.run(query.delete())
        }
        catch{
            print("ERROR delete_my_topic_by_list")
            print(error)
        }
    }
    func get_inactive_my_topic() -> Array<String>{
        let query = my_topic.filter(active == false)
        var return_list:Array<String> = []
        do{
            for datas in try sql_db!.prepare(query){
                return_list.append(datas[topic_id]!)
            }
        }
        catch{
            print("ERROR!! get_inactive_my_topic")
        }
        return return_list
    }
    func check_old_topic_count() -> Int{
        do{
            return try sql_db!.scalar(my_topic.count)
        }
        catch{
            print("database error")
            print(error)
        }
        return 0
    }
    func check_is_in_mytopic(check_topic_id:String) -> Bool{
        do{
            let query = my_topic.filter(topic_id == check_topic_id)
            if try sql_db!.scalar(query.count) > 0 {
                return true
            }
            return false
        }
        catch{
            print("insert_recent_topic資料庫錯誤")
            print(error)
            return false
        }
    }
    func get_my_topic_detial_for_title_cell(topic_id_in:String) -> Dictionary<String,AnyObject>{
        do{
            // 對照輸入的話題id，確認自己的話題存在，取得自己話題標題
            let query = my_topic.filter(topic_id == topic_id_in)
            // 確認自己的話題存在，取得自己話題「標題＃1」(因為這裡只能輸入一個話題id，所以用.first，之後可能可以改複數變成用for?
            if let myTopicRow = try sql_db!.prepare(query).first(where: { (row) -> Bool in
                return true
            }){
                // 每個「我的」cell最後一句是否要橘色<跟誰的對話，有沒有已讀> #2
                var highLightDict:Dictionary<String,Dictionary<String,Bool>> = [:]
                // 輸入話題ID,取得一個字典是跟誰的對話，還有最後一句話的狀態
                let lastLine = get_last_line(topic_id_in: topic_id_in)
                // eachLastLine = 指定話題id之後，遍歷每一個cell
                for eachLastLine in lastLine!{
                    // 如果最後一句話不是自己的，而且還沒有已讀 -> <跟誰的對話，沒已讀>
                    if eachLastLine.value["sender"] as? String != userData.id &&
                        eachLastLine.value["is_read"]as!Bool == false{
                        highLightDict[eachLastLine.key] = ["read":false]
                    }
                    // 如果最後一句話不是自己的，而且還沒有已讀 -> <跟誰的對話，已讀>
                    else if eachLastLine.value["sender"]as?String != userData.id &&
                        eachLastLine.value["is_read"]as!Bool == true{
                        highLightDict[eachLastLine.key] = ["read":true]
                    }
                    // 如果最後一句話是自己的 -> <跟誰的對話，已讀>
                    else if eachLastLine.value["sender"]as?String == userData.id{
                        highLightDict[eachLastLine.key] = ["read":true]
                    }
                }
                // 從已經取得的Row提出tag純文字，再轉成清單 ＃3
                var myTopicTags:Array<String> = []
                if myTopicRow[tags] != nil{
                    myTopicTags = turn_tag_string_to_tag_list(tag_string: myTopicRow[tags]!)
                }
                
                
                let returnDict:Dictionary<String,AnyObject> = [
                    "topic_title":myTopicRow[topic_title] as AnyObject,
                    "topics":highLightDict as AnyObject,
                    "hash_tag":myTopicTags as AnyObject
                ]
                return returnDict
            }
            
        }
        catch{
            print("get_my_topic_detial 錯誤")
            print(error)
        }
        return [:]
    }
        // 此函數輸出三份字典，目的在取得「我的話題清單」cell需要顯示的資料，輸入的資料為該話題ID
        // 輸出要「話題標題#1」、「每個對話cell對方已讀了沒#2」、「hashtag#3」
    func get_my_topics_server_id() -> Array<String>{
        var return_list:Array<String> = []
        do{
            for topic_s in try sql_db!.prepare(my_topic){
                if let topic_id = topic_s[topic_id]{
                    return_list.append(topic_id)
                }
            }
            if !return_list.isEmpty{
                return return_list
            }
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
        print("沒有自己的話題")
        return return_list
    }
        // 取得自己的話題在伺服器上的id
    func get_all_badges() -> Dictionary<String,String>{
        let friendBagdes = String(get_friend_badges())
        let myTopicBadges = String(get_myTopic_badges())
        let recentBadge = String(get_recent_badges())
        let return_dic:Dictionary<String,String> = [
            "my_topic_badge":myTopicBadges,
            "recent_badge":recentBadge,
            "friend_badge":friendBagdes
        ]
        return return_dic
    }
        // 取的所有的 BADGE 由三個分開的 func 整理成純文字
    
    
    // recent_topic
    func establish_recent_topic(){
        do{
            try sql_db?.run(recent_topic.create { t in
                t.column(id, primaryKey: true)
                t.column(topic_title)
                t.column(topic_id, unique: true)
                t.column(client_id)
                t.column(tags)
                t.column(active)
            })
            print("表單建立成功")
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
    }
    func insert_recent_topic(input_dic:Dictionary<String,String?>){
        let insert = recent_topic.insert(
            topic_title <- input_dic["topic_title"]!,
            topic_id <- input_dic["topic_id"]!,
            client_id <- input_dic["client_id"]!,
            tags <- input_dic["tags"]!,
            active <- true
        )
        do{
            try sql_db?.run(insert)
        }
        catch{
            print("insert_recent_topic資料庫錯誤")
            print(error)
        }
    }
    func check_is_in_recent_topic(check_topic_id:String) -> Bool{
        do{
            let query = recent_topic.filter(topic_id == check_topic_id)
            if try sql_db!.scalar(query.count) > 0 {
                return true
            }
            return false
        }
        catch{
            print("check_is_in_recent_topic資料庫錯誤")
            print(error)
            return false
        }
    }
    func get_recent_topic_list() -> Array<String>{
        var recent_topic_list:Array<String> = []
        do{
            for topic_ids in try sql_db!.prepare(recent_topic){
                recent_topic_list.append(topic_ids[topic_id]!)
            }
            return recent_topic_list
        }
        catch{
            print("ERROR!!! get_recent_topic_list")
            print(error)
        }
        return []
    }
    func get_recent_last_line() -> Dictionary<String,AnyObject>{
        do{
            let black_list = get_black_list()   
            var return_dic:Dictionary<String,AnyObject> = [:]
            //let ignore_topic_list = get_ignore_topic_id_list()
            let recent_topic_list = get_recent_topic_list()
            
            //let my_topic_id_list = get_my_topics_server_id()
            let query_recent_topic_list_v2 = topic_content.filter(
                    recent_topic_list.contains(topic_id)
                ).select(distinct: topic_id)
            for recent_datas in try sql_db!.prepare(query_recent_topic_list_v2){
                let query = topic_content.filter(
                    topic_id == recent_datas[topic_id]! &&
                    !black_list.contains(sender) &&
                    !black_list.contains(receiver)
                )
                if let topic_content_obj = try sql_db!.prepare(query.order(id.desc).limit(1)).first(where: { (row) -> Bool in
                    return true
                }){
                    if check_is_in_recent_topic(check_topic_id: topic_content_obj[topic_id]!){
                        var client_id_ins = userData.id!
                        if topic_content_obj[sender]! == client_id_ins{
                            client_id_ins = topic_content_obj[receiver]!
                        }
                        let level = get_level(topic_id_in: recent_datas[topic_id]!, client_id: client_id_ins)
                        let recent_topic_query = recent_topic.filter(topic_id == recent_datas[topic_id]!).limit(1)
                        var tag_list_ins:Array<String> = []
                        var topic_title_ins = ""
                        if let recent_topic_query_result = try sql_db!.prepare(recent_topic_query).first(where: { (row) -> Bool in
                            return true
                        }){
                            // working
                            tag_list_ins = turn_tag_string_to_tag_list(tag_string: recent_topic_query_result[tags]!)
                            topic_title_ins = recent_topic_query_result[topic_title]!
                        }
                        print ("tag_list_ins-----------")
                        print (tag_list_ins)
                        print (topic_title_ins)
                        var temp_dic:Dictionary<String,AnyObject> = [
                            "owner": client_id_ins as AnyObject,
                            "last_line": topic_content_obj[topic_text]! as AnyObject,
                            "topic_content_id": String(topic_content_obj[id]) as AnyObject,
                            "last_speaker": topic_content_obj[sender]! as AnyObject,
                            "is_read": topic_content_obj[is_read]! as AnyObject,
                            "tag_list": tag_list_ins as AnyObject,
                            "topic_title": topic_title_ins as AnyObject,
                            "time": topic_content_obj[time] as AnyObject,
                            "level": String(level) as AnyObject
                        ]
                        
                        if let temp_data = tmp_client_search(searchByClientId: recent_datas[topic_id]!, level: level){
                            temp_dic["owner_name"] = temp_data["client_name"]
                            temp_dic["owner_is_real_img"] = temp_data["is_real_pic"]
                            temp_dic["owner_sex"] = temp_data["sex"]
                            temp_dic["img"] = temp_data["img"]
                        }
                        return_dic[recent_datas[topic_id]!] = temp_dic as AnyObject
                    }
                    
                }
            }
            return return_dic
        }
        catch{
            print("get_recent_last_line資料庫錯誤")
            print(error)
        }
        return [:]
    }
    func delete_recent_topic(topic_id_in:String){
        do{
            let update = recent_topic.filter(topic_id == topic_id_in).update(active <- false)
            try sql_db!.run(update)
            HttpRequestCenter().send_delete_recent_topic()
        }
        catch{
            print("delete_recent_topic資料庫錯誤")
            print(error)
        }
    }
    func get_unsend_recent_topic_list() -> Array<String>{
        let query = recent_topic.filter(active == false)
        var return_list:Array<String> = []
        do{
            for datas in try sql_db!.prepare(query){
                return_list.append(datas[topic_id]!)
            }
            return return_list
        }
        catch{
            print("ERROR get_unsend_recent_topic_list")
            print(error)
        }
        return []
    }
    func delete_recent_topic_complete(return_recent_topic_list:Array<String>){
        let query = recent_topic.filter(return_recent_topic_list.contains(topic_id))
        do{
            try sql_db!.run(query.delete())
        }
        catch{
            print("ERROR delete_recent_topic_complete")
            print(error)
        }
    }
    func print_recent_db(){
        do{
            print("========================")
            for c in try sql_db!.prepare(recent_topic){
                print(c[topic_title])
            }
            print("=====================")
        }
        catch{
            
        }
    }

    // 取得自己話題的badge數
    func get_myTopic_badges() -> Int{
        let myTopicIds:Array<String> = get_my_topics_server_id()
        let black_list:Array<String> = get_black_list()
        let my_topic_ignore_client_id_dic = get_ignore_client_id_list()
        var query_count = 0
        do{
            // 抓所有的MyTopic的topic_id
            if userData.id != nil{
                for myTopId in myTopicIds{
                    let query = topic_content.filter(
                        topic_id == myTopId &&
                            sender != userData.id &&
                            is_read == false &&
                            black_list.contains(sender) == false &&
                            my_topic_ignore_client_id_dic[myTopId]!.contains(sender) == false
                        )
                    query_count += (try sql_db?.scalar(query.count))!
                }
            }
            return query_count
        }
        catch{
            print("get_myTopic_badges錯誤")
            print(error)

        }
        return 0
    }
    
    // leave_topic
//    func establish_leave_topic_table(){
//        do{
//            try sql_db?.run(leave_topic.create { t in
//                t.column(id, primaryKey: true)
//                t.column(topic_id)
//            })
//            print("表單建立成功")
//        }
//        catch{
//            print("資料庫錯誤")
//            print(error)
//        }
//    }
//    func add_topic_to_topic_table(topic_id_input:String){
//        let insert = leave_topic.insert(
//            topic_id <- topic_id_input
//        )
//        do{
//            try sql_db!.run(insert)
//        }
//        catch{
//            print("資料庫錯誤")
//            print(error)
//        }
//    }
//    func remove_topic_from_topic_table(topic_id_input:String){
//        let query = leave_topic.filter(topic_id == topic_id_input)
//        
//        do{
//            try sql_db!.run(query.delete())
//        }
//        catch{
//            print("資料庫錯誤")
//            print(error)
//        }
//    }
//    func get_topic_table_list() -> Array<String>{
//        var return_list:Array<String> = []
//        do{
//            for topic_c in try sql_db!.prepare(leave_topic) {
//                return_list.append(topic_c[topic_id]!)
//            }
//        }
//        catch{
//            print("資料庫錯誤")
//            print(error)
//        }
//        return return_list
//    }
//    func print_topic_table(){
//        print("print_topic_table=====op")
//        do{
//            for topic_c in try sql_db!.prepare(leave_topic) {
//                print("topic_id: \(topic_c[topic_id])")
//                // id: 1, email: alice@mac.com, name: Optional("Alice")
//            }
//            print("print_topic_table=====ed")
//        }
//        catch{
//            print("資料庫錯誤")
//            print(error)
//        }
//    }
    
    
    // leave_topic_master
//    func establish_leave_topic_master_table(){
//        do{
//            try sql_db?.run(leave_topic_master.create { t in
//                t.column(id, primaryKey: true)
//                t.column(topic_id)
//                t.column(client_id)
//            })
//            print("表單建立成功")
//        }
//        catch{
//            print("資料庫錯誤")
//            print(error)
//        }
//    }
//    func add_topic_to_leave_topic_master_table(topic_id_input:String, client_id_input:String){
//        let insert = leave_topic_master.insert(
//            topic_id <- topic_id_input,
//            client_id <- client_id_input
//        )
//        do{
//            try sql_db!.run(insert)
//        }
//        catch{
//            print("資料庫錯誤")
//            print(error)
//        }
//    }
//    func remove_topic_from_leave_topic_master_table(topic_id_input:String, client_id_input:String){
//        let query = leave_topic_master.filter(topic_id == topic_id_input && client_id == client_id_input)
//        
//        do{
//            try sql_db!.run(query.delete())
//        }
//        catch{
//            print("資料庫錯誤")
//            print(error)
//        }
//    }
//    func get_leave_topic_master_table_list() -> Array<Dictionary<String,String>>{
//        var return_list:Array<Dictionary<String,String>> = []
//        do{
//            for topic_c in try sql_db!.prepare(leave_topic_master) {
//                let temp_dic:Dictionary<String,String> = [
//                    "topic_id":topic_c[topic_id]!,
//                    "client_id":topic_c[client_id]!
//                ]
//                return_list.append(temp_dic)
//            }
//        }
//        catch{
//            print("資料庫錯誤")
//            print(error)
//        }
//        return return_list
//    }
    
    
    // private func
    func establish_private_msg_table(){
        do{
            try sql_db?.run(private_table.create { t in
                t.column(id, primaryKey: true)
                t.column(private_text)
                t.column(sender)
                t.column(receiver)
                t.column(time)
                t.column(is_read)
                t.column(is_send)
                t.column(id_server)
            })
            print("表單建立成功")
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
    }
    func check_private_msg_type(input_dic:Dictionary<String,AnyObject>) -> String{
        if input_dic["id_server"] != nil && input_dic["id_server"]! as! String != "0"{
            if input_dic["id_local"] != nil && input_dic["id_local"]! as! String != "0"{
                //                let query = private_table.filter(
                //                    id == Int64(input_dic["id_local"]! as! String)! &&
                //                    sender == userData.id
                //                )
                let query_server_id = private_table.filter(
                    id_server == input_dic["id_server"]! as? String
                )
                do{
                    let count_server = try sql_db!.scalar(query_server_id.count)
                    //let count = try sql_db!.scalar(query.count)
                    if count_server > 0{
                        return "old_data"
                    }
                }
                catch{
                    print("資料庫錯誤")
                    print(error)
                }
                if input_dic["sender"]! as! String == userData.id!{
                    return "update_local"
                }
                return "new_server_msg"
            }
            else{
                let query = private_table.filter(
                    id_server == input_dic["id_server"]! as? String
                )
                do{
                    let count = try sql_db!.scalar(query.count)
                    if count > 0{
                        return "old_data"
                    }
                }
                catch{
                    print("資料庫錯誤")
                    print(error)
                }
                return "new_server_msg"
            }
        }
        else{
            return "new_local_msg"
        }
    }
    func print_all2(){
        if print_part_log_switch{
            do{
                for topic_c in try sql_db!.prepare(private_table) {
                    print("id_s: \(topic_c[id_server]), id_l: \(topic_c[id]), re: \(topic_c[receiver]!), se:\(topic_c[sender]!) , is_s:\(topic_c[is_send]) , is_r\(topic_c[is_read]) ms: \(topic_c[private_text])")
                    // id: 1, email: alice@mac.com, name: Optional("Alice")
                }
                print("========")
            }
            catch{
                print("資料庫錯誤")
                print(error)
                
            }
        }
        
    }
    func get_friend_badges() -> Int{
        let black_list:Array<String> = get_black_list()
        do{
            if userData.id != nil{
            let query = private_table.filter(
                sender != userData.id &&
                is_read == false &&
                black_list.contains(sender) == false
                )
                let query_count = try sql_db?.scalar(query.count)
                return query_count!
            
                }
            }
        catch{
            print("get_friend_badges錯誤")
            print(error)
            
        }
        return 0
    }
    func check_private_msg_type2(input_dic:Dictionary<String,AnyObject>) -> String{
        if input_dic["id_server"] != nil && input_dic["id_server"]! as! String != "0"{
            let query_id_server = private_table.filter(id_server == input_dic["id_server"]! as? String)
            //let query_id_local = private_table.filter(id == Int64(input_dic["id_local"]! as! String)! && sender == userData.id)
            do{
                let count_id_server = try sql_db!.scalar(query_id_server.count)
                //let count_id_local = try sql_db!.scalar(query_id_local.count)
                if count_id_server != 0{
                    return "old_data"
                }
                return "new_server_msg"
            }
            catch{
                print("資料庫錯誤")
                print(error)
                return "old_data"
            }
        }
        else{
            return "new_local_msg"
        }
    }
    // working (暫緩 好像目前沒問題)我的client的訊息分開寫入  改成兩個函數
    func inser_date_to_private_msg(input_dic:Dictionary<String,AnyObject>){
        do{
            let topic_msg_type = check_private_msg_type2(input_dic: input_dic)
            print ("topic_msg_type: \(topic_msg_type)")
            if topic_msg_type == "update_local"{
                let id_local_input = Int64(input_dic["id_local"]! as! String)!
                let query = private_table.filter(
                        id == id_local_input
                )
                let time_string = input_dic["time"]! as! String
                let time_input = time_transform_to_since1970(time_string:time_string)
                try sql_db?.run(query.update(
                    time <- time_input,
                    is_send <- true,
                    is_read <- input_dic["is_read"]! as? Bool,
                    id_server <- input_dic["id_server"]! as? String
                ))
            }
            else if topic_msg_type == "old_data"{
                //pass
            }
            else{
                var id_server_input:String?
                var is_read_input:Bool?
                var is_send_input:Bool?
                var time_input:TimeInterval?
                
                if topic_msg_type == "new_server_msg"{
                    id_server_input = input_dic["id_server"]! as? String
                    is_read_input = input_dic["is_read"]! as? Bool
                    is_send_input = true
                    let time_string = input_dic["time"]! as! String
                    time_input = time_transform_to_since1970(time_string:time_string)
                }
                else{
                    // new_local_msg
                    is_read_input = false
                    is_send_input = false
                    time_input = Date().timeIntervalSince1970
                    
                }
                let insert = private_table.insert(
                    private_text <- input_dic["private_text"]! as? String,
                    sender <- input_dic["sender_id"]! as? String,
                    receiver <- input_dic["receiver_id"]! as? String,
                    time <- time_input,
                    is_read <- is_read_input,
                    is_send <- is_send_input,
                    id_server <- id_server_input
                )
                try sql_db!.run(insert)
                //print("寫入資料成功")
            }
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
        //self.print_all()
    }
    func get_unsend_private_data(client_id:String) -> Array<NSDictionary>?{
        do{
            let query = private_table.filter(
                (sender == userData.id! && receiver == client_id) ||
                    (sender == client_id && receiver == userData.id!)
                ).filter(is_send == false).order(id.asc)
            var return_list:Array<NSDictionary> = []
            for query_s in try sql_db!.prepare(query) {
                let dict_unit:NSDictionary = [
                    "msg_type": "priv_msg",
                    "private_text": query_s[private_text]!,
                    "receiver": query_s[receiver]!,
                    "id_local": String(query_s[id]),
                    ]
                return_list.append(dict_unit)
            }
            return return_list
        }
        catch{
            print("資料庫錯誤")
            print(error)
            return nil
        }
    }
    func get_private_msg_last_id_server(client_id_input:String) -> String{
        let query = private_table.filter(
                id_server != nil &&
                (receiver == userData.id! && sender == client_id_input)
            ).order(time.desc).limit(1)
        do{
            for query_s in try sql_db!.prepare(query){
                return query_s[id_server]!
            }
            return "0"
        }
        catch{
            print("資料庫錯誤")
            print(error)
            return "0"
        }
    }
    func get_private_histopry_msg(client_id:String) -> Array<Dictionary<String,AnyObject>>{
        let query = private_table.filter(
            (sender == userData.id! && receiver == client_id) ||
                (sender == client_id && receiver == userData.id!)
            ).order(time.asc)
        var return_list:Array<Dictionary<String,AnyObject>> = []
        do{
            let query_server = query.filter(id_server != nil)
            for query_s in try sql_db!.prepare(query_server){
                var is_resd_input = false
                if query_s[is_read] != nil{
                    is_resd_input = query_s[is_read]!
                }
                let id_local:Int64 = query_s[id]
                let write_time:Double = query_s[time]!
                let return_dic:Dictionary<String,AnyObject> = [
                    "sender":query_s[sender]! as AnyObject,
                    "private_text":query_s[private_text]! as AnyObject,
                    "is_read":is_resd_input as AnyObject,
                    "is_send":query_s[is_send] as AnyObject,
                    "write_time":write_time as AnyObject,
                    "id_local":id_local as AnyObject,
                    "id_server":query_s[id_server] as AnyObject
                    ]
                return_list.append(return_dic)
                if query_s[sender]! != userData.id{
                    // update private msg to readed
                    let query_s_local_id = query_s[id]
                    let update = private_table.filter(id == query_s_local_id).update(is_read <- true)
                    try sql_db!.run(update)
                }
            }
            let query_local = query.filter(id_server == nil)
            for query_s in try sql_db!.prepare(query_local){
                var is_resd_input = false
                if query_s[is_read] != nil{
                    is_resd_input = query_s[is_read]!
                }
                let id_local:Int64 = query_s[id]
                let write_time:Double = query_s[time]!
                let return_dic:Dictionary<String,AnyObject> = [
                    "sender":query_s[sender]! as AnyObject,
                    "private_text":query_s[private_text]! as AnyObject,
                    "is_read":is_resd_input as AnyObject,
                    "is_send":query_s[is_send] as AnyObject,
                    "write_time":write_time as AnyObject,
                    "id_local":id_local as AnyObject
                    ]
                return_list.append(return_dic)
            }
            return return_list
        }
        catch{
            print("資料庫錯誤")
            print(error)
            return []
        }
        
    }
    func update_private_msg_time(id_local:String,time_input:String,id_server_input:String){
        do{
            let date = time_transform_to_since1970(time_string: time_input)
            let id_local_int = Int64(id_local)
            let query = private_table.filter(id == id_local_int!)
            try sql_db?.run(query.update(time <- date, is_send <- true, id_server <- id_server_input))
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
    }
    func update_private_msg_read(id_local:String){
        do{
            let id_local_int = Int64(id_local)
            let query = private_table.filter(id == id_local_int!)
            let private_table_obj = try sql_db?.prepare(query).first(where: { (row) -> Bool in
                return true
            })
            if private_table_obj != nil{
                let receiver_input = private_table_obj![receiver]!
                let query2 = private_table.filter(
                    sender == userData.id! &&
                        receiver == receiver_input &&
                        is_read == false
                )
                try sql_db?.run(query2.update(is_read <- true))
            }
            
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
        
    }
    func get_private_msg_last_checked_server_id() -> String{
        do{
            let query = private_table.filter(receiver == userData.id!).order(id.desc)
            if let private_msg_obj = try sql_db!.prepare(query).first(where: { (row) -> Bool in
                return true
            }){
                return private_msg_obj[id_server]!
            }
            return "0"
        }
        catch{
            print("get_private_msg_last_checked_server_id ERROR")
            print(error)
            return "0"
        }
    }
    
    
    // topic content func
    func establish_topic_content_table(){
        do{
            try sql_db?.run(topic_content.create { t in
                t.column(id, primaryKey: true)
                t.column(topic_id)
                t.column(topic_text)
                t.column(sender)
                t.column(receiver)
                t.column(time)
                t.column(is_read)
                t.column(is_send)
                t.column(id_server)
                t.column(battery)
            })
            print("表單建立成功")
            init_sql = true
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
    }
    func check_topic_msg_type(input_dic:Dictionary<String,AnyObject>) -> String{
        if (input_dic["id_server"] != nil && input_dic["id_server"]! as! String != "0"){
            let query_id_server = topic_content.filter(id_server == input_dic["id_server"]! as? String)
            let query_id_local = topic_content.filter(id == Int64(input_dic["id_local"]! as! String)! && sender == userData.id)
            do{
                let count_id_server = try sql_db!.scalar(query_id_server.count)
                let count_id_local = try sql_db!.scalar(query_id_local.count)
                if count_id_server != 0{
                    return "old_data"
                }
                else if (count_id_local != 0 && input_dic["sender"] != nil && input_dic["sender"]! as! String == userData.id!){
                    return "old_data"
                }
                return "new_server_msg"
            }
            catch{
                print("資料庫錯誤")
                print(error)
                return "old_data"
            }
        }
        else{
            return "new_local_msg"
        }
        
    }
    func inser_date_to_topic_content(input_dic:Dictionary<String,AnyObject>){
        do{
            let topic_msg_type = check_topic_msg_type(input_dic: input_dic)
            if topic_msg_type == "update_local"{
                let id_local_input = Int64(input_dic["id_local"]! as! String)!
                let query = topic_content.filter(
                    topic_id == input_dic["topic_id"]! as? String &&
                    id == id_local_input
                )
                let time_string = input_dic["time"]! as! String
                let time_input = time_transform_to_since1970(time_string:time_string)
                try sql_db?.run(query.update(
                    time <- time_input,
                    is_send <- true,
                    is_read <- input_dic["is_read"]! as? Bool,
                    id_server <- input_dic["id_server"]! as? String
                ))
            }
            else if topic_msg_type == "old_data"{
                //pass
            }
            else{
                //new
                var id_server_input:String?
                var is_read_input:Bool?
                var is_send_input:Bool?
                var time_input:TimeInterval?
                var insert_switch = true
                if topic_msg_type == "new_server_msg"{
                    id_server_input = input_dic["id_server"]! as? String
                    is_read_input = input_dic["is_read"]! as? Bool
                    is_send_input = true
                    let time_string = input_dic["time"]! as! String
                    time_input = time_transform_to_since1970(time_string:time_string)
                    insert_switch = check_id_server(id_server_input: id_server_input!)
                }
                else{
                    // new_local_msg
                    is_read_input = false
                    is_send_input = false
                    time_input = Date().timeIntervalSince1970
                    
                }
                if insert_switch{
                    let insert = topic_content.insert(
                        topic_id <- input_dic["topic_id"]! as? String,
                        topic_text <- input_dic["topic_content"]! as? String,
                        sender <- input_dic["sender"]! as? String,
                        receiver <- input_dic["receiver"]! as? String,
                        time <- time_input,
                        is_read <- is_read_input,
                        is_send <- is_send_input,
                        id_server <- id_server_input,
                        battery <- input_dic["battery"] as? String
                    )
                    try sql_db!.run(insert)
                }
                
                //print("寫入資料成功")
            }
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
        //self.print_all()
    }
    enum Check_state:NSNumber{
        case checked = 1
        case uncheck = 0
    }
    func insert_client_topic_content_from_server(input_dic:Dictionary<String,AnyObject>,check_state:Check_state){
        do{
            let id_server_input = input_dic["id_server"]! as! String
            let filter = topic_content.filter(id_server == id_server_input)
            let count = try sql_db!.scalar(filter.count)
            if count == 0{
                let time_in = time_transform_to_since1970(time_string: input_dic["time"]! as! String)
                let insert = topic_content.insert(
                    topic_id <- input_dic["topic_id"]! as? String,
                    topic_text <- input_dic["topic_content"]! as? String,
                    sender <- input_dic["sender"]! as? String,
                    receiver <- input_dic["receiver"]! as? String,
                    time <- time_in,
                    is_read <- input_dic["is_read"] as? Bool,
                    is_send <- Bool(check_state.rawValue),
                    id_server <- input_dic["id_server"]! as? String
                    //battery <- input_dic["battery"] as? String
                )
                try sql_db!.run(insert)
            }
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
        // MARK:test print
        print_part_topic_content()
    }
    enum Topic_content_insert_option:String{
        case new_msg = "new_msg"
        case sended = "sended"
        case readed = "readed"
        case server = "server"
    }
    func insert_self_topic_content(input_dic:Dictionary<String,AnyObject>,option:Topic_content_insert_option){
        do{
            if option.rawValue == "new_msg"{
                let insert = topic_content.insert(
                    topic_id <- input_dic["topic_id"]! as? String,
                    topic_text <- input_dic["topic_content"]! as? String,
                    sender <- input_dic["sender"]! as? String,
                    receiver <- input_dic["receiver"]! as? String,
                    time <- Date().timeIntervalSince1970,
                    is_read <- false,
                    is_send <- false,
                    battery <- input_dic["battery"] as? String
                )
                try sql_db!.run(insert)
            }
            else if option.rawValue == "sended"{
                let id_local_input = Int64(input_dic["id_local"]! as! String)!
                print(id_local_input)
                let query = topic_content.filter(
                        id == id_local_input
                )
                let time_string = input_dic["time"]! as! String
                let time_input = time_transform_to_since1970(time_string:time_string)
                try sql_db?.run(query.update(
                    time <- time_input,
                    is_send <- true,
                    id_server <- input_dic["id_server"]! as? String
                ))
            }
            else if option.rawValue == "readed"{
                let id_local_input = Int64(input_dic["id_local"]! as! String)!
                let query = topic_content.filter(
                    id == id_local_input
                )
                try sql_db?.run(query.update(
                    is_read <- true
                ))
            }
            else if option.rawValue == "server"{
                let time_string = input_dic["time"]! as! String
                let is_read_input = input_dic["is_read"]! as? Bool
                let insert = topic_content.insert(
                    topic_id <- input_dic["topic_id"]! as? String,
                    topic_text <- input_dic["topic_content"]! as? String,
                    sender <- input_dic["sender"]! as? String,
                    receiver <- input_dic["receiver"]! as? String,
                    time <- time_transform_to_since1970(time_string:time_string),
                    is_read <- is_read_input,
                    is_send <- true,
                    battery <- input_dic["battery"] as? String,
                    id_server <- input_dic["id_server"]! as? String
                )
                try sql_db!.run(insert)
            }
            
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
        //Check_state = new_msg
            //未送出,直接寫入資料庫
        //Check_state = sended
            //找到該條資料升級成已送出
        //Check_state = readed
            //找到該條資料升級成已讀
        // MARK:test print
        print_part_topic_content()
    }
    func check_id_server(id_server_input:String) -> Bool{
        let query = topic_content.filter(id_server == id_server_input)
        do{
            let query_count = try sql_db?.scalar(query.count)
            if query_count! > 0{
                return false
            }
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
        return true
    }
    func print_all(){
        do{
            for topic_c in try sql_db!.prepare(topic_content) {
                print("id_s: \(topic_c[id_server]), id_l: \(topic_c[id]), re: \(topic_c[receiver]!), se:\(topic_c[sender]!) , is_s:\(topic_c[is_send]) , is_r\(topic_c[is_read]), text: \(topic_c[topic_text]), time:\(topic_c[time])")
            }
            print("========")
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
    }
    func print_part_topic_content(){
        if print_part_log_switch{
            do{
                let query = topic_content.order(id.desc).limit(3)
                for topic_c in try sql_db!.prepare(query.order(id.asc)) {
                    print("id_s: \(topic_c[id_server]), id_l: \(topic_c[id]), re: \(topic_c[receiver]!), se:\(topic_c[sender]!) , is_s:\(topic_c[is_send]) , is_r\(topic_c[is_read]), text: \(topic_c[topic_text]), time:\(topic_c[time])")
                }
                print("========")
            }
            catch{
                print("資料庫錯誤")
                print(error)
            }
        }
        
    }
        // 檢查有沒有未送出的訊息然後一併送出
    func get_topic_content_last_checked_server_id() -> String{
        do{
            let query = topic_content.filter(
                receiver == userData.id &&
                id_server != nil).order(id.desc).limit(1)
            if try sql_db?.scalar(query.count) != 0{
                let last_id = try sql_db!.prepare(query).first(where: { (row) -> Bool in
                    return true
                })![id_server]!
                return "\(last_id)"
            }
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
        return "0"
    }
    func get_unsend_topic_data(topic_id_input:String,client_id:String) -> Array<NSDictionary>?{
        do{
            let query = topic_content.filter(topic_id == topic_id_input).filter(
                (sender == userData.id! && receiver == client_id) ||
                    (sender == client_id && receiver == userData.id!)
                ).filter(is_send == false).order(id.asc)
            var return_list:Array<NSDictionary> = []
            for query_s in try sql_db!.prepare(query) {
                let dict_unit:NSDictionary = [
                    "msg_type": "topic_msg",
                    "msg": query_s[topic_text]!,
                    "receiver": query_s[receiver]!,
                    "topic_id": query_s[topic_id]!,
                    "id_local": String(query_s[id]),
                    "battery_val": query_s[battery]!
                ]
                return_list.append(dict_unit)
            }
            return return_list
        }
        catch{
            print("資料庫錯誤")
            print(error)
            return nil
        }
    }
    func get_histopry_msg(topic_id_input:String,client_id:String) -> Array<Dictionary<String,AnyObject>>{
        let query = topic_content.filter(topic_id == topic_id_input).filter(
            (sender == userData.id! && receiver == client_id) ||
            (sender == client_id && receiver == userData.id!)
            ).order(time.asc)
        var return_list:Array<Dictionary<String,AnyObject>> = []
        do{
            let query_server = query.filter(id_server != nil)
            for query_s in try sql_db!.prepare(query_server){
                var is_resd_input = false
                if query_s[is_read] != nil{
                    is_resd_input = query_s[is_read]!
                }
                let return_dic:Dictionary<String,AnyObject> = [
                    "sender":query_s[sender]! as AnyObject,
                    "topic_content":query_s[topic_text]! as AnyObject,
                    "is_read":is_resd_input as AnyObject,
                    "write_time":query_s[time] as AnyObject,
                    "is_send":query_s[is_send] as AnyObject,
                    "id_local":query_s[id] as AnyObject
                ]
                return_list.append(return_dic)
            }
            send_read_to_server(topic_id_input: topic_id_input, client_id: client_id)
            try sql_db?.run(query_server.filter(receiver == userData.id!).update(is_read <- true))
            let query_local = query.filter(id_server == nil)
            for query_s in try sql_db!.prepare(query_local){
                var is_resd_input = false
                if query_s[is_read] != nil{
                    is_resd_input = query_s[is_read]!
                }
                let return_dic:Dictionary<String,AnyObject> = [
                    "sender":query_s[sender]! as AnyObject,
                    "topic_content":query_s[topic_text]! as AnyObject,
                    "is_read":is_resd_input as AnyObject,
                    "write_time":query_s[time] as AnyObject,
                    "is_send":query_s[is_send] as AnyObject,
                    "id_local":query_s[id] as AnyObject
                    ]
                return_list.append(return_dic)
            }
            return return_list
        }
        catch{
            print("資料庫錯誤")
            print(error)
            return []
        }
        
    }
    func send_read_to_server(topic_id_input:String,client_id:String){
        let query = topic_content.filter(topic_id == topic_id_input).filter(
                (sender == client_id && receiver == userData.id!)
            ).order(time.desc)
        do{
            if let last_msg_obj = try sql_db!.prepare(query).first(where: { (row) -> Bool in
                return true
            }){
                if last_msg_obj[is_read] == false{
                    let sendData = [
                        "msg_type":"topic_content_read",
                        "topic_content_id":last_msg_obj[id_server]
                    ]
                    socket.write(data:json_dumps(sendData as NSDictionary))
                }
            }
        }
        catch{
            print("ERROR!!!  send_read_to_server")
            print(error)
        }
    }
    func update_topic_content_time(id_local:String,time_input:String,id_server_input:String){
        print(id_local)
        do{
            //let check_id_server = self.check_id_server(id_server_input: id_server_input)
            
            let date = time_transform_to_since1970(time_string: time_input)
            let id_local_int = Int64(id_local)
            let query = topic_content.filter(id == id_local_int!)
            try sql_db?.run(query.update(time <- date, is_send <- true, id_server <- id_server_input))
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
    }
    func update_topic_content_read(id_local:String){
        do{
            let id_local_int = Int64(id_local)
            let query = topic_content.filter(id == id_local_int!)
            let topic_content_obj = try sql_db?.prepare(query).first(where: { (row) -> Bool in
                return true
            })
            if topic_content_obj != nil{
                let receiver_input = topic_content_obj![receiver]!
                let topic_id_obj = topic_content_obj![topic_id]!
                let query2 = topic_content.filter(
                    sender == userData.id! &&
                        receiver == receiver_input &&
                        is_read == false &&
                        topic_id == topic_id_obj &&
                        id <= id_local_int!
                )
                let query_count = try sql_db?.scalar(query2.count)
                if query_count! > 0 {
                    try sql_db?.run(query2.update(is_read <- true))
                }
            }
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
        
    }
    func get_topic_content_last_id_server(topic_id_input:String,client_id_input:String) -> String{
        let query = topic_content.filter(
            topic_id == topic_id_input &&
            id_server != nil &&
            (receiver == userData.id! && sender == client_id_input)
        ).order(time.desc).limit(1)
        do{
            for query_s in try sql_db!.prepare(query){
                return query_s[id_server]!
            }
            return "0"
        }
        catch{
            print("資料庫錯誤")
            print(error)
            return "0"
        }
    }
    func get_topic_content_first_id_server(topic_id_input:String,client_id_input:String) -> String{
        let query = topic_content.filter(
            topic_id == topic_id_input &&
                id_server != nil &&
                (sender == userData.id! && receiver == client_id_input) ||
                (receiver == userData.id! && sender == client_id_input)
            ).order(time.asc).limit(1)
        do{
            for query_s in try sql_db!.prepare(query){
                return query_s[id_server]!
            }
            return "0"
        }
        catch{
            print("資料庫錯誤")
            print(error)
            return "0"
        }
    }
    func get_recent_badges() -> Int{
        let myTopicIds:Array<String> = get_my_topics_server_id()
        let black_list:Array<String> = get_black_list()
        let ignore_list = get_ignore_topic_id_list()
        do{
            if userData.id != nil{
                // 抓所有的recentTopic的topic_id  只是我的話題的反向布林操作
                let query = topic_content.filter(
                    !myTopicIds.contains(topic_id) &&
                    sender != userData.id &&
                    is_read == false &&
                    !black_list.contains(sender) &&
                    !ignore_list.contains(topic_id)
                )
                let query_count = try sql_db?.scalar(query.count)
                return query_count!
            }
        }
        catch{
            print("get_myTopic_badges錯誤")
            print(error)
            
        }
        return 0
    }
        // 輸入話題ID,取得一個字典是跟誰的對話，還有最後一句話的狀態
    func get_last_line(topic_id_in:String) -> Dictionary<String,Dictionary<String,AnyObject>>?{
        print("---get_last_line----")
        do{
            let black_list:Array<String> = get_black_list()
            var return_dic:Dictionary<String,Dictionary<String,AnyObject>> = [:]
            let ignore_dic = get_ignore_client_id_list()
            var ignore_list:Array<String> = []
            if ignore_dic[topic_id_in] != nil{
                ignore_list = ignore_dic[topic_id_in]!
            }
            let query2 = topic_content.filter(
                    topic_id == topic_id_in &&
                    !black_list.contains(sender) &&
                    !ignore_list.contains(sender)
                ).select(distinct: sender)
            for sender_s in try sql_db!.prepare(query2){
                let temp_sender_id = sender_s[sender]!
                if temp_sender_id != userData.id && !check_is_in_ignore_list(topic_id_in: topic_id_in, client_id: temp_sender_id){
                    let query_last = topic_content.filter(
                        topic_id == topic_id_in &&
                        ((sender == userData.id! && receiver == temp_sender_id) ||
                        (receiver == userData.id! && sender == temp_sender_id))
                    ).order(id.desc).limit(1)
                    if let temp_last_obj = try sql_db!.prepare(query_last).first(where: { (row) -> Bool in
                        return true
                    }){
                        var topic_who:String
                        if temp_last_obj[sender]! == userData.id!{
                            topic_who = temp_last_obj[receiver]!
                        }
                        else{
                            topic_who = temp_last_obj[sender]!
                        }
                        return_dic[topic_who] = [
                            "sender":temp_last_obj[sender]! as AnyObject,
                            "topic_text":temp_last_obj[topic_text]! as AnyObject,
                            "is_read":temp_last_obj[is_read]! as AnyObject,
                            "time": temp_last_obj[time]! as AnyObject,
                            "level":self.get_level(topic_id_in: topic_id_in, client_id: topic_who) as AnyObject
                        ]
                    }
                }
            }
            
            
//            for topic_obj in try sql_db!.prepare(query){
//                var topic_who:String
//                if topic_obj[sender]! == userData.id!{
//                    topic_who = topic_obj[receiver]!
//                }
//                else{
//                    topic_who = topic_obj[sender]!
//                }
//                return_dic[topic_who] = [
//                    "sender":topic_obj[sender]! as AnyObject,
//                    "topic_text":topic_obj[topic_text]! as AnyObject,
//                    "is_read":topic_obj[is_read]! as AnyObject,
//                    "time": topic_obj[time]! as AnyObject,
//                    "level":self.get_level(topic_id_in: topic_id_in, client_id: topic_who) as AnyObject
//                ]
//            }
            // topic_who* -- topic_text
            //            -- is_read
            //print(return_dic)
            return return_dic
            
        }
        catch{
            print("get_last_line錯誤")
            print(error)
            return nil
        }
    }
        // 取得我跟人的對話解鎖到第幾層
    func get_level(topic_id_in:String,client_id:String) -> Int{
        do{
            let query = topic_content.filter(
                topic_id == topic_id_in &&
                self.receiver == userData.id &&
                self.sender == client_id
                ).count
            let count = try sql_db!.scalar(query)
            let level:Int = count/unlock_img_exp
            print("get_level:\(level)")
            if level >= 0 && level <= 9{
                return level
            }
            else{
                return 9
            }
            
        }
        catch{
            print("get_level資料庫錯誤")
            print(error)
        }
        return 0
    }
    func get_level_my(topic_id_in:String,client_id:String) -> Int{
        do{
            let query = topic_content.filter(
                topic_id == topic_id_in &&
                self.receiver == client_id &&
                self.sender == userData.id!
                ).count
            let count = try sql_db!.scalar(query)
            let level:Int = count/unlock_img_exp
            print("get_level_my:\(get_level_my)")
            if level >= 0 && level <= 9{
                return level
            }
            else{
                return 9
            }
            
        }
        catch{
            print("get_level資料庫錯誤")
            print(error)
        }
        return 0
    }
    func delete_topic_content(topic_id_ins:String){
        do{
            try sql_db!.run(topic_content.filter(topic_id == topic_id_ins).delete())
        }
        catch{
            print("error delete_topic_content")
            print(error)
        }
    }
    
    // user_data
    func establish_user_data(){
        do{
            try sql_db?.run(user_data_table.create { t in
                t.column(id, primaryKey: true)
                t.column(user_id)
                t.column(user_name)
                t.column(img)
                t.column(img_name)
            })
            print("表單建立成功")
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
    }
    func insert_user_name(input_dic:Dictionary<String,AnyObject>){
        do{
            try sql_db!.run(user_data_table.delete())
            let insert = user_data_table.insert(
                user_id <- input_dic["user_id"] as! String,
                user_name <- input_dic["user_name"] as! String,
                img_name <- input_dic["img_name"] as! String
            )
        
            try sql_db!.run(insert)
        }
        catch{
            print(error)
            print("insert_user_name error")
        }
    }
    func update_user_img(input_dic:Dictionary<String,AnyObject>){
        let query = user_data_table.filter(img_name == input_dic["img_name"] as! String)
        let updata = query.update(
            img <- input_dic["img"] as? String
        )
        do{
            try sql_db!.run(updata)
        }
        catch{
            print(error)
            print("update_user_img error")
        }
    }
    func get_user_id() -> String?{
        do{
            let target = try sql_db!.prepare(user_data_table.order(id.desc)).first(where: { (row) -> Bool in
                return true
            })
            if target != nil{
                return target![user_id]
            }
        }
        catch{
            print(error)
            print("get_user_id error")
        }
        return nil
    }
    func get_user_data() -> Dictionary<String,String>?{
        do{
            let target = try sql_db!.prepare(user_data_table.order(id.desc)).first(where: { (row) -> Bool in
                return true
            })
            if target != nil{
                if target![img] == nil{
                    return [
                        "user_id": target![user_id],
                        "user_name": target![user_name],
                        "img_name": target![img_name]
                    ]
                }
                else{
                    return [
                        "user_id": target![user_id],
                        "user_name": target![user_name],
                        "img_name": target![img_name],
                        "img": target![img]!
                    ]
                }
            }
        }
        catch{
            print(error)
            print("get_user_id error")
        }
        return nil
    }
    
    
    // establish_userdata
    func establish_version(version:String){
        do{
            try sql_db?.run(version_table.create { t in
                t.column(id, primaryKey: true)
                t.column(version_number)
            })
            let insert = version_table.insert(
                version_number <- version
            )
            try sql_db!.run(insert)
            print("建立成功 version_table")
        }
        catch{
            print("資料庫錯誤")
            print(error)
        }
    }
    func load_version() -> String?{
        let query = version_table.filter(id == 1)
        do{
            for query_s in try sql_db!.prepare(query){
                return query_s[version_number]
            }
        }
        catch{
            print("資料庫錯誤")
            print(error)
            return nil
        }
        return nil
    }
    
    
    // tmp_client_data客戶本地暫存DB
    func establish_tmp_client_data(){
        do{
            try sql_db?.run(tmp_client_Table.create { t in
                t.column(id, primaryKey: true)
                t.column(client_id)
                t.column(tmp_client_img)
                t.column(tmp_client_img_name)
                t.column(tmp_client_level)
                t.column(tmp_client_sex)
                t.column(tmp_client_real_pic)
                t.column(tmp_client_name)
            })
            print("表單建立成功establish_tmp_client_data")
        }
        catch{
            print("establish_tmp_client_data資料庫錯誤")
            print(error)
        }
    }
        // 新增資料到客戶端本地暫存DB
    func tmp_client_addNew(input_dic:Dictionary<String,AnyObject>){
        do{
            let insert = tmp_client_Table.insert(
                client_id <- input_dic["client_id"]as?String,
                tmp_client_name <- input_dic["client_name"]as?String,
                tmp_client_img <- input_dic["img"]as?String,
                tmp_client_img_name <- input_dic["img_name"]as?String,
                tmp_client_level <- Int64((input_dic["level"]as?Int)!),
                tmp_client_sex <- input_dic["sex"]as?String,
                tmp_client_real_pic <- input_dic["is_real_pic"]as?Bool
            )
            try sql_db?.run(insert)
        }
        catch{
            print("tmp_client_addNew錯誤")
            print(error)
        }
    }
        // 搜尋客戶端本地暫存DB
    func tmp_client_search(searchByClientId:String, level:Int)-> Dictionary<String,AnyObject>?{
        let query_tmp = tmp_client_Table.filter(client_id == searchByClientId && tmp_client_level == Int64(level))
        do{
            if let query_result = try sql_db!.prepare(query_tmp).first(where: { (row) -> Bool in
                return true
            }){
                let return_dic:Dictionary<String,AnyObject> = [
                    "client_id":query_result[client_id]! as AnyObject,
                    "client_name":query_result[tmp_client_name]! as AnyObject,
                    "img":query_result[tmp_client_img]! as AnyObject,
                    "img_name":query_result[tmp_client_img_name]! as AnyObject,
                    "level":Int(query_result[tmp_client_level]!) as AnyObject,
                    "sex":query_result[tmp_client_sex]! as AnyObject,
                    "is_real_pic":query_result[tmp_client_real_pic]! as AnyObject,
                ]
            return return_dic
            }
            return nil
        }
        catch{
                print("tmp_client_search錯誤")
                print(error)
                return nil
            }
    }
        // 客戶端本地暫存DB上限
    func tmp_client_limit(){
        do{
            let count = try sql_db!.scalar(tmp_client_Table.count)
            let tmp_client_limit = 300
            let delete_count = count - tmp_client_limit
            if delete_count > 0{
                let delete_rows = tmp_client_Table.order(id.asc).limit(delete_count)
                try sql_db!.run(delete_rows.delete())
            }
        }
        catch{
            print("tmp_client_limit錯誤")
            print(error)
        }
    }
        // 確認客戶端本地照片是否為最新
    func tmp_client_img_check(client_id:String, tmp_client_img_name:String) -> Bool? {
        do{
            let query_client = tmp_client_Table.filter(self.client_id == client_id)
            if let client_row = try sql_db!.prepare(query_client).first(where: { (row) -> Bool in
                return true
            }){
                if client_row[self.tmp_client_img_name]! == tmp_client_img_name{
                    return true
                }
            
                else{
                    let queryDel = tmp_client_Table.filter(
                        self.client_id == client_id &&
                        self.tmp_client_name != tmp_client_img_name)
                    try sql_db!.run(queryDel.delete())
                    return false
                }
            }
            return nil
        }
        catch{
            print("tmp_client_search錯誤")
            print(error)
            return nil
        }
    }
    
}


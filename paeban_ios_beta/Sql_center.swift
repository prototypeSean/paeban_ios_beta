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
    // user data
    let user_data_table = Table("user_data_table")
    let user_id_table = Expression<String?>("user_id_table")
    // version
    var version_table = Table("version_table")
    let version_number = Expression<String?>("version_number")
    
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
            print("資料庫連線失敗")
        }
    }
    
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
            print(error)
        }
    }
    func print_all2(){
        do{
            for topic_c in try sql_db!.prepare(private_table) {
                print("id_s: \(topic_c[id_server]), id_l: \(topic_c[id]), re: \(topic_c[receiver]!), se:\(topic_c[sender]!) , is_s:\(topic_c[is_send]) , is_r\(topic_c[is_read]) ms: \(topic_c[private_text])")
                // id: 1, email: alice@mac.com, name: Optional("Alice")
            }
            print("========")
        }
        catch{}
    }
    
    // ***working
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
                    // pass
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
                    // pass
                }
                return "new_server_msg"
            }
        }
        else{
            return "new_local_msg"
        }
    }
    
    // old_data
    // new_server_msg*
    // update_local
    // new_local_msg*
    
    
    func check_private_msg_type2(input_dic:Dictionary<String,AnyObject>) -> String{
        if input_dic["id_server"] != nil && input_dic["id_server"]! as! String != "0"{
            let query_id_server = private_table.filter(id_server == input_dic["id_server"]! as? String)
            let query_id_local = private_table.filter(id == Int64(input_dic["id_local"]! as! String)! && sender == userData.id)
            do{
                let count_id_server = try sql_db!.scalar(query_id_server.count)
                let count_id_local = try sql_db!.scalar(query_id_local.count)
                if (count_id_local != 0 && input_dic["sender"] as! String == userData.id!) && count_id_server != 0{
                    return "old_data"
                }
                return "new_server_msg"
            }
            catch{
                return "old_data"
            }
        }
        else{
            return "new_local_msg"
        }
    }
    func inser_date_to_private_msg(input_dic:Dictionary<String,AnyObject>){
        do{
            let topic_msg_type = check_private_msg_type2(input_dic: input_dic)
            print("==============")
            print(topic_msg_type)
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
                    sender <- input_dic["sender"]! as? String,
                    receiver <- input_dic["receiver"]! as? String,
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
            print(error)
            //return nil
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
        catch{return "0"}
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
                let return_dic:Dictionary<String,AnyObject> = [
                    "sender":query_s[sender]! as AnyObject,
                    "private_text":query_s[private_text]! as AnyObject,
                    "is_read":is_resd_input as AnyObject,
                    ]
                return_list.append(return_dic)
            }
            let query_local = query.filter(id_server == nil)
            for query_s in try sql_db!.prepare(query_local){
                var is_resd_input = false
                if query_s[is_read] != nil{
                    is_resd_input = query_s[is_read]!
                }
                let return_dic:Dictionary<String,AnyObject> = [
                    "sender":query_s[sender]! as AnyObject,
                    "private_text":query_s[private_text]! as AnyObject,
                    "is_read":is_resd_input as AnyObject,
                    ]
                return_list.append(return_dic)
            }
            return return_list
        }
        catch{
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
        catch{}
    }
    func update_private_msg_read(id_local:String){
        do{
            let id_local_int = Int64(id_local)
            let query = private_table.filter(id == id_local_int!)
            let private_table_obj = try sql_db?.prepare(query).first(where: { (row) -> Bool in
                return true
            })
            let receiver_input = private_table_obj![receiver]!
            let query2 = private_table.filter(
                sender == userData.id! &&
                    receiver == receiver_input &&
                    is_read == false
            )
            try sql_db?.run(query2.update(is_read <- true, is_send <- true))
        }
        catch{}
        
    }
    // ***working
    
    
    // topic func
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
            })
            print("表單建立成功")
            init_sql = true
        }
        catch{
            print(error)
        }
        
    }
    func remove_topic_content_table(){
        
        do{
            try sql_db?.run(topic_content.drop())
            try sql_db?.run(private_table.drop())
            try sql_db?.run(version_table.drop())
        }
        catch{
            print(error)
            print("表單刪除失敗")
        }
    }
    func check_topic_msg_type(input_dic:Dictionary<String,AnyObject>) -> String{
        if input_dic["id_server"] != nil && input_dic["id_server"]! as! String != "0"{
            let query_id_server = topic_content.filter(id_server == input_dic["id_server"]! as? String)
            //let query_id_local = topic_content.filter(id == Int64(input_dic["id_local"]! as! String)! && sender == userData.id)
            do{
                let count_id_server = try sql_db!.scalar(query_id_server.count)
                //let count_id_local = try sql_db!.scalar(query_id_local.count)
                if count_id_server != 0{
                    return "old_data"
                }
                return "new_server_msg"
            }
            catch{
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
                let insert = topic_content.insert(
                    topic_id <- input_dic["topic_id"]! as? String,
                    topic_text <- input_dic["topic_content"]! as? String,
                    sender <- input_dic["sender"]! as? String,
                    receiver <- input_dic["receiver"]! as? String,
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
            print(error)
            //return nil
        }
        //self.print_all()
    }
    func print_all(){
        do{
            for topic_c in try sql_db!.prepare(topic_content) {
                print("id_s: \(topic_c[id_server]), id_l: \(topic_c[id]), re: \(topic_c[receiver]!), se:\(topic_c[sender]!) , is_s:\(topic_c[is_send]) , is_r\(topic_c[is_read]), text: \(topic_c[topic_text])")
            }
            print("========")
        }
        catch{
            print(error)
        }
        
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
                ]
                return_list.append(dict_unit)
            }
            return return_list
        }
        catch{
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
                ]
                return_list.append(return_dic)
            }
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
                    ]
                return_list.append(return_dic)
            }
            return return_list
        }
        catch{
            return []
        }
        
    }
    func update_topic_content_time(id_local:String,time_input:String,id_server_input:String){
        do{
            let date = time_transform_to_since1970(time_string: time_input)
            let id_local_int = Int64(id_local)
            let query = topic_content.filter(id == id_local_int!)
            try sql_db?.run(query.update(time <- date, is_send <- true, id_server <- id_server_input))
        }
        catch{}
    }
    func update_topic_content_read(id_local:String){
        do{
            let id_local_int = Int64(id_local)
            let query = topic_content.filter(id == id_local_int!)
            let topic_content_obj = try sql_db?.prepare(query).first(where: { (row) -> Bool in
                return true
            })
            let receiver_input = topic_content_obj![receiver]!
            let query2 = topic_content.filter(
                sender == userData.id! &&
                receiver == receiver_input &&
                is_read == false
            )
            try sql_db?.run(query2.update(is_read <- true, is_send <- true))
//            var receiver_input:String
//            for query_s in try sql_db!.prepare(query){
//                receiver_input =
//            }
        }
        catch{}
        
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
        catch{return "0"}
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
        catch{return "0"}
    }
    
    // user_data
    func establish_userdata(){
        do{
            try sql_db?.run(topic_content.create { t in
                t.column(id, primaryKey: true)
                t.column(user_id_table)
            })
            print("表單建立成功")
        }
        catch{
            print(error)
        }
    }
    func insert_user_name(){
        //pass
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
        }
        catch{
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
            return nil
        }
        return nil
    }
}










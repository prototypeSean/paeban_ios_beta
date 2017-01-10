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
            
        }
        catch{
            print(error)
            print("表單建立失敗")
        }
        
    }
    func remove_topic_content_table(){
        
        do{
            try sql_db?.run(topic_content.drop())
        }
        catch{
            print(error)
            print("表單刪除失敗")
        }
    }
    func inser_date_to_topic_content(input_dic:Dictionary<String,AnyObject>){
        do{
            var id_server_input:String?
            var is_read_input = false
            var is_send_input = false
            if input_dic["id_server"] != nil{
                print("id_server")
                id_server_input = input_dic["id_server"]! as? String
                is_read_input = true
                is_send_input = true
            }
            var time_input = Date().timeIntervalSince1970
            if input_dic["time"] != nil{
                let time_string = input_dic["time"]! as! String
                time_input = time_transform_to_since1970(time_string:time_string)
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
//            let query = topic_content.select(id).order(id.desc).limit(1)
//            for query_s in try sql_db!.prepare(query) {
//                return Int(query_s[id])
//            }
            print("寫入資料成功")
        }
        catch{
            print(error)
            //return nil
        }
        //return nil
    }
    func print_all(){
        do{
            for topic_c in try sql_db!.prepare(topic_content) {
                print("id: \(topic_c[id_server]), msg: \(topic_c[topic_text]), re: \(topic_c[receiver]), se:\(topic_c[sender]) , is_s:\(topic_c[is_send])")
            // id: 1, email: alice@mac.com, name: Optional("Alice")
            }
        }
        catch{}
        
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
            
            for query_s in try sql_db!.prepare(query){
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
            (sender == userData.id! && receiver == client_id_input) ||
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
    
}










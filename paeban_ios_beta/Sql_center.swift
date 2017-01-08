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
    
    
    func establish_topic_content_table(){
        let id = Expression<Int64>("id")
        let topic_id = Expression<String?>("topic_id")
        let topic_text = Expression<String?>("topic_text")
        let sender = Expression<String?>("sender")
        let receiver = Expression<String?>("receiver")
        let time = Expression<Double?>("time")
        let is_read = Expression<Bool?>("is_read")
        let is_send = Expression<Bool?>("is_send")
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
    func inser_date_to_topic_content(){
        let id = Expression<Int64>("id")
        let topic_id = Expression<String?>("topic_id")
        let topic_text = Expression<String?>("topic_text")
        let sender = Expression<String?>("sender")
        let receiver = Expression<String?>("receiver")
        let time = Expression<Double?>("time")
        let is_read = Expression<Bool?>("is_read")
        let is_send = Expression<Bool?>("is_send")
        do{
            let insert = topic_content.insert(topic_id <- "Alice",
                                              sender <- "sss",
                                              time <- Date().timeIntervalSince1970)
            try sql_db!.run(insert)
            for user in try sql_db!.prepare(topic_content) {
                print("id: \(user[id]), topic_id: \(user[topic_id]), sender: \(user[sender])")
            }
        }
        catch{
            print(error)
        }
    }
    
}










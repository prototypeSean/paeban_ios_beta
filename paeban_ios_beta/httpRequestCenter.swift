//
//  httpRequestCenter.swift
//  paeban_ios_test_3
//
//  Created by 工作用 on 2016/5/16.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import Foundation
import UIKit

protocol httpResquestDelegate {
    func new_topic_did_load(http_obj:httpRequsetCenter)
}


class httpRequsetCenter{
    var delegate:httpResquestDelegate?
    var topic_list = [Topic]()
    // MARK:轉換為Topic的標準格式
    private func topic_type(ouput_json:Dictionary<NSObject, AnyObject>)->Array<Topic>{
        let type_key:NSObject = "msg_type"
        var topic_list_temp = [Topic]()
        if ouput_json[type_key] as! String == "new_topic"{
            var dataKeyList:[String] = []   //排序topicId清單
            for data_key in ouput_json.keys{
                if data_key as! String != "msg_type"{
                    dataKeyList.append(data_key as! String)
                }
            }
            dataKeyList = dataKeyList.sort(>)
            for dataKey in dataKeyList{
                let photo_temp = UIImage(named: "logo")!
                let topic_temp = Topic(
                    owner: ouput_json[dataKey]!["topic_publisher"] as! String,
                    photo: photo_temp,
                    title: ouput_json[dataKey]!["title"] as! String,
                    hashtags: ouput_json[dataKey]!["tag"] as! Array,
                    lastline:"最後一句對話" ,
                    topicID: String(dataKey)
                    )!
                topic_list_temp.append(topic_temp)
            }
        }
        return topic_list_temp
    }
    // MARK:請求Topic公用部份
    private func topicUpdate(sendDate:String){
        let url = "http://www.paeban.com/topic_update/"
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "POST"
        let csrf = getCSRFToken(cookie!)
        request.allHTTPHeaderFields = ["Cookie":cookie!]
        request.allHTTPHeaderFields = ["X-CSRFToken":csrf!]
        request.HTTPBody = sendDate.dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if error != nil{
                print("連線錯誤\(error)")
            }
            else{
                let ouput = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
                let ouput_json = json_load(ouput) as Dictionary
                self.topic_list = self.topic_type(ouput_json)
                self.delegate?.new_topic_did_load(self)
            }
        })
        task.resume()
        var while_protect = 0
        while topic_list.isEmpty || while_protect < 100{
            sleep(1/10)
            while_protect += 1
        }
    }
    
    func getTopic(){
        topicUpdate("mode=new")
    }
    func getOldTopic(topicID:Int){
        self.topic_list = []
        print("Old啟動")
        let topicIdToString = String(topicID)
        let sentData = "mode=old;min_topic_id=\(topicIdToString)"
        topicUpdate(sentData)
    }
}
//
//  httpRequestCenter.swift
//  paeban_ios_test_3
//
//  Created by 工作用 on 2016/5/16.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import Foundation
import UIKit


protocol ＨttpResquestDelegate {
    func new_topic_did_load(http_obj:ＨttpRequsetCenter)
}

class ＨttpRequsetCenter{
    var delegate:ＨttpResquestDelegate?
    var topic_list = [Topic]()
    
    func getTopic(topicData:[Topic] -> Void){
        let url = "http://www.paeban.com/topic_update/"
        let sendData = "mode=new"
        ajax(url, sendDate: sendData) { (returnData) -> Void in
            let turnToType = self.topic_type(returnData)
            topicData(turnToType)
        }
    }
    
    func getOldTopic(topicID:Int,topicData:[Topic]->Void){
        let topicIdToString = String(topicID)
        let sendData = "mode=old;min_topic_id=\(topicIdToString)"
        let url = "http://www.paeban.com/topic_update/"
        ajax(url, sendDate: sendData) { (returnData) -> Void in
            let turnToType = self.topic_type(returnData)
            topicData(turnToType)
        }
        
    }

    func topicUserMode(topicId:String,InViewAct: (returnData2:Dictionary<String,AnyObject>)->Void){
        let url = "http://www.paeban.com/topic_user_mode/"
        let sendData = "mode=check_user_mode;topic_id=\(topicId)"
        ajax(url, sendDate: sendData) { (returnData) in
            InViewAct(returnData2: returnData as Dictionary)
            
        }
    }
    
    func getTopicContentHistory(topicReceiverId:String,topicId:String,InViewAct: (returnData2:Dictionary<String,AnyObject>)->Void){
        let url = "http://www.paeban.com/topic_user_mode/"
        let sendData = "mode=get_topic_content_history;topic_receiver_id=\(topicReceiverId);topic_id=\(topicId)"
        ajax(url, sendDate: sendData) { (returnData) in
            InViewAct(returnData2: returnData as Dictionary)
        }
    }
    
    func requestMyTopic(InViewAct: (returnData:Dictionary<String,AnyObject>)->Void){
        let url = "http://www.paeban.com/topic_update/"
        let sendData = "mode=request_my_topic"
        ajax(url, sendDate: sendData) { (returnDic) in
            InViewAct(returnData: returnDic)
        }
    }
    
    func get_my_topic_title(InViewAct: (returnData:Dictionary<String,AnyObject>)->Void){
        let url = "http://www.paeban.com/topic_update/"
        let sendData = "mode=get_my_topic_title"
        ajax(url, sendDate: sendData) { (returnDic) in
            InViewAct(returnData: returnDic)
        }
    }
    func get_my_topic_detail(topicId:String,InViewAct: (returnData:Dictionary<String,AnyObject>)->Void) {
        let url = "http://www.paeban.com/topic_update/"
        let sendData = "mode=get_my_topic_detail;topic_id=\(topicId)"
        ajax(url, sendDate: sendData) { (returnDic) in
            InViewAct(returnData: returnDic)
        }
    }
    func request_topic_msg_config(topic_id:String, client_id:String,topic_content_id:String , InViewAct: (returnData:Dictionary<String,AnyObject>)->Void) {
        //return_dic -- topic_content_id
        //           -- img
        //           -- client_name
        //           -- client_is_real_photo
        //           -- client_sex
        //           -- client_online
        let url = "http://www.paeban.com/topic_update/"
        let sendData = "mode=request_topic_msg_config;topic_id=\(topic_id);client_id=\(client_id);topic_content_id=\(topic_content_id)"
        ajax(url, sendDate: sendData) { (returnDic) in
            InViewAct(returnData: returnDic)
        }
        
    }
    // MARK:================私有函數===============
    
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
            //print("------")
            for dataKey in dataKeyList{
                //--base64--
                let encodedImageData = ouput_json[dataKey]!["img"] as! String
                
                let decodedimage = base64ToImage(encodedImageData)
                
                var finalimg:UIImage
                if decodedimage != nil{
                    finalimg = decodedimage!
                }
                else{
                    finalimg = UIImage(named: "logo")!
                }
                //--base64--end
                var isMe:Bool = false
                var online:Bool = false
                
                if ouput_json[dataKey]!["is_me"] as! Bool == true{
                    isMe = true
                }
                if ouput_json[dataKey]!["online"] as! Bool == true{
                    online = true
                }
                
                
                let topic_temp = Topic(
                    owner: ouput_json[dataKey]!["topic_publisher"] as! String,
                    photo: finalimg,
                    title: ouput_json[dataKey]!["title"] as! String,
                    hashtags: ouput_json[dataKey]!["tag"] as! Array,
                    lastline:"最後一句對話" ,
                    topicID: String(dataKey),
                    sex:ouput_json[dataKey]!["sex"] as! String,
                    isMe:isMe,
                    online:online,
                    ownerName:ouput_json[dataKey]!["name"] as! String
                    )!
                topic_list_temp.append(topic_temp)
            }
        }
        return topic_list_temp
    }
    private func ajax(url:String,sendDate:String,outPutDic:Dictionary<String,AnyObject> -> Void){
        var ouput:String?
        var ouput_json = [String:AnyObject]()
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
                ouput = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String
                //print(ouput)
                ouput_json = json_load(ouput!) as! Dictionary
                //print(ouput_json)
                outPutDic(ouput_json)
            }
        })
        
        task.resume()
    }
    
    
    
    private func topiceUserMode(){
        
    }
}





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
    
    func getTopic2(){
        topicUpdate("mode=new")
    }
    func getTopic(Dic2:[Topic] -> Void){
        print("start")
        let url = "http://www.paeban.com/topic_update/"
        let sendDate = "mode=new"
        
        //var topicData:Dictionary<String,AnyObject>?
        ajax(url, sendDate: sendDate) { (Dic) -> Void in
            let turnToType = self.topic_type(Dic)
            Dic2(turnToType)
        }
    }
    
    
    func getOldTopic(topicID:Int){
        self.topic_list = []
        let topicIdToString = String(topicID)
        let sentData = "mode=old;min_topic_id=\(topicIdToString)"
        topicUpdate(sentData)
    }
    func getNewTopic(topicID:Int){
        self.topic_list = []
        let topicIdToString = String(topicID)
        let sentData = "mode=old;min_topic_id=\(topicIdToString)"
        topicUpdate(sentData)
    }
    
    func topicUserMode(topicId:String){
        
        //let data = "mode=check_user_mode;topic_id=\(topicId)"
        
        
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

                let index = encodedImageData.characters.startIndex.advancedBy(23)
                let out = encodedImageData.substringFromIndex(index)
                let dataDecoded:NSData? = NSData(base64EncodedString: out, options: NSDataBase64DecodingOptions())
                var  decodedimage:UIImage?
                if dataDecoded != nil{
                    decodedimage = UIImage(data: dataDecoded!)
                }
                
                var iimg:UIImage
                if decodedimage != nil{
                    iimg = decodedimage!
                }
                else{
                    iimg = UIImage(named: "logo")!
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
                    photo: iimg,
                    title: ouput_json[dataKey]!["title"] as! String,
                    hashtags: ouput_json[dataKey]!["tag"] as! Array,
                    lastline:"最後一句對話" ,
                    topicID: String(dataKey),
                    sex:ouput_json[dataKey]!["sex"] as! String,
                    isMe:isMe,
                    online:online
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
                //print(ouput_json)
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





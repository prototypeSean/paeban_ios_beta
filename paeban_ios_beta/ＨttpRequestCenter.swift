//
//  httpRequestCenter.swift
//  paeban_ios_test_3
//
//  Created by 工作用 on 2016/5/16.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import Foundation
import UIKit

protocol HttpRequestCenterDelegate {
    func new_topic_did_load(_ http_obj:HttpRequestCenter)
}

class HttpRequestCenter{
    var delegate:HttpRequestCenterDelegate?
    var topic_list = [Topic]()
    
    func getTopic(_ topicData:@escaping ([Topic]) -> Void){
        let url = "http://www.paeban.com/topic_update/"
        let sendData = "mode=new"
        ajax(url, sendDate: sendData, retryCount:5) { (returnData) -> Void in
            let turnToType = self.topic_type(returnData as Dictionary<NSObject, AnyObject>)
            topicData(turnToType)
        }
    }
    
    func loginWithIPPW(id:String,pw:String){
//        let url = "http://www.paeban.com/login_paeban/"
//        let sendDic:NSDictionary = ["username":id,"password":pw]
//        let sendData = "data=\(json_dumps2(sendDic))"
//        ajax(url, sendDate: sendData) { (returnData) -> Void in
//            let turnToType = self.topic_type(returnData as Dictionary<NSObject, AnyObject>)
//            //print("httpCenter_27")
//            //print(returnData)
//            topicData(turnToType)
//        }
        
    }
    
    func getOldTopic(_ topicID:Int,topicData:@escaping ([Topic])->Void){
        let topicIdToString = String(topicID)
        let sendData = "mode=old;min_topic_id=\(topicIdToString)"
        let url = "http://www.paeban.com/topic_update/"
        ajax(url, sendDate: sendData, retryCount:5) { (returnData) -> Void in
            if !returnData.isEmpty {
                let turnToType = self.topic_type(returnData as Dictionary<NSObject, AnyObject>)
                topicData(turnToType)
            }
        }
        
    }

//    func topicUserMode(_ topicId:String,InViewAct: @escaping (_ returnData2:Dictionary<String,AnyObject>)->Void){
//        let url = "http://www.paeban.com/topic_user_mode/"
//        let sendData = "mode=check_user_mode;topic_id=\(topicId)"
//        ajax(url, sendDate: sendData, retryCount:5) { (returnData) in
//            if !returnData.isEmpty {
//                InViewAct(returnData as Dictionary)
//            }
//            
//        }
//    }
    
    func getTopicContentHistory(_ topicReceiverId:String,topicId:String,InViewAct: @escaping (_ returnData2:Dictionary<String,AnyObject>)->Void){
        let url = "http://www.paeban.com/topic_user_mode/"
        let sendData = "mode=get_topic_content_history;topic_receiver_id=\(topicReceiverId);topic_id=\(topicId)"
        ajax(url, sendDate: sendData, retryCount:5) { (returnData) in
            if !returnData.isEmpty {
                InViewAct(returnData as Dictionary)
            }
        }
    }
    
    func requestMyTopic(_ InViewAct: @escaping (_ returnData:Dictionary<String,AnyObject>)->Void){
        let url = "http://www.paeban.com/topic_update/"
        let sendData = "mode=request_my_topic"
        ajax(url, sendDate: sendData, retryCount:5) { (returnDic) in
            if !returnDic.isEmpty{
                InViewAct(returnDic)
            }
        }
    }
    
    func get_my_topic_title(_ InViewAct: @escaping (_ returnData:Dictionary<String,AnyObject>)->Void){
        let url = "http://www.paeban.com/topic_update/"
        let sendData = "mode=get_my_topic_title"
        ajax(url, sendDate: sendData, retryCount:5) { (returnDic) in
            InViewAct(returnDic)
        }
    }
    func get_my_topic_detail(_ topicId:String,InViewAct: @escaping (_ returnData:Dictionary<String,AnyObject>)->Void) {
        let url = "http://www.paeban.com/topic_update/"
        let sendData = "mode=get_my_topic_detail;topic_id=\(topicId)"
        ajax(url, sendDate: sendData, retryCount:5) { (returnDic) in
            if !returnDic.isEmpty{
                InViewAct(returnDic)
            }
        }
    }
    func request_topic_msg_config(_ topic_id:String, client_id:String,topic_content_id:String , InViewAct: @escaping (_ returnData:Dictionary<String,AnyObject>)->Void) {
        //return_dic -- topic_content_id
        //           -- img
        //           -- client_name
        //           -- client_is_real_photo
        //           -- client_sex
        //           -- client_online
        let url = "http://www.paeban.com/topic_update/"
        let sendData = "mode=request_topic_msg_config;topic_id=\(topic_id);client_id=\(client_id);topic_content_id=\(topic_content_id)"
        ajax(url, sendDate: sendData, retryCount:5) { (returnDic) in
            if !returnDic.isEmpty{
                InViewAct(returnDic)
            }
        }
        
    }
    
    func reconnect_check_my_table_view(_ send_dic:NSDictionary,InViewAct: @escaping (_ returnData:Dictionary<String,AnyObject>)->Void) {
        let url = "http://www.paeban.com/ws_reconnect/"
        let jsonData = json_dumps2(send_dic)
        let sendData = "mode=check_my_table_view;msg=\(jsonData!)"
        ajax(url, sendDate: sendData, retryCount:5) { (returnDic) in
            if !returnDic.isEmpty{
                InViewAct(returnDic)
            }
        }
    }
    
    func reconnect_update_new_user_data(_ send_dic:NSDictionary,InViewAct: @escaping (_ returnData:Dictionary<String,AnyObject>)->Void) {
        let url = "http://www.paeban.com/ws_reconnect/"
        let jsonData = json_dumps2(send_dic)
        let sendData = "mode=update_new_user_data;msg=\(jsonData!)"
        ajax(url, sendDate: sendData, retryCount:5) { (returnDic) in
            if !returnDic.isEmpty{
                InViewAct(returnDic)
            }
        }
    }
    
    func getBlurImg(_ send_dic:Dictionary<String,String>,InViewAct: @escaping (_ returnData:Dictionary<String,AnyObject>)->Void){
        let url = "http://www.paeban.com/request_user_data/"
        let jsonData = json_dumps2(send_dic as NSDictionary)
        let sendData = "mode=get_blur_image;msg=\(jsonData!)"
        ajax(url, sendDate: sendData, retryCount:5) { (returnDic) in
            if !returnDic.isEmpty{
                InViewAct(returnDic)
            }
        }
        
    }
    func sendSingData(send_dic:NSDictionary,inViewAct:@escaping (_ returnData:Dictionary<String,AnyObject>)->Void){
        let url = "http://www.paeban.com/sing_in/"
        let jsonData = json_dumps2(send_dic)
        let sendData = "mode=final_check;data=\(jsonData!)"
        ajax(url, sendDate: sendData, retryCount:5) { (returnDic) in
            if !returnDic.isEmpty{
                inViewAct(returnDic)
            }
        }
    }
    func privacy_function(msg_type:String, send_dic:NSDictionary,inViewAct:@escaping (_ returnData:Dictionary<String,AnyObject>)->Void){
        let url = "http://www.paeban.com/privacy_function/"
        let jsonData = json_dumps2(send_dic)
        let sendData = "msg_type=\(msg_type);data=\(jsonData!)"
        ajax(url, sendDate: sendData, retryCount:5) { (returnDic) in
            if !returnDic.isEmpty{
                inViewAct(returnDic)
            }
        }
    }
    func friend_function(msg_type:String, send_dic:NSDictionary,inViewAct:@escaping (_ returnData:Dictionary<String,AnyObject>)->Void){
        let url = "http://www.paeban.com/friend_function/"
        let jsonData = json_dumps2(send_dic)
        let sendData = "msg_type=\(msg_type);data=\(jsonData!)"
        ajax(url, sendDate: sendData, retryCount:5) { (returnDic) in
            if !returnDic.isEmpty{
                inViewAct(returnDic)
            }
        }
    }
    
    func change_profile(send_dic:NSDictionary, inViewAct:@escaping (_ returnData:Dictionary<String,AnyObject>)->Void){
        let url = "http://www.paeban.com/change_profile/"
        var send_dic_string = ""
        for send_dic_s in send_dic{
            send_dic_string += "\(send_dic_s.key)=\(send_dic_s.value);"
        }
        ajax(url, sendDate: send_dic_string, retryCount:5) { (returnDic) in
            inViewAct(returnDic)
        }
        
    }
    
    func msg_func(msg_type:String, send_dic:NSDictionary,inViewAct:@escaping (_ returnData:Dictionary<String,AnyObject>)->Void){
        let url = "http://www.paeban.com/msg_func/"
        let jsonData = json_dumps2(send_dic)
        let sendData = "msg_type=\(msg_type);data=\(jsonData!)"
        ajax(url, sendDate: sendData, retryCount:5) { (returnDic) in
            if !returnDic.isEmpty{
                inViewAct(returnDic)
            }
        }
    }
    
    func request_user_data(_ mode:String, send_dic:Dictionary<String,String>,InViewAct: @escaping (_ returnData:Dictionary<String,AnyObject>)->Void){
        let url = "http://www.paeban.com/request_user_data/"
        let jsonData = json_dumps2(send_dic as NSDictionary)
        let sendData = "mode=\(mode);msg=\(jsonData!)"
        ajax(url, sendDate: sendData, retryCount:5) { (returnDic) in
            if !returnDic.isEmpty{
                InViewAct(returnDic)
            }
        }
    }
    
    func request_user_data_v2(_ mode:String, send_dic:Dictionary<String,AnyObject>,InViewAct: @escaping (_ returnData:Dictionary<String,AnyObject>?)->Void){
        let url = "http://www.paeban.com/request_user_data/"
        let jsonData = json_dumps2(send_dic as NSDictionary)
        let sendData = "mode=\(mode);msg=\(jsonData!)"
        ajax(url, sendDate: sendData, retryCount:5) { (returnDic) in
            if !returnDic.isEmpty{
                InViewAct(returnDic)
            }
            else{
                InViewAct(nil)
            }
        }
    }
    
    // MARK:================私有函數===============
    
    // MARK:轉換為Topic的標準格式
    func topic_type(_ ouput_json:Dictionary<NSObject, AnyObject>)->Array<Topic>{
        let type_key:NSObject = "msg_type" as NSObject
        var topic_list_temp = [Topic]()
        if ouput_json[type_key] as! String == "new_topic"{
            var dataKeyList:[String] = []   //排序topicId清單
            for data_key in ouput_json.keys{
                if data_key as! String != "msg_type"{
                    dataKeyList.append(data_key as! String)
                }
            }
            dataKeyList = dataKeyList.sorted(by: >)
            //print("------")
            for dataKey in dataKeyList{
                //--base64--
                let dataKey_val = ouput_json[dataKey as NSObject]
                let encodedImageData = dataKey_val!["img"] as! String
                
                
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
                
                if dataKey_val!["is_me"] as! Bool == true{
                    isMe = true
                }
                if dataKey_val!["online"] as! Bool == true{
                    online = true
                }
                
                let topic_temp = Topic(
                    owner: dataKey_val!["topic_publisher"] as! String,
                    photo: finalimg,
                    title: dataKey_val!["title"] as! String,
                    hashtags: dataKey_val!["tag"] as! Array,
                    lastline:"最後一句對話" ,
                    topicID: String(dataKey),
                    sex:dataKey_val!["sex"] as! String,
                    isMe:isMe,
                    online:online,
                    ownerName:dataKey_val!["name"] as! String,
                    battery:Int(dataKey_val!["battery"] as! String)!
                    )!
                topic_list_temp.append(topic_temp)
            }
        }
        return topic_list_temp
    }
    
    fileprivate func ajax(_ url:String, sendDate:String,retryCount:Int ,outPutDic:@escaping (Dictionary<String,AnyObject>) -> Void){
        if cookie_new.get_cookie() != ""{
            var ouput:String?
            var ouput_json = [String:AnyObject]()
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = ["Cookie":cookie_new.get_cookie()]
            request.allHTTPHeaderFields = ["X-CSRFToken":cookie_new.get_csrf()]
            request.allHTTPHeaderFields = ["Referer":"http://www.paeban.com/"]
            request.httpBody = sendDate.data(using: String.Encoding.utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
                if error != nil{
                    print("======連線錯誤======")
                    print(error)
                    if retryCount > 0{
                        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                            sleep(1)
                            self.ajax(url, sendDate: sendDate, retryCount:retryCount-1, outPutDic: outPutDic)
                        }
                        
                    }
                    else{
                        outPutDic([:])
                    }
                    
                }
                else{
                    ouput = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as? String
                    if let res = response as? HTTPURLResponse{
                        let status = res.statusCode
                        if status == 200{
                            ouput_json = json_load(ouput!) as! Dictionary
                            //print(ouput_json)
                            outPutDic(ouput_json)
                            //print(response)
                        }
                        else{
                            print("http state\(status)")
                            print(sendDate)
                            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
                        }
                    }
                    
                }
            })
            task.resume()
        }
        else{
            print("cookie is nil")
        }

        
        
    }
    func ajax2(_ url:String, sendDate:String,retryCount:Int,cookie:String? ,outPutDic:@escaping (Dictionary<String,AnyObject>) -> Void){
        if cookie != nil{
            var ouput:String?
            var ouput_json = [String:AnyObject]()
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = "POST"
            let csrf = getCSRFToken(cookie!)
            //        print("======cookie=======")
            //        print(cookie)
            //        print(isInternetAvailable())
            request.allHTTPHeaderFields = ["Cookie":cookie!]
            request.allHTTPHeaderFields = ["X-CSRFToken":csrf!]
            request.allHTTPHeaderFields = ["Referer":"http://www.paeban.com/"]
            request.httpBody = sendDate.data(using: String.Encoding.utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
                if error != nil{
                    print("======連線錯誤======")
                    print(error)
                    if retryCount > 0{
                        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                            sleep(1)
                            self.ajax(url, sendDate: sendDate, retryCount:retryCount-1, outPutDic: outPutDic)
                        }
                        
                    }
                    else{
                        outPutDic([:])
                    }
                    
                }
                else{
                    ouput = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as? String
                    if let res = response as? HTTPURLResponse{
                        let status = res.statusCode
                        if status == 200{
                            ouput_json = json_load(ouput!) as! Dictionary
                            //print(ouput_json)
                            outPutDic(ouput_json)
                            //print(response)
                        }
                        else{
                            outPutDic([:])
                            //print(response)
                            //print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
                            print(sendDate)
                            print("http error state:\(status)")
                        }
                    }
                    
                }
            })
            task.resume()
        }
        else{
            print("cookie is nil")
        }
        
        
        
    }
    
    
    func getHttpImg(_ url:String,getImg:@escaping (_ img:UIImage)->Void){
        if cookie_new.get_cookie() != ""{
            var ouput:UIImage?
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = ["Cookie":cookie_new.get_cookie()]
            request.allHTTPHeaderFields = ["X-CSRFToken":cookie_new.get_csrf()]
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
                if error != nil{
                    print("連線錯誤")
                }
                else{
                    ouput = UIImage(data: data!)
                    if let res = response as? HTTPURLResponse{
                        let status = res.statusCode
                        if status != 200{
                            print(response)
                            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
                        }
                        
                    }
                    getImg(ouput!)
                }
            })
            
            task.resume()
        }
        else{print("cookie is nil")}
    }
    
    
    
    fileprivate func topiceUserMode(){
        
    }
}





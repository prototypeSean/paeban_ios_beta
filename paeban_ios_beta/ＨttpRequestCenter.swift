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
    var topic_list:Array<TopicData> = []
    func getTopic(_ topicData:@escaping ([TopicData]) -> Void){
        let url = "\(local_host)topic_update/"
        let sendData = "mode=new"
        ajax(url, sendDate: sendData, retryCount:5) { (returnData) -> Void in
            if !returnData.isEmpty{
                let turnToType = self.topic_type(returnData as Dictionary<NSObject, AnyObject>)
                topicData(turnToType)
            }
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
    
    func getOldTopic(_ topicID:Int,topicData:@escaping ([TopicData])->Void){
        let topicIdToString = String(topicID)
        let sendData = "mode=old;min_topic_id=\(topicIdToString)"
        let url = "\(local_host)topic_update/"
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
        let url = "\(local_host)topic_user_mode/"
        let sendData = "mode=get_topic_content_history;topic_receiver_id=\(topicReceiverId);topic_id=\(topicId)"
        ajax(url, sendDate: sendData, retryCount:5) { (returnData) in
            if !returnData.isEmpty {
                InViewAct(returnData as Dictionary)
            }
        }
    }
    
    func requestMyTopic(_ InViewAct: @escaping (_ returnData:Dictionary<String,AnyObject>)->Void){
        let url = "\(local_host)topic_update/"
        let sendData = "mode=request_my_topic"
        ajax(url, sendDate: sendData, retryCount:5) { (returnDic) in
            if !returnDic.isEmpty{
                InViewAct(returnDic)
            }
        }
    }
    
    func get_my_topic_title(_ InViewAct: @escaping (_ returnData:Dictionary<String,AnyObject>)->Void){
        let url = "\(local_host)topic_update/"
        let sendData = "mode=get_my_topic_title"
        ajax(url, sendDate: sendData, retryCount:5) { (returnDic) in
            InViewAct(returnDic)
        }
    }
    func get_my_topic_detail(_ topicId:String,InViewAct: @escaping (_ returnData:Dictionary<String,AnyObject>)->Void) {
        let url = "\(local_host)topic_update/"
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
        let url = "\(local_host)topic_update/"
        let sendData = "mode=request_topic_msg_config;topic_id=\(topic_id);client_id=\(client_id);topic_content_id=\(topic_content_id)"
        ajax(url, sendDate: sendData, retryCount:5) { (returnDic) in
            if !returnDic.isEmpty{
                InViewAct(returnDic)
            }
        }
        
    }
    
    func reconnect_check_my_table_view(_ send_dic:NSDictionary,InViewAct: @escaping (_ returnData:Dictionary<String,AnyObject>)->Void) {
        let url = "\(local_host)ws_reconnect/"
        let jsonData = json_dumps2(send_dic)
        let sendData = "mode=check_my_table_view;msg=\(jsonData!)"
        ajax(url, sendDate: sendData, retryCount:5) { (returnDic) in
            if !returnDic.isEmpty{
                InViewAct(returnDic)
            }
        }
    }
    
    func reconnect_update_new_user_data(_ send_dic:NSDictionary,InViewAct: @escaping (_ returnData:Dictionary<String,AnyObject>)->Void) {
        let url = "\(local_host)ws_reconnect/"
        let jsonData = json_dumps2(send_dic)
        let sendData = "mode=update_new_user_data;msg=\(jsonData!)"
        ajax(url, sendDate: sendData, retryCount:5) { (returnDic) in
            if !returnDic.isEmpty{
                InViewAct(returnDic)
            }
        }
    }
    
    func getBlurImg(_ send_dic:Dictionary<String,String>,InViewAct: @escaping (_ returnData:Dictionary<String,AnyObject>)->Void){
        let url = "\(local_host)request_user_data/"
        let jsonData = json_dumps2(send_dic as NSDictionary)
        let sendData = "mode=get_blur_image;msg=\(jsonData!)"
        ajax(url, sendDate: sendData, retryCount:5) { (returnDic) in
            if !returnDic.isEmpty{
                InViewAct(returnDic)
            }
        }
        
    }
    func sendSingData(send_dic:NSDictionary,inViewAct:@escaping (_ returnData:Dictionary<String,AnyObject>)->Void){
        let url = "\(local_host)sing_in/"
        let jsonData = json_dumps2(send_dic)
        let sendData = "mode=final_check;data=\(jsonData!)"
        ajax(url, sendDate: sendData, retryCount:5) { (returnDic) in
            if !returnDic.isEmpty{
                inViewAct(returnDic)
            }
        }
    }
    func privacy_function(msg_type:String, send_dic:NSDictionary,inViewAct:@escaping (_ returnData:Dictionary<String,AnyObject>)->Void){
        let url = "\(local_host)privacy_function/"
        let jsonData = json_dumps2(send_dic)
        let sendData = "msg_type=\(msg_type);data=\(jsonData!)"
        ajax(url, sendDate: sendData, retryCount:5) { (returnDic) in
            if !returnDic.isEmpty{
                inViewAct(returnDic)
            }
        }
    }
    func friend_function(msg_type:String, send_dic:NSDictionary,inViewAct:@escaping (_ returnData:Dictionary<String,AnyObject>)->Void){
        let url = "\(local_host)friend_function/"
        let jsonData = json_dumps2(send_dic)
        let sendData = "msg_type=\(msg_type);data=\(jsonData!)"
        ajax(url, sendDate: sendData, retryCount:5) { (returnDic) in
            if !returnDic.isEmpty{
                inViewAct(returnDic)
            }
        }
    }
    
    func change_profile(send_dic:NSDictionary, inViewAct:@escaping (_ returnData:Dictionary<String,AnyObject>)->Void){
        let url = "\(local_host)change_profile/"
        var send_dic_string = ""
        for send_dic_s in send_dic{
            send_dic_string += "\(send_dic_s.key)=\(send_dic_s.value);"
        }
        ajax(url, sendDate: send_dic_string, retryCount:5) { (returnDic) in
            inViewAct(returnDic)
        }
        
    }
    
    func msg_func(msg_type:String, send_dic:NSDictionary,inViewAct:@escaping (_ returnData:Dictionary<String,AnyObject>)->Void){
        let url = "\(local_host)msg_func/"
        let jsonData = json_dumps2(send_dic)
        let sendData = "msg_type=\(msg_type);data=\(jsonData!)"
        ajax(url, sendDate: sendData, retryCount:5) { (returnDic) in
            if !returnDic.isEmpty{
                inViewAct(returnDic)
            }
        }
    }
    
    func inquire_online_state(client_id_list:Array<String>, after:@escaping (_ return_dic:Dictionary<String,AnyObject>)->Void){
        let send_dic = [
            "client_id_list": client_id_list
        ]
        request_user_data_v2("inquire_online_state", send_dic: send_dic as Dictionary<String, AnyObject>) { (return_dic:Dictionary<String, AnyObject>?) in
            if return_dic != nil{
                after(return_dic!)
            }
        }
    }
    
    func request_user_data(_ mode:String, send_dic:Dictionary<String,String>,InViewAct: @escaping (_ returnData:Dictionary<String,AnyObject>)->Void){
        let url = "\(local_host)request_user_data/"
        let jsonData = json_dumps2(send_dic as NSDictionary)
        let sendData = "mode=\(mode);msg=\(jsonData!)"
        ajax(url, sendDate: sendData, retryCount:5) { (returnDic) in
            if !returnDic.isEmpty{
                InViewAct(returnDic)
            }
        }
    }
    
    func send_delete_recent_topic(){
        let send_list = sql_database.get_unsend_recent_topic_list()
        if !send_list.isEmpty{
            let send_dic = ["recent_topic_list":send_list]
            request_user_data_v2("up_load_recent_tpoic_list", send_dic: send_dic as Dictionary<String, AnyObject>, InViewAct: { (return_dic:Dictionary<String, AnyObject>?) in
                if return_dic != nil{
                    let return_recent_topic_list = return_dic!["return_recent_topic_list"] as! Array<String>
                    sql_database.delete_recent_topic_complete(return_recent_topic_list: return_recent_topic_list)
                }
            })
        }
    }
    
    func send_close_my_topic(){
        let send_list = sql_database.get_inactive_my_topic()
        if !send_list.isEmpty{
            let send_dic = ["close_my_topic_list": send_list]
            request_user_data_v2("close_my_topic", send_dic: send_dic as Dictionary<String, AnyObject>, InViewAct: { (return_dic:Dictionary<String, AnyObject>?) in
                if return_dic != nil{
                    let close_my_topic_list = return_dic!["close_my_topic_list"] as! Array<String>
                    sql_database.delete_my_topic_by_list(topic_id_list: close_my_topic_list)
                }
            })
        }
    }
    
    func check_topic_alive(topic_id:String, after:@escaping (_ alive:Bool, _ topic_id:String)->Void){
        request_user_data_v2("check_topic_alive", send_dic: ["topic_id":topic_id as AnyObject]) { (return_dic:Dictionary<String, AnyObject>?) in
            if return_dic != nil{
                after(return_dic!["result"] as! Bool, return_dic!["topic_id"] as! String)
            }
        }
    }
    
    func updata_battery_state(topic_id_list:Array<String>, after:@escaping (Dictionary<String, AnyObject>)->Void){
        request_user_data_v2("request_battery_state", send_dic: ["topic_id_list":topic_id_list as AnyObject]) { (return_dic:Dictionary<String, AnyObject>?) in
            if return_dic != nil{
                after(return_dic!)
            }
        }
    }
    
    func request_user_data_v2(_ mode:String, send_dic:Dictionary<String,AnyObject>,InViewAct: @escaping (_ returnData:Dictionary<String,AnyObject>?)->Void){
        let url = "\(local_host)request_user_data/"
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
    
    func http_request(url:String, data_mode:String, form_data_dic:Dictionary<String,AnyObject>,
                      InViewAct: @escaping (_ returnData:Dictionary<String,AnyObject>?)->Void){
        let url = "\(local_host)\(url)"
        let jsonData = json_dumps2(form_data_dic as NSDictionary)
        let sendData = "mode=\(data_mode);msg=\(jsonData!)"
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
    func topic_type(_ ouput_json:Dictionary<NSObject, AnyObject>)->Array<TopicData>{
        let type_key:NSObject = "msg_type" as NSObject
        var topic_list_temp = [TopicData]()
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
                
                let topic_temp = TopicData(
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
            request.allHTTPHeaderFields = ["Referer":"\(local_host)"]
            request.httpBody = sendDate.data(using: String.Encoding.utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
                if error != nil{
                    print("======連線錯誤======")
                    print(error as Any)
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
                    ouput = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as String?
                    if let res = response as? HTTPURLResponse{
                        print("http complete")
                        if let response_cookie = res.allHeaderFields["Set-Cookie"] as? String {
                            cookie_new.set_cookie(cookie_in: response_cookie)
                        }
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
                            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as Any)
                            outPutDic([:])
                        }
                    }
                    else{
                        print("http statusCode error")
                    }
                    
                }
            })
            task.resume()
        }
        else{
            get_csfr(after: {
                self.ajax(url, sendDate: sendDate, retryCount: retryCount, outPutDic: outPutDic)
            })
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
            request.allHTTPHeaderFields = ["Referer":"\(local_host)"]
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
            get_csfr(after: {
                self.ajax2(url, sendDate: sendDate, retryCount: retryCount, cookie: cookie_new.get_cookie(), outPutDic: outPutDic)
            })
            print("cookie is nil")
        }
        
        
        
    }
    
    
    func getHttpImg(_ url:String,getImg:@escaping (_ img:UIImage)->Void){
        if cookie_new.get_cookie() != ""{
            var ouput:UIImage?
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = "GET"
//            request.allHTTPHeaderFields = ["Cookie":cookie_new.get_cookie()]
//            request.allHTTPHeaderFields = ["X-CSRFToken":cookie_new.get_csrf()]
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
    
    func get_csfr(re_times:Int = 5, after:(()->Void)?){
        // 請求內含csrf的cookie
        // re_times ＝ 重試次數
        // @dk
        let url = "\(local_host)login_paeban/"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = ["Referer":"\(local_host)"]
        let session = URLSession.shared
        //        let aaa = HTTPCookieStorage.shared.cookies(for: URL(string: url)!)
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            if error != nil{
                if re_times > 0{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self.get_csfr(re_times:re_times - 1, after:after)
                    })
                }
                print("連線錯誤\(error!)")
            }
            else{
                if let httpResponse = response as? HTTPURLResponse {
                    if let response_cookie = httpResponse.allHeaderFields["Set-Cookie"] as? String {
                        cookie_new.set_cookie(cookie_in: response_cookie)
                        after?()
                    }
                    else{
                        if re_times > 0{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                self.get_csfr(re_times:re_times - 1, after:after)
                            })
                        }
                        else{
                            print("get csrf fail!!!")
                        }
                    }
                }
                else{
                    if re_times > 0{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            self.get_csfr(re_times:re_times - 1, after:after)
                        })
                    }
                    else{
                        print("get csrf fail!!!")
                    }
                }
            }
            
        })
        task.resume()
    }
    
    
    fileprivate func topiceUserMode(){
        
    }
}





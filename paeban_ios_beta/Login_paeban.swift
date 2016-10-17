//
//  Login_paeban.swift
//  paeban_ios_test_3
//
//  Created by 工作用 on 2016/4/11.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import Foundation
import Starscream

@objc protocol login_paeban_delegate {
    @objc optional func get_cookie_login_report(state:String)
    @objc optional func get_cookie_csrf_report(state:String,setcookie:String)
    @objc optional func get_cookie_by_IDPW_report(state:String,setcookie:String)
}


class login_paeban{
    var fb_ssesion:String?
    var delegate:login_paeban_delegate?
    var csrf_string = ""
    
    func get_cookie(){
        let url = "http://www.paeban.com/register-by-token/facebook/\(fb_ssesion!)"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            if error != nil{
                print("連線錯誤\(error)")
            }
            else{
                let ouput = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                if ouput != "log in fail"{
                    if let httpResponse = response as? HTTPURLResponse {
                        if let response_cookie = httpResponse.allHeaderFields["Set-Cookie"] as? String {
                            self.delegate?.get_cookie_login_report!(state: response_cookie)
                        }
                    }
                }
                else{
                    self.delegate?.get_cookie_login_report!(state: "login_no")
                }
                //print("回應內容物： \(ouput)")
            }
            
        })
        task.resume()
    }
    
    func get_cookie_csrf(){
        let url = "https://www.paeban.com/login_paeban/"

        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        
        request.allHTTPHeaderFields = ["Referer":"https://www.paeban.com/"]
        let session = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            if error != nil{
                print("連線錯誤\(error)")
            }
            else{
                let ouput = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                if let httpResponse = response as? HTTPURLResponse {
                    //                        print("========print(response)========")
                    //                        print(response)
                    if let response_cookie = httpResponse.allHeaderFields["Set-Cookie"] as? String {
                        self.delegate?.get_cookie_csrf_report!(state: ouput as! String,setcookie:response_cookie)
                    }
                    else{
                        self.delegate?.get_cookie_csrf_report!(state: "login_fail",setcookie:"")
                    }
                    
                }
                else{
                    self.delegate?.get_cookie_csrf_report!(state: "login_fail",setcookie:"")
                }
                
                //print(ouput)
            }
            
        })
        task.resume()
    }
    
    
    
    func get_cookie_by_IDPW(id:String,pw:String){
        if cookie == nil || getCSRFToken(cookie!)! == ""{
            get_cookie_csrf()
        }
        var timeLimit = 10000 //10s
        while cookie == nil || getCSRFToken(cookie!)! == ""{
            usleep(10000) //10ms
            timeLimit -= 10
            if timeLimit < 0{
                delegate?.get_cookie_by_IDPW_report!(state: "timeout", setcookie: "")
                break
            }
        }
        if cookie != nil && getCSRFToken(cookie!)! != ""{
            print(cookie)
            print(getCSRFToken(cookie!)!)
            print("=====")
            let url = "https://www.paeban.com/login_paeban/"
            let sendDic:NSDictionary = ["username":id,"password":pw]
            let sendData = "data=\(json_dumps2(sendDic)!)"
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = "POST"
            request.httpBody = sendData.data(using: String.Encoding.utf8)
            request.allHTTPHeaderFields = ["Cookie":cookie!]
            request.allHTTPHeaderFields = ["Referer":"https://www.paeban.com/"]
            let csrf = getCSRFToken(cookie!)
            request.allHTTPHeaderFields = ["X-CSRFToken":csrf!]
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
                if error != nil{
                    print("連線錯誤\(error)")
                }
                else{
                    let ouput = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    if ouput != "login_no"{
                        if let httpResponse = response as? HTTPURLResponse {
                            print(httpResponse.allHeaderFields["Set-Cookie"])
                            if let response_cookie = httpResponse.allHeaderFields["Set-Cookie"] as? String {
                                //cookie = response_cookie
                                self.delegate?.get_cookie_by_IDPW_report!(state: "login_yes", setcookie: response_cookie)
                            }
                        }
                    }
                    else{
                        self.delegate?.get_cookie_by_IDPW_report!(state: "login_no", setcookie: "")
                    }
                    //print("ouput")
                    print(ouput)
                }
                
            })
            task.resume()
        }
        
        
        
        
    }
}


    
    





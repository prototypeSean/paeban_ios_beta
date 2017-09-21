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
    @objc optional func login_with_fb_report(state:String)
    @objc optional func get_cookie_csrf_report(state:String,setcookie:String)
    @objc optional func get_cookie_by_IDPW_report(state:String,setcookie:String)
}


class login_paeban{
    var fb_ssesion:String?
    var delegate:login_paeban_delegate?
    var csrf_string = ""
    func login_with_fb(){
        let url = "\(local_host)register-by-token/facebook/\(fb_ssesion!)"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            if error != nil{
                self.delegate?.login_with_fb_report!(state: "net_fail")
                print("連線錯誤")
                print(error)
            }
            else{
                let ouput = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                if ouput != "log in fail"{
                    if let httpResponse = response as? HTTPURLResponse {
                        if let response_cookie = httpResponse.allHeaderFields["Set-Cookie"] as? String {
                            self.delegate?.login_with_fb_report!(state: response_cookie)
                        }
                    }
                }
                else{
                    self.delegate?.login_with_fb_report!(state: "login_no")
                }
                print("回應內容物：")
                print(ouput)
            }
            
        })
        task.resume()
    }
    
    func get_cookie_csrf(){
        let url = "\(local_host)login_paeban/"

        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        
        request.allHTTPHeaderFields = ["Referer":"\(local_host)"]
        let session = URLSession.shared
//        let aaa = HTTPCookieStorage.shared.cookies(for: URL(string: url)!)
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            if error != nil{
                self.delegate?.get_cookie_csrf_report!(state: "login_fail", setcookie: "")
                print("連線錯誤\(error)")
            }
            else{
                let ouput = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                if let httpResponse = response as? HTTPURLResponse {
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
            }
            
        })
        task.resume()
    }
    
    
    
    func get_cookie_by_IDPW(id:String,pw:String){
//        if cookie_new.get_cookie() == "" || cookie_new.get_csrf() == ""{
//            get_cookie_csrf()
//        }
//        var timeLimit = 10000 //10s
//        while cookie_new.get_cookie() == "" || cookie_new.get_csrf() == ""{
//            usleep(10000) //10ms
//            timeLimit -= 10
//            if timeLimit < 0{
//                delegate?.get_cookie_by_IDPW_report!(state: "timeout", setcookie: "")
//                break
//            }
//        }
        
        let url = "\(local_host)login_paeban/"
        let sendDic:NSDictionary = ["username":id,"password":pw]
        let sendData = "data=\(json_dumps2(sendDic)!)"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = sendData.data(using: String.Encoding.utf8)
        request.allHTTPHeaderFields = ["Referer":"\(local_host)"]
        request.allHTTPHeaderFields = ["Cookie":cookie_new.get_cookie()]
        request.allHTTPHeaderFields = ["X-CSRFToken":cookie_new.get_csrf()]
        let session = URLSession.shared
        func start_login(){
            let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
                if error != nil{
                    self.delegate?.get_cookie_by_IDPW_report!(state: "net_fail", setcookie: "")
                    print("連線錯誤\(error)")
                    
                }
                else{
                    let ouput = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    if ouput != "login_no"{
                        if let httpResponse = response as? HTTPURLResponse {
                            if let response_cookie = httpResponse.allHeaderFields["Set-Cookie"] as? String {
                                //cookie = response_cookie
                                self.delegate?.get_cookie_by_IDPW_report!(state: "login_yes", setcookie: response_cookie)
                            }
                            else{
                                print("response_cookie_error")
                            }
                            
                        }
                        else{
                            
                            print("httpResponse_error")
                            
                        }
                        print(response as Any)
                    }
                    else{
                        self.delegate?.get_cookie_by_IDPW_report!(state: "login_no", setcookie: "")
                    }
                }
                
            })
            task.resume()
        }
        
        
        var request_csrf = URLRequest(url: URL(string: url)!)
        request_csrf.httpMethod = "GET"
        
        request_csrf.allHTTPHeaderFields = ["Referer":"\(local_host)"]
        let task_csrf = session.dataTask(with: request_csrf, completionHandler: {data, response, error -> Void in
            if error != nil{
                self.delegate?.get_cookie_csrf_report!(state: "login_fail", setcookie: "")
                print("連線錯誤\(error)")
            }
            else{
                //let ouput = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                if let httpResponse = response as? HTTPURLResponse {
                    if let response_cookie = httpResponse.allHeaderFields["Set-Cookie"] as? String {
                        cookie_new.set_cookie(cookie_in: response_cookie)
                        request.allHTTPHeaderFields = ["Cookie":cookie_new.get_cookie()]
                        request.allHTTPHeaderFields = ["X-CSRFToken":cookie_new.get_csrf()]
                        start_login()
                    }
                    else{
                        self.delegate?.get_cookie_by_IDPW_report!(state: "timeout", setcookie: "")
                    }
                    
                }
                else{
                    self.delegate?.get_cookie_by_IDPW_report!(state: "timeout", setcookie: "")
                }
                print(response as Any)
                //print(ouput)

            }
            
            
        })
        if (cookie_new.get_cookie() != "" && cookie_new.get_csrf() != ""){
            //task.resume()
            start_login()
        }
        else{
            task_csrf.resume()
        }
        
        
        
        
    }
}


    
    





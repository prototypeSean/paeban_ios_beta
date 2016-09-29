//
//  Login_paeban.swift
//  paeban_ios_test_3
//
//  Created by 工作用 on 2016/4/11.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import Foundation
import Starscream

class login_paeban{
    var fb_ssesion:String?
    
    
    
    func get_cookie() ->String{
        var login_return_val:String?
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
                            cookie = response_cookie
                            if cookie != nil{
                                login_return_val = cookie
                            }
                            else{
                                login_return_val = "login_no"
                            }
                        }
                    }
                }
                else{
                    login_return_val = "login_no"
                }
                //print("回應內容物： \(ouput)")
            }
            
        })
        task.resume()
        var while_protect:Int = 0
        while login_return_val == nil || while_protect < 100{
            sleep(1/10)
            while_protect += 1
        }
        //print(login_return_val)
        return login_return_val!
    }
    
    func get_cookie_csrf() -> String? {
        let url = "https://www.paeban.com/login_paeban/"
        
        var login_return_val:String?
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        //let sendData = "csrfmiddlewaretoken=VPgY4sgd2nlEFZYxv9i5xl9cSwbXA4fo;"
        //request.allHTTPHeaderFields = ["Cookie":"csrftoken=VPgY4sgd2nlEFZYxv9i5xl9cSwbXA4fo"]
        //request.httpBody = sendData.data(using: String.Encoding.utf8)
        request.allHTTPHeaderFields = ["Referer":"https://www.paeban.com/"]
        let session = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            if error != nil{
                print("連線錯誤\(error)")
            }
            else{
                let ouput = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                if ouput != "log in fail"{
                    if let httpResponse = response as? HTTPURLResponse {
                        print("========print(response)========")
                        print(response)
                        if let response_cookie = httpResponse.allHeaderFields["Set-Cookie"] as? String {
                            cookie = response_cookie
                            if cookie != nil{
                                login_return_val = cookie
                            }
                            else{
                                login_return_val = "login_no"
                            }
                        }
                        else if httpResponse.statusCode == 200{
                            login_return_val = ouput! as String
                            //cookie = "csrftoken=\(ouput!)"
                        }
                        else{login_return_val = "login_no"}
                        
                    }
                    else{login_return_val = "login_no"}
                }
                else{
                    login_return_val = "login_no"
                }
                print("=======output=======")
                print(ouput)
            }
            
        })
        task.resume()
        var while_protect:Int = 0
        while login_return_val == nil || while_protect < 10{
            sleep(1/10)
            while_protect += 1
        }
        return login_return_val
    }
    
    
    
    func get_cookie_by_IDPW(id:String,pw:String) -> String?{
        //let csrf_state = get_cookie_csrf()
        let csrf_state = "login_no"
        if csrf_state == "login_no"{
            let url = "https://www.paeban.com/login_paeban/"
            let sendDic:NSDictionary = ["username":id,"password":pw]
            let sendData = "csrfmiddlewaretoken=VPgY4sgd2nlEFZYxv9i5xl9cSwbXA4fo;data=\(json_dumps2(sendDic)!)"
            var login_return_val:String?
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = "POST"
            request.httpBody = sendData.data(using: String.Encoding.utf8)
            
            request.allHTTPHeaderFields = ["Cookie":"csrftoken=VPgY4sgd2nlEFZYxv9i5xl9cSwbXA4fo"]
            request.allHTTPHeaderFields = ["Referer":"https://www.paeban.com/"]
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
                if error != nil{
                    print("連線錯誤\(error)")
                }
                else{
                    let ouput = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    if ouput != "login fail"{
                        if let httpResponse = response as? HTTPURLResponse {
                            print(httpResponse.allHeaderFields["Set-Cookie"])
                            if let response_cookie = httpResponse.allHeaderFields["Set-Cookie"] as? String {
                                
                                cookie = response_cookie
                                if cookie != nil{
                                    login_return_val = cookie
                                }
                                else{
                                    login_return_val = "login_no"
                                }
                            }
                        }
                    }
                    else{
                        login_return_val = "login_no"
                    }
                    print("ouput")
                    print(ouput)
                }
                
            })
            task.resume()
            var while_protect:Int = 0
            while login_return_val == nil || while_protect < 100{
                sleep(1/10)
                while_protect += 1
            }
//            print("162_cookie")
//            print(cookie)
            return login_return_val
            
        }
        return "login_no"
    }
}


    
    





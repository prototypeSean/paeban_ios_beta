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
    var fb_ssesion:String
    var cookie:String!
    
    
    init(fb_ssesion:String){
        self.fb_ssesion = fb_ssesion
    }
    
    func get_cookie() ->String{
        var login_return_val:String?
        let url = "http://www.paeban.com/register-by-token/facebook/\(fb_ssesion)"
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "GET"
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if error != nil{
                print("連線錯誤\(error)")
            }
            else{
                let ouput = NSString(data: data!, encoding: NSUTF8StringEncoding)
                if ouput != "log in fail"{
                    if let httpResponse = response as? NSHTTPURLResponse {
                        if let response_cookie = httpResponse.allHeaderFields["Set-Cookie"] as? String {
                            self.cookie = response_cookie
                            if self.cookie != nil{
                                login_return_val = self.cookie
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
}


    
    





//
//  ToolsFunction.swift
//  paeban_ios_test_3
//
//  Created by 工作用 on 2016/5/16.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import Foundation
import SystemConfiguration
import UIKit

//MARK: 封裝成json
func json_dumps(_ input_data:NSDictionary) ->Data{
    var ouput_data:Data?
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: input_data, options: JSONSerialization.WritingOptions.prettyPrinted)
        ouput_data = jsonData
        //here "jsonData" is the dictionary encoded in JSON data
    } catch let error as NSError {
        print(error)
    }
    return ouput_data!
}

func json_dumps2(_ input_data:NSDictionary) -> String?{
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: input_data, options: JSONSerialization.WritingOptions.prettyPrinted)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        return jsonString
        
        //here "jsonData" is the dictionary encoded in JSON data
    } catch let error as NSError {
        print(error)
        return nil
    }
    
}

//MARK: 解封json
func json_load(_ input_data:String) ->NSDictionary{
    var ouput : NSDictionary?
    
    let input_data_2 = input_data.data(using: String.Encoding.utf8)
    
    do {
        let decoded = try JSONSerialization.jsonObject(with: input_data_2!, options: []) as? NSDictionary
        // here "decoded" is the dictionary decoded from JSON data
        ouput = decoded
    } catch let error as NSError {
        print(error)
        //print(input_data_2)
    }
    if ouput != nil{
        return ouput!
    }
    return [:]
}


//MARK: 擷取cookie裡的csrftoken值
func getCSRFToken(_ cookie:String) -> String? {
    let keyWord = "csrftoken="
    
    func getWord(_ str:String, index:Int) -> String {
        return String(str[str.characters.index(str.characters.startIndex, offsetBy: index)])
    }
    
    var stopSwitch = false
    var ouputCookie = ""
    for x in 0..<(cookie.characters.count as Int){
        if getWord(cookie,index: x) == "c"{
            var keyWordCheck = true
            for x2 in 0..<(keyWord.characters.count as Int){
                
                let posion = x+x2
                if posion < (cookie.characters.count as Int){
                    if getWord(cookie,index: posion) != getWord(keyWord,index: x2){
                        keyWordCheck = false
                    }
                }
            }
            if keyWordCheck{
                let getCookStartCount = x+(keyWord.characters.count as Int)
                let endCount = (cookie.characters.count as Int)
                
                if endCount > getCookStartCount{
                    for x3 in getCookStartCount..<endCount{
                        if getWord(cookie, index: x3) != ";"{
                            ouputCookie += getWord(cookie, index: x3)
                        }
                        else{
                            break
                        }
                    }
                    stopSwitch = true
                }
            }
        }
        if stopSwitch{
            break
        }
    }
    return String(ouputCookie)
}


//MARK: base64轉換成UIImage
func base64ToImage(_ encodedImageData:String) -> UIImage?{
    
    let index = encodedImageData.characters.index(encodedImageData.characters.startIndex, offsetBy: 23)
    let out = encodedImageData.substring(from: index)
    //print(out)
    let dataDecoded:Data? = Data(base64Encoded: out, options: NSData.Base64DecodingOptions())
    var  decodedimage:UIImage?
    if dataDecoded != nil{
        decodedimage = UIImage(data: dataDecoded!)
    }
    return decodedimage
}

func imageToBase64(image:UIImage, optional:String) -> String{
    let imageData = UIImagePNGRepresentation(image)
    // data:image/jpeg;base64,
    let base64String = imageData?.base64EncodedString(options: Data.Base64EncodingOptions.endLineWithLineFeed)
    //lineLength64Characters
    if optional == "withHeader"{
        return "data:image/jpeg;base64," + base64String!
    }
    else{
        return base64String!
    }
    
}


//正則匹配
func regMatches(for regex: String, in text: String) -> [String] {
    
    do {
        let regex = try NSRegularExpression(pattern: regex)
        let nsString = text as NSString
        let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
        return results.map { nsString.substring(with: $0.range)}
    } catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}

//確認網路連線
func isInternetAvailable() -> Bool{
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
            SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
        }
    }
    
    var flags = SCNetworkReachabilityFlags()
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
        return false
    }
    let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
    let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
    return (isReachable && !needsConnection)
}

//偵測是否連線
func check_online(in vc:UIViewController, with original_func:@escaping ()->Void){
    if isInternetAvailable(){
        original_func()
    }
    else{
        let alert = UIAlertController(title: "警告", message: "網路尚未連線", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.default, handler:nil))
        alert.addAction(UIAlertAction(title: "重試", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            check_online(in: vc, with: original_func)
        }))
        vc.present(alert, animated: true, completion: nil)
    }
}


// 快速通知
func fast_alter(inviter:String,nav_controller:UINavigationController){
    let nav = nav_controller
    let alert = UILabel()
    alert.backgroundColor = UIColor.gray
    alert.text = "\(inviter) 邀請你為好友"
    alert.textColor = UIColor.white
    alert.textAlignment = NSTextAlignment.center
    alert.frame = CGRect(x: 0, y: -60, width: nav.view.frame.width, height: 60)
    nav.view.addSubview(alert)
    UIView.animateKeyframes(withDuration: TimeInterval(0.5), delay: TimeInterval(0), options: .beginFromCurrentState, animations: {
        alert.frame = CGRect(x: 0, y: CGFloat(0), width: nav.view.frame.width, height: 60)
        }, completion: nil)
    
    UIView.animateKeyframes(withDuration: 0.5, delay: TimeInterval(1.5), options: .beginFromCurrentState, animations: {
        alert.alpha = CGFloat(0)
        }, completion: {(bool) in
            alert.removeFromSuperview()
    })
}


func leap(from currentVC:UIViewController, to page:Int){
    var PartentVC:UIViewController?
    PartentVC = currentVC.parent
    for _ in 0..<5{
        if PartentVC != nil{
            let rid = PartentVC?.restorationIdentifier
            if rid == "tabBar"{
                let tab = PartentVC as! UITabBarController
                tab.selectedIndex = page
                break
            }
            PartentVC = PartentVC?.parent
        }
        else{
            break
        }
        
    }
}


func leapToPage(segueInf:Dictionary<String,String>) -> Int?{
    var returnInt:Int?
    if let type = segueInf["type"]{
        switch type {
        case "topic_msg_master":
            returnInt = 1
        case "topic_msg_client":
            returnInt = 2
        case "priv_msg":
            returnInt = 3
        default:
            returnInt = nil
        }
    }
    return returnInt
}

func simpoAlert2(view:UIViewController , reason:String){
    let mailAlert = UIAlertController(title: "錯誤", message: reason, preferredStyle: UIAlertControllerStyle.alert)
    mailAlert.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
        //code
    }))
    view.present(mailAlert, animated: true, completion: {
        //code
    })
}

func time_transform_to_since1970(time_string:String) -> TimeInterval!{
    let time_transform = DateFormatter()
    
    let dot_index = time_string.characters.index(of: ".")
    
    if dot_index == nil{
        time_transform.dateFormat = "Y-MM-dd HH:mm:ssxxx"
    }
    else{
        time_transform.dateFormat = "Y-MM-dd HH:mm:ss.Sxxx"
    }
    
    let time_input = (time_transform.date(from: time_string)?.timeIntervalSince1970)!
    return time_input
}

func time_diff(time_input:Double){
    
}









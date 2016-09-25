//
//  ToolsFunction.swift
//  paeban_ios_test_3
//
//  Created by 工作用 on 2016/5/16.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import Foundation
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
    return ouput!
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
    let dataDecoded:Data? = Data(base64Encoded: out, options: NSData.Base64DecodingOptions())
    var  decodedimage:UIImage?
    if dataDecoded != nil{
        decodedimage = UIImage(data: dataDecoded!)
    }
    return decodedimage
}


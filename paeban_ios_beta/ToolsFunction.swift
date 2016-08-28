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
func json_dumps(input_data:NSDictionary) ->NSData{
    var ouput_data:NSData?
    do {
        let jsonData = try NSJSONSerialization.dataWithJSONObject(input_data, options: NSJSONWritingOptions.PrettyPrinted)
        ouput_data = jsonData
        //here "jsonData" is the dictionary encoded in JSON data
    } catch let error as NSError {
        print(error)
    }
    return ouput_data!
}

func json_dumps2(input_data:NSDictionary) -> String?{
    do {
        let jsonData = try NSJSONSerialization.dataWithJSONObject(input_data, options: NSJSONWritingOptions.PrettyPrinted)
        let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)! as String
        return jsonString
        
        //here "jsonData" is the dictionary encoded in JSON data
    } catch let error as NSError {
        print(error)
        return nil
    }
    
}

//MARK: 解封json
func json_load(input_data:String) ->NSDictionary{
    var ouput : NSDictionary?
    
    let input_data_2 = input_data.dataUsingEncoding(NSUTF8StringEncoding)
    
    do {
        let decoded = try NSJSONSerialization.JSONObjectWithData(input_data_2!, options: []) as? NSDictionary
        // here "decoded" is the dictionary decoded from JSON data
        ouput = decoded
    } catch let error as NSError {
        print(error)
        //print(input_data_2)
    }
    return ouput!
}


//MARK: 擷取cookie裡的csrftoken值
func getCSRFToken(cookie:String) -> String? {
    let keyWord = "csrftoken="
    
    func getWord(str:String, index:Int) -> String {
        return String(str[str.characters.startIndex.advancedBy(index)])
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
func base64ToImage(encodedImageData:String) -> UIImage?{
    let index = encodedImageData.characters.startIndex.advancedBy(23)
    let out = encodedImageData.substringFromIndex(index)
    let dataDecoded:NSData? = NSData(base64EncodedString: out, options: NSDataBase64DecodingOptions())
    var  decodedimage:UIImage?
    if dataDecoded != nil{
        decodedimage = UIImage(data: dataDecoded!)
    }
    return decodedimage
}


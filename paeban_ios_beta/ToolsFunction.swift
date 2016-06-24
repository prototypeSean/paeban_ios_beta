//
//  ToolsFunction.swift
//  paeban_ios_test_3
//
//  Created by 工作用 on 2016/5/16.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import Foundation

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

func json_load(input_data:String) ->NSDictionary{
    var ouput : NSDictionary?
    let input_data_2 = input_data.dataUsingEncoding(NSUTF8StringEncoding)
    do {
        let decoded = try NSJSONSerialization.JSONObjectWithData(input_data_2!, options: []) as? NSDictionary
        // here "decoded" is the dictionary decoded from JSON data
        ouput = decoded
    } catch let error as NSError {
        print(error)
    }
    return ouput!
}

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


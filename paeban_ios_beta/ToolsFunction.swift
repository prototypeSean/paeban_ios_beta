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
    var state = false, state2 = false, count = 1, result = [Character]()
    let key = "csrftoken=s"
    //print(cookie)
    for word in cookie.characters.indices{
        if state{
            //print(cookie[word])
            //print(key[key.startIndex.advancedBy(count)])
            
            if cookie[word] == key[key.startIndex.advancedBy(count)]{
                count += 1
                if cookie[word] == "="{
                    state = false
                    state2 = true
                }
            }
            else{
                state = false
            }
        }
        else if state2{
            if cookie[word] != ";"{
                result.append(cookie[word] as Character)
            }
            else{
                state2 = false
            }
        }
        else{
            if cookie[word] == "c"{
                state = true
            }
        }
    }
    return String(result)
}


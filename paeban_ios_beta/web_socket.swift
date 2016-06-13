//
//  web_socket.swift
//  paeban_ios_test_3
//
//  Created by 工作用 on 2016/4/11.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import Foundation
import Starscream


func ws_connected(ws:WebSocket){
    let online_msg = json_dumps(["msg_type":"online"])
    ws.writeData(online_msg)
}
func ws_onmsg(text:String){
    print(text)
    let unzip_data :NSDictionary = json_load(text)
    //print(unzip_data)
    if unzip_data["msg_type"] as? String == "online"{
        print("online...")
    }
    else{
        print(unzip_data["msg_type"])
    }
    
}


func ws_connect_fun(ws:WebSocket){
    ws.onConnect = {
        //print("ccccccc")
    }
    ws.connect()
}




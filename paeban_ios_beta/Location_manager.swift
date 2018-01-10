//
//  Location_manager.swift
//  paeban_ios_beta
//
//  Created by elijah on 2017/12/29.
//  Copyright © 2017年 尚義 高. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation


public class Location_manage:NSObject,CLLocationManagerDelegate{
    var myLocationManager :CLLocationManager!
    var my_location:CLLocationCoordinate2D?
    var locate_authorize:Bool?
    var upload_location_list:Array<Double>?
    var self_location_list:Array<Double>?
        // 暫存準備上傳的自我座標
    override init() {
        super.init()
        myLocationManager = CLLocationManager()
        
        // 設置委任對象
        myLocationManager.delegate = self
        
        // 距離篩選器 用來設置移動多遠距離才觸發委任方法更新位置
        myLocationManager.distanceFilter = 1000
        
        // 取得自身定位位置的精確度
        myLocationManager.desiredAccuracy = 50
    }
    func start_locate(){
        locate_process()
    }
    
    // MARK: operate function
         // 取得跟別人的距離字典<對方ＩＤ, 距離>
    func get_distance(client_id_list:Array<String>, after:@escaping (_ distance_dic:Dictionary<String, Double>)->Void){
        let CLIENT_ID_LIST = "client_id_list"
        let send_dic = [CLIENT_ID_LIST: client_id_list]
        HttpRequestCenter().request_user_data_v2("get_location", send_dic: send_dic as Dictionary<String, AnyObject>) { (result_dic) in
            guard result_dic != nil else{
                return
            }
            guard self.self_location_list != nil else{
                return
            }
            var result_dic_2:Dictionary<String, Double> = [:]
            
            let data_dic = result_dic as! Dictionary<String, Array<String>>
            let point_self:CLLocationCoordinate2D = CLLocationCoordinate2D(
                latitude: self.self_location_list![0],
                longitude:  self.self_location_list![1])
            // 自己的座標
            for c in data_dic{
                // 計算別人的距離
                let point_client:CLLocationCoordinate2D = CLLocationCoordinate2D(
                    latitude: Double(c.value[0])!,
                    longitude: Double(c.value[1])!)
                let distance = self.GetDistance_Google(pointA: point_self, pointB: point_client)
                result_dic_2[c.key] = distance
            }
            after(result_dic_2)
        }
    }
    
    // MARK: internal function
        // 地球上兩點取得距離
    private func GetDistance_Google(pointA:CLLocationCoordinate2D , pointB:CLLocationCoordinate2D) -> Double{
        let EARTH_RADIUS:Double = 6378.137;
        
        let radlng1:Double = pointA.longitude * .pi / 180.0;
        let radlng2:Double = pointB.longitude * .pi / 180.0;
        
        let a:Double = radlng1 - radlng2;
        let b:Double = (pointA.latitude - pointB.latitude) * .pi / 180;
        var s:Double = 2 * asin(sqrt(pow(sin(a/2), 2) + cos(radlng1) * cos(radlng2) * pow(sin(b/2), 2)));
        
        s = s * EARTH_RADIUS;
        s = (round(s * 10000) / 10000);
        return s;
    }
        // 開始定位程序
    private func locate_process(){
        // 首次使用 向使用者詢問定位自身位置權限
        print("首次使用 向使用者詢問定位自身位置權限")
        if CLLocationManager.authorizationStatus() ==  CLAuthorizationStatus.notDetermined {
            // 取得定位服務授權
            print("取得定位服務授權")
            myLocationManager.requestWhenInUseAuthorization()
            
            if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied{
                locate_authorize = false
            }
            else if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse{
                locate_authorize = true
            }
            
            // 開始定位自身位置
            print("開始定位自身位置")
            myLocationManager.startUpdatingLocation()
        }
            // 使用者已經拒絕定位自身位置權限
        else if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied {
            // 提示可至[設定]中開啟權限
            locate_authorize = false
        }
            // 使用者已經同意定位自身位置權限
        else if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse {
            // 開始定位自身位置
            myLocationManager.startUpdatingLocation()
            locate_authorize = true
        }
    }
    
        // 上傳位置
    private func upload_location(){
        let LOCATION_LIST = "location_list"
        guard self.upload_location_list != nil else {
            return
        }
        let send_dic = [LOCATION_LIST: self.upload_location_list as AnyObject]
        HttpRequestCenter().request_user_data_v2("upload_location", send_dic: send_dic) { (result_dic) in
            if result_dic == nil{
                DispatchQueue.main.asyncAfter(deadline: .now() + 180, execute: {
                    self.upload_location()
                })
            }
            else{
                self.upload_location_list = nil
            }
        }
    }
    // MARK: delegate
        // return my coordinate
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        if !locations.isEmpty{
            let currentLocation :CLLocation =
                locations[0] as CLLocation
            self.upload_location_list = [currentLocation.coordinate.latitude, currentLocation.coordinate.longitude]
            self.self_location_list = self.upload_location_list
            upload_location()
        }
    }
    
}



















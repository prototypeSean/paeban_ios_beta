//
//  Location_manager.swift
//  paeban_ios_beta
//
//  Created by elijah on 2017/12/29.
//  Copyright © 2017年 尚義 高. All rights reserved.
//

import Foundation
import MapKit


class Location_manage:NSObject,CLLocationManagerDelegate{
    var myLocationManager :CLLocationManager!
    var my_location:CLLocationCoordinate2D?
    var locate_authorize:Bool?
    override init() {
        super.init()
        myLocationManager = CLLocationManager()
        
        // 設置委任對象
        myLocationManager.delegate = self
        
        // 距離篩選器 用來設置移動多遠距離才觸發委任方法更新位置
        myLocationManager.distanceFilter = 1000
        
        // 取得自身定位位置的精確度
        myLocationManager.desiredAccuracy = 50
        
        locate_process()
    }
    
    // MARK: operate function
    func get_distance(){}
    
    // MARK: internal function
        // 地球上兩點取得距離
    func GetDistance_Google(pointA:CLLocationCoordinate2D , pointB:CLLocationCoordinate2D) -> Double{
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
    func locate_process(){
        // 首次使用 向使用者詢問定位自身位置權限
        if CLLocationManager.authorizationStatus() ==  CLAuthorizationStatus.notDetermined {
            // 取得定位服務授權
            myLocationManager.requestWhenInUseAuthorization()
            
            if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied{
                locate_authorize = false
            }
            else if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse{
                locate_authorize = true
            }
            
            // 開始定位自身位置
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
    
    // MARK: delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
    }
    
}



















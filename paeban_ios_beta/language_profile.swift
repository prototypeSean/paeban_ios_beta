//
//  language_profile.swift
//  paeban_ios_beta
//
//  Created by elijah on 2017/11/29.
//  Copyright © 2017年 尚義 高. All rights reserved.
//  Fuck!! Copyright belong to me(elijah)!!!


import Foundation

//MARK: language profile
public class alert_string {
    // 標題
    let warning = "警告"
    let confirm = "確定"
    let cancel = "取消"
    let error = "錯誤"
    let notice = "通知"
    
    // 句子
    let internet_error_do_you_want_retry = "網路錯誤，是否重試"
    let initiate_transaction = "正在啟動交易"
    let transactioning_please_try_later = "尚有交易進行中，請稍後再試"
    let trying_to_complete_last_transaction = "正在完成上一次交易"
    let exchanging_point = "正在進行點數轉換"
    let transaction_fail = "交易驗證失敗，是否重試?"
    let transaction_success = "交易成功"
    let verifying = "驗證中"
    let the_following_are_veriry_fail_list = "以下交易序號錯誤，請通知們處理"
    let double_ckeck_for_unlock_img = "是否要花費\(unlock_img_point)點數提早解鎖該用戶照片？"
    let get_client_id_error = "獲取用戶名稱錯誤"
    let have_been_unlocked = "已解鎖過該用戶"
    let have_been_unlocked_distance = "已解鎖過距離"
    let insufficient_coin = "餘額不足"
    let unknow_error_20001 = "內部伺服器錯誤 20001"
    let unknow_error_20002 = "內部伺服器錯誤 20002"
    let unknow_error_20003 = "內部伺服器錯誤 20003"
    let create_extra_topic = "預設只能同時存在一個話題，確定要花費\(extra_topic_point)點數開啟額外的新的話題？"
    let too_many_topic_no_auto_close = "話題數太多，請關閉一個話題，並花費\(extra_topic_point)點數開啟新的話題"
    let too_many_topic_please_wait = "話題數太多，可能是您已刪除的話題尚未送到伺服器，請稍後再試"
    let cant_find_del_topic = " 無法找到被刪除的話題"
    let unlock_distance = "請問是否要花費\(unlock_distance_point)點數來解鎖所有用戶的距離計算功能"
    let kilometer = "公里"
    let free_extra_topic_will_out = "交易完成，vip解鎖照片額度已用盡"
    
    func too_many_topic(close_topic_title:String) -> String{
        return "話題數太多，是否要關閉話題：\(close_topic_title)，並花費\(extra_topic_point)點數開啟新的話題"
    }
}







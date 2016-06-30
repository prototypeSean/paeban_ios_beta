//
//  TopicTableViewController.swift
//  paeban_ios_test_3
//
//  Created by 尚義 高 on 2016/5/5.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit
import Starscream
public var tagList:[String] = []

// 所有話題清單 其實不是tabelveiw 是 UIview
class TopicTableViewController:UIViewController, ＨttpResquestDelegate,UITableViewDelegate, UITableViewDataSource,webSocketActiveCenterDelegate, UISearchBarDelegate, TopicSearchControllerDelegate{
    // MARK: Properties
    
    var topicSearchController: TopicSearchController!
    
    // 用來控制要顯示上面哪個清單
    var shouldShowSearchResults = false
    
    // 所有清單 ＆ 資料來源
    var dataArray = [String]()
    
    // 搜尋時的清單 ＆ 資料來源
    var filteredArray = [String]()

    
    @IBOutlet weak var topicList: UITableView!
    
    @IBOutlet weak var isMe: UIImageView!
    
    
    var topics:[Topic] = []
    var httpOBJ = ＨttpRequsetCenter()
    var requestUpDataSwitch = true
    
    
    //var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        //loadSampleTopics()
        
        // 具體要怎麼作 由這個class自己來決定
        httpOBJ.delegate = self
        topicList.delegate = self
        topicList.dataSource = self
        wsActive.wsActiveDelegateForTopicView = self
        //socket.delegate = self
        
        let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
        dispatch_async(dispatch_get_global_queue(qos,0)){ () -> Void in
            self.httpOBJ.getTopic()
            dispatch_async(dispatch_get_main_queue(), {
                let temp_topic = self.httpOBJ.topic_list
                self.topics = self.topics + temp_topic
                self.topicList.reloadData()
            })
        }
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(TopicTableViewController.update), forControlEvents: UIControlEvents.ValueChanged)
        topicList.addSubview(refreshControl)
        configureTopicSearchController()
        
        // 我不知道為什麼-1 就可以了 高度明明是35....
        topicList.contentInset = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0)

        
    }
    // MARk:更新程式
    func update(refreshControl:UIRefreshControl){
        if requestUpDataSwitch == true{
            self.requestUpDataSwitch = false
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            dispatch_async(dispatch_get_global_queue(qos,0)){ () -> Void in
                self.httpOBJ.getTopic()
                let temp_topic = self.httpOBJ.topic_list
                self.topics = temp_topic
                dispatch_async(dispatch_get_main_queue(), {
                    //print(self.topics[0].hashtags)
                    self.topicList.reloadData()
                    refreshControl.endRefreshing()
                    self.requestUpDataSwitch = true
                })
            }
        }
        else{
            refreshControl.endRefreshing()
        }
    }
    
    func new_topic_did_load(http_obj:ＨttpRequsetCenter){
        print("websocket data did load")
    }
    
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return topics.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let topic = topics[indexPath.row]
//        tagList = topic.hashtags!
//        print(tagList)
        let cellIdentifier = "TopicCellTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TopicCellTableViewCell
        cell.hashtags.tagListInContorller = topic.hashtags
        cell.hashtags.drawButton()
        cell.topicTitle.text = topic.title
        cell.topicOwnerImage.image = topic.photo
        
        var isMeImg:UIImage
        if topic.isMe{
            isMeImg = UIImage(named:"True_photo")!
        }
        else{
            isMeImg = UIImage(named:"Fake_photo")!
        }
        cell.isMe.image = isMeImg
        
        
        var sexImg:UIImage
        
        if topic.sex == "男"{
            sexImg = UIImage(named: "male")!
        }
        else if topic.sex == "女"{
            sexImg = UIImage(named: "female")!
        }
        else if topic.sex == "男同"{
            sexImg = UIImage(named:"gay")!
        }
        else{
            sexImg = UIImage(named:"lesbain")!
        }
        cell.sex.image = sexImg
        
        var onlineImg:UIImage
        if topic.online{
            onlineImg = UIImage(named:"texting")!
        }
        //MARK:下面那張圖請改 “不在線上的人圖示”
        else{
            onlineImg = UIImage(named:"topic")!
        }
        cell.online.image = onlineImg

        // Configure the cell...

        return cell
    }
    //-----------test---------
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let scroolHeight = self.topicList.contentOffset.y + self.topicList.frame.height
        let contentHeight = self.topicList.contentSize.height
        if scroolHeight >= contentHeight && contentHeight > 0
            && requestUpDataSwitch == true{
            requestUpDataSwitch = false
            print("撞...撞到最底了 >///<")
            
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            dispatch_async(dispatch_get_global_queue(qos,0)){ () -> Void in
                if !self.topics.isEmpty{
                    var minTopicId:Int = Int(self.topics[0].topicID)!
                    for topicS in self.topics{
                        let topicIdS = Int(topicS.topicID)
                        minTopicId = min(minTopicId, topicIdS!)
                    }
                    print("最小ＩＤ\(String(minTopicId))")
                    self.httpOBJ.getOldTopic(minTopicId)
                }
                
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.topics += self.httpOBJ.topic_list
                    self.topicList.reloadData()
                    self.requestUpDataSwitch = true
                })
            }
        }
    }
    
    //NSIndexPath* ipath = [NSIndexPath indexPathForRow: cells_count-1 inSection: sections_count-1];
    //[tableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
    //-----------test---------
    //MARK:websocketDelegate
    func wsOnMsg(msg:Dictionary<String,AnyObject>) {
        if let msg_type:String =  msg["msg_type"] as? String{
            if msg_type == "off_line"{
                //print(msg)
                let offLineUser = msg["user_id"] as! String
                
                if let topic_sIndex = topics.indexOf({$0.owner==offLineUser}){
                    topics[topic_sIndex].online = false
                    let topicNsIndex = NSIndexPath(forRow: topic_sIndex, inSection:0)
                    self.topicList.reloadRowsAtIndexPaths([topicNsIndex], withRowAnimation: UITableViewRowAnimation.Fade)
                }
                
            }
            else if msg_type == "new_member"{
                //print(msg)
                let onLineUser = msg["user_id"] as! String
                if let topic_sIndex = topics.indexOf({$0.owner==onLineUser}){
                    topics[topic_sIndex].online = true
                    let topicNsIndex = NSIndexPath(forRow: topic_sIndex, inSection:0)
                    self.topicList.reloadRowsAtIndexPaths([topicNsIndex], withRowAnimation: UITableViewRowAnimation.Fade)
                }
            }
        }
        
    }
    
    // MARK: 設定搜尋列
    func configureTopicSearchController() {
        topicSearchController = TopicSearchController(
            searchResultsController: self,
            searchBarFrame: CGRectMake(0.0, 0.0, topicList.frame.size.width, 40.0),
            searchBarFont: UIFont(name: "Futura", size: 14.0)!,
            searchBarTextColor: UIColor.orangeColor(),
            searchBarTintColor: UIColor.blackColor())
        
        topicSearchController.customSearchBar.placeholder = "搜尋"
        
        topicList.tableHeaderView = topicSearchController.customSearchBar
        
        topicSearchController.customDelegate = self
    }
    
    // 客製化的代理功能在這
    
    func didStartSearching() {
        shouldShowSearchResults = true
        topicList.reloadData()
    }
    
    
    func didTapOnSearchButton() {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            topicList.reloadData()
        }
    }
    
    func didTapOnCancelButton() {
        shouldShowSearchResults = false
        topicList.reloadData()
    }
    
    func didChangeSearchText(searchText: String) {
        // Filter the data array and get only those countries that match the search text.
        filteredArray = dataArray.filter({ (country) -> Bool in
            let countryText: NSString = country
            
            return (countryText.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch).location) != NSNotFound
        })
        
        // Reload the tableview.
        topicList.reloadData()
    }
    
}


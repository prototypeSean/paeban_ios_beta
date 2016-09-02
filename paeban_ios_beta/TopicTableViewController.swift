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
class TopicTableViewController:UIViewController, ＨttpResquestDelegate,UITableViewDelegate, UITableViewDataSource,webSocketActiveCenterDelegate, UISearchBarDelegate, TopicSearchControllerDelegate,TopicViewControllerDelegate{
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
        wsActive.wsad_ForTopicTableViewController = self
        gettopic()
        //socket.delegate = self
        
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(TopicTableViewController.update), forControlEvents: UIControlEvents.ValueChanged)
        topicList.addSubview(refreshControl)
        configureTopicSearchController()
        
        // 我不知道為什麼-1 就可以了 高度明明是35....
        topicList.contentInset = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0)

    }
    
    // MARk:更新程式
    private func gettopic(){
        let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
        dispatch_async(dispatch_get_global_queue(qos,0)){ () -> Void in
            var temp_topic:Array<Topic>{
                get{
                    return []
                }
                set{
                    dispatch_async(dispatch_get_main_queue(), {
                        for newValue_s in newValue{
                            if newValue_s.owner != userData.id{
                                self.topics += [newValue_s]
                            }
                        }

                        self.topicList.reloadData()
                    })
                }
            }
            self.httpOBJ.getTopic({ (temp_topic2) in
                temp_topic = temp_topic2
            })
        }
    }
    
    func update(refreshControl:UIRefreshControl?){
        if requestUpDataSwitch == true{
            print("updataing")
            self.requestUpDataSwitch = false
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            dispatch_async(dispatch_get_global_queue(qos,0)){ () -> Void in
                var temp_topic:Array<Topic>{
                    get{
                        return []
                    }
                    set{
                        dispatch_async(dispatch_get_main_queue(), {
                            self.topics = []
                            for newValue_s in newValue{
                                if newValue_s.owner != userData.id{
                                    self.topics += [newValue_s]
                                }
                            }
                            self.topicList.reloadData()
                            refreshControl?.endRefreshing()
                            self.requestUpDataSwitch = true
                        })
                    }
                }
                self.httpOBJ.getTopic({ (temp_topic2) in
                    temp_topic = temp_topic2
                })
                
            }
        }
        else{
            refreshControl?.endRefreshing()
        }
        
    }
    
    func new_topic_did_load(http_obj:ＨttpRequsetCenter){
        //print("websocket data did load")
    }
    
    // MARK: TableView 的內建功能
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let indexPath = topicList.indexPathForSelectedRow!
        let dataposition:Int = indexPath.row
        let ownerID = topics[dataposition].owner
        let turnedTopicData = turnTopicDataType(topics[dataposition])
        addTopicCellToPublicList(turnedTopicData)
        if userData.id == ownerID{
            performSegueWithIdentifier("masterModeSegue", sender: self)
        }
        else{
            performSegueWithIdentifier("clientModeSegue", sender: self)
        }
        
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
        cell.topicOwner.text = topic.ownerName
        cell.topicOwnerImage.image = topic.photo
        
        var isMeImg:UIImage
        if topic.isMe{isMeImg = UIImage(named:"True_photo")!}
        else{isMeImg = UIImage(named:"Fake_photo")!}
        cell.isMe.image = isMeImg
        var sexImg:UIImage?
        switch topic.sex {
        case "男":
            sexImg = UIImage(named: "male")!
        case "女":
            sexImg = UIImage(named:"gay")!
        case "男同":
            sexImg = UIImage(named:"gay")!
        case "女同":
            sexImg = UIImage(named:"lesbain")!
        default:
            sexImg = UIImage(named: "male")!
            print("性別圖示分類失敗")
        }
        
        
        cell.sex.image = sexImg
        
        cell.online.image = UIImage(named:"texting")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)

        if topic.online{
            cell.online.tintColor = UIColor(red:0.98, green:0.43, blue:0.32, alpha:1.0)
        }
        //MARK:下面那張圖請改 “不在線上的人圖示”
        else{
            cell.online.tintColor = UIColor.grayColor()
        }
//        cell.online.image = onlineimage.image
        // Configure the cell...
        
        
        
        return cell
    }
    
    // MARK: 向下滾動更新
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let scroolHeight = self.topicList.contentOffset.y + self.topicList.frame.height
        let contentHeight = self.topicList.contentSize.height
        if scroolHeight >= contentHeight && contentHeight > 0
            && requestUpDataSwitch == true{
            requestUpDataSwitch = false
            //print("撞...撞到最底了 >///<")
            
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            dispatch_async(dispatch_get_global_queue(qos,0)){ () -> Void in
                if !self.topics.isEmpty{
                    
                    var minTopicId:Int = Int(self.topics[0].topicID)!
                    for topicS in self.topics{
                        let topicIdS = Int(topicS.topicID)
                        minTopicId = min(minTopicId, topicIdS!)
                    }
                    //print("最小ＩＤ\(String(minTopicId))")
                    var temp_topic:[Topic]{
                        get{return []}
                        set{
                            dispatch_async(dispatch_get_main_queue(), {
                                self.topics += newValue
                                self.topicList.reloadData()
                                self.requestUpDataSwitch = true
                            })
                        }
                    }
                    self.httpOBJ.getOldTopic(minTopicId, topicData: { (temp_topic2) in
                        temp_topic = temp_topic2
                    })
                }
                else{
                    self.requestUpDataSwitch = true
                }
                
            }
        }
    }
        //NSIndexPath* ipath = [NSIndexPath indexPathForRow: cells_count-1 inSection: sections_count-1];
    //[tableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];

    // MARK: websocketDelegate
    func wsOnMsg(msg:Dictionary<String,AnyObject>) {
        if let msg_type:String =  msg["msg_type"] as? String{
            //有人離線
            if msg_type == "off_line"{
                let offLineUser = msg["user_id"] as! String
                
                if let topic_sIndex = topics.indexOf({$0.owner==offLineUser}){
                    topics[topic_sIndex].online = false
                    let topicNsIndex = NSIndexPath(forRow: topic_sIndex, inSection:0)
                    self.topicList.reloadRowsAtIndexPaths([topicNsIndex], withRowAnimation: UITableViewRowAnimation.Fade)
                }
                
            }
                
            //有人上線
            else if msg_type == "new_member"{
                let onLineUser = msg["user_id"] as! String
                if let topic_sIndex = topics.indexOf({$0.owner==onLineUser}){
                    topics[topic_sIndex].online = true
                    let topicNsIndex = NSIndexPath(forRow: topic_sIndex, inSection:0)
                    self.topicList.reloadRowsAtIndexPaths([topicNsIndex], withRowAnimation: UITableViewRowAnimation.Fade)
                }
            }
                
            //關閉話題
            else if msg_type == "topic_closed"{
                let closeTopicIdList:Array<String>? = msg["topic_id"] as? Array
                if closeTopicIdList != nil{
                    var removeTopicIndexList:Array<Int> = []
                    for closeTopicId in closeTopicIdList!{
                        let closeTopicIndex = topics.indexOf({ (Topic) -> Bool in
                            if Topic.topicID == closeTopicId{
                                return true
                            }
                            else{return false}
                        })
                        if closeTopicIndex != nil{
                            removeTopicIndexList.append(closeTopicIndex! as Int)
                        }
                    }
                    removeTopicIndexList = removeTopicIndexList.sort(>)
                    for removeTopicIndex in removeTopicIndexList{
                        topics.removeAtIndex(removeTopicIndex)
                    }
                    topicList.reloadData()
                }
            }
            
            //接收到訊息
            else if msg_type == "topic_msg"{
                let resultDic:Dictionary<String,AnyObject> = msg["result_dic"] as! Dictionary
                
                //=====topic_msg=====
                // msg -- msg_type:"topic_msg"
                //     -- img:Dtring
                //     -- result_dic -- sender:String
                //                   -- temp_topic_msg_id
                //                   -- topic_content
                //                   -- receiver
                //                   -- topic_id
                
                //更新最後說話
                
                func updataLastList(dataBase:Array<MyTopicStandardType>,newDic:Dictionary<String,AnyObject>) -> Array<MyTopicStandardType>?{
                    var topicWho = newDic["sender"] as! String
                    var returnData = dataBase
                    if topicWho == userData.id{
                        topicWho = newDic["receiver"] as! String
                    }
                    
                    if let dataIndex = returnData.indexOf({ (target) -> Bool in
                        
                        if target.clientId_detial! == topicWho
                            && target.topicId_title! == newDic["topic_id"] as! String{
                            return true
                        }
                        else{return false}
                    }){
                        returnData[dataIndex].lastLine_detial = newDic["topic_content"] as? String
                        returnData[dataIndex].lastSpeaker_detial = newDic["sender"] as? String
                        return returnData
                    }
                    else{return nil}
                }
                
                if let newDB = updataLastList(nowTopicCellList,newDic: resultDic){
                    nowTopicCellList = newDB
                }
                
            }
        }
        
    }
    
    // MARK: 準備跳頁
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //print(segue.identifier)
        let indexPath = topicList.indexPathForSelectedRow!
        //print(indexPath.row)
        let dataposition:Int = indexPath.row
        
        if segue.identifier == "masterModeSegue"{
            // MARK: master模式看要做啥
        }
        else{
            let topicViewCon = segue.destinationViewController as! TopicViewController
            let selectTopicData = topics[dataposition]
            topicViewCon.topicId = selectTopicData.topicID
            topicViewCon.ownerId = selectTopicData.owner
            topicViewCon.ownerImg = selectTopicData.photo
            topicViewCon.topicTitle = selectTopicData.title
            topicViewCon.title = selectTopicData.ownerName
            topicViewCon.delegate = self
//            topicViewCon.topicTitleContent.text = selectTopicData.title
        }
        
        
        
        //print(topicOwnerID)
        
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
        self.topicSearchController.customSearchBar.showsCancelButton = true
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
        self.topicSearchController.customSearchBar.text = ""
        self.topicSearchController.customSearchBar.setShowsCancelButton(false, animated: true)
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
    
    func reLoadTopic(topicId:String){
        let removeTopicPosition = topics.indexOf { (Topic) -> Bool in
            if Topic.topicID == topicId{
                return true
            }
            else{return false}
        }
        if removeTopicPosition != nil{
            topics.removeAtIndex(removeTopicPosition! as Int)
            topicList.reloadData()
        }
    }
    
    func turnTopicDataType(inputData:Topic) -> MyTopicStandardType{
        let returnData = MyTopicStandardType(dataType: "detail")
        returnData.topicTitle_title = inputData.title
        returnData.topicId_title = inputData.topicID
        returnData.clientId_detial = inputData.owner
        returnData.clientName_detial = inputData.ownerName
        returnData.clientPhoto_detial = inputData.photo
        returnData.clientIsRealPhoto_detial = inputData.isMe
        returnData.clientSex_detial = inputData.sex
        //print("topic table VC")
        //print(inputData.online)
        returnData.clientOnline_detial = inputData.online
        returnData.tag_detial = inputData.hashtags
        

        return returnData
    }
}









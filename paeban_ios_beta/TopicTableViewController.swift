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
class TopicTableViewController:UIViewController, HttpRequestCenterDelegate,UITableViewDelegate, UITableViewDataSource,webSocketActiveCenterDelegate, UISearchBarDelegate, TopicSearchControllerDelegate,TopicViewControllerDelegate{
    // MARK: Properties
    var topicSearchController: TopicSearchController?
    // 用來控制要顯示上面哪個清單
    var shouldShowSearchResults = false
    
    // 搜尋時的清單 ＆ 資料來源
    @IBOutlet weak var topicList: UITableView!
    @IBOutlet weak var isMe: UIImageView!
    @IBAction func new_topic(_ sender: AnyObject) {
        switchEditTopicArea()
    }
    @IBOutlet weak var editArea: UIView!
    @IBAction func testBtn(_ sender: AnyObject) {
        
        leap(from: self, to: 2)
        
    }
    var filteredArray = [String]()
    var searchKeyAndState:Dictionary<String,String?> = ["key": nil, "smallest_id": "init", "state": "none"]
    var dataArray = [String]()
    var topics:[Topic] = []
    var topicsBackup:Array<Topic> = []
    var httpOBJ = HttpRequestCenter()
    var requestUpDataSwitch = true
    // MARK:override
    override func viewDidLoad() {
        super.viewDidLoad()
        //loadSampleTopics()
        // 具體要怎麼作 由這個class自己來決定
        httpOBJ.delegate = self
        topicList.delegate = self
        topicList.dataSource = self
        wsActive.wsad_ForTopicTableViewController = self
        //socket.delegate = self
        open_app_frist = false
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(TopicTableViewController.update), for: UIControlEvents.valueChanged)
        topicList.addSubview(refreshControl)
        configureTopicSearchController()
        
        // 我不知道為什麼-1 就可以了 高度明明是35....
        topicList.contentInset = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0)
        
    }
        // 覆蓋掉故事板的初始設定顯示
    override func viewDidLayoutSubviews() {
        initAddTopicArea()
    }
        // 從聊天視窗回到清單把cell的反灰取消
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gettopic()
        if let path = topicList.indexPathForSelectedRow {
            topicList.deselectRow(at: path, animated: true)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //print(segue.identifier)
        // 轉跳頁面時，收起鍵盤跟開話題的視窗（如果有的話）
        self.editArea.isHidden = true
        dismissKeyboard()
        if segue.identifier == "clientModeSegue"{
            let indexPath = topicList.indexPathForSelectedRow!
            let dataposition:Int = (indexPath as NSIndexPath).row
            
            if segue.identifier == "masterModeSegue"{
                // MARK: master模式看要做啥
            }
            else{
                let topicViewCon = segue.destination as! TopicViewController
                let selectTopicData = topics[dataposition]
                topicViewCon.topicId = selectTopicData.topicID
                topicViewCon.ownerId = selectTopicData.owner
                topicViewCon.ownerImg = selectTopicData.photo
                topicViewCon.topicTitle = selectTopicData.title
                topicViewCon.title = selectTopicData.ownerName
                topicViewCon.setID = selectTopicData.owner
                topicViewCon.setName = selectTopicData.ownerName
                topicViewCon.delegate = self
                
                //            topicViewCon.topicTitleContent.text = selectTopicData.title
            }
        }
        
        //print(topicOwnerID)
        
    }
    
    
    // MARk:internal function
    fileprivate func gettopic(){
        //let qos = Int(DispatchQoS.QoSClass.userInitiated.rawValue)
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async{ () -> Void in
            self.httpOBJ.getTopic({ (temp_topic2) in
                DispatchQueue.main.async {
                    var temp_topic:Array<Topic> = []
                    for temp_topic2_s in temp_topic2{
                        if temp_topic2_s.owner != userData.id{
                            temp_topic.append(temp_topic2_s)
                        }
                    }
                    self.topics = temp_topic
                    self.topicList.reloadData()
                }
                
            })
        }
    }
    func update(_ refreshControl:UIRefreshControl?){
        if requestUpDataSwitch == true{
            print("updataing")
            self.requestUpDataSwitch = false
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async{ () -> Void in
                var temp_topic:Array<Topic>{
                    get{
                        return []
                    }
                    set{
                        DispatchQueue.main.async(execute: {
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
    func new_topic_did_load(_ http_obj:HttpRequestCenter){
        //print("websocket data did load")
    }
    func initAddTopicArea(){
        self.editArea.isHidden = true
    }
        //開新話題
    func switchEditTopicArea(){
//        self.editArea.isHidden = false
        // 不能用清單寬度因為被我動過，要用最外層VIEW
        let parent_width = self.view.frame.size.width
        func editArea_position_init(){
            self.editArea.frame = CGRect(x: 10, y: -50, width: parent_width-20, height: 50)
        }
        func editArea_position_set(){
            self.editArea.frame = CGRect(x: 10, y: 5, width: parent_width-20, height: 50)
        }
        if self.editArea.isHidden{
            editArea_position_init()
            self.editArea.isHidden = false
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
                editArea_position_set()
            }) { (finish) in
                //sss()
            }
        }
        else{
            self.editArea.isHidden = true
            dismissKeyboard()
        }
        
        
        
    }
    
    
    // MARK: delegate -> TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = topicList.indexPathForSelectedRow!
        let dataposition:Int = (indexPath as NSIndexPath).row
        let ownerID = topics[dataposition].owner
        let turnedTopicData = turnTopicDataType(topics[dataposition])
        addTopicCellToPublicList(turnedTopicData)
        if userData.id == ownerID{
            performSegue(withIdentifier: "masterModeSegue", sender: self)
        }
        else{
            performSegue(withIdentifier: "clientModeSegue", sender: self)
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return topics.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // MARK: 開始設定CELL跟裡面的圖示
        // Table view cells are reused and should be dequeued using a cell identifier.
        let topic = topics[(indexPath as NSIndexPath).row]
//        tagList = topic.hashtags!
//        print(tagList)
        let cellIdentifier = "TopicCellTableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TopicCellTableViewCell
        cell.hashtags.tagListInContorller = topic.hashtags
        cell.hashtags.drawButton()
        cell.topicTitle.text = topic.title
        cell.topicOwner.text = topic.ownerName
        cell.topicOwnerImage.image = topic.photo
        // 本人照片
        cell.isMe.layoutIfNeeded()
        cell.isMe.image = UIImage(named:"True_photo")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        cell.isMe.layer.cornerRadius = cell.isMe.frame.size.width/2
        cell.isMe.clipsToBounds = true
        if topic.isMe{
            cell.isMe.tintColor = UIColor.white
        }
        else{
            cell.isMe.tintColor = UIColor.clear
            cell.isMe.backgroundColor = UIColor.clear
        }
        // 性別圖示
        var sexImg:UIImage?
        switch topic.sex {
        case "男":
            sexImg = UIImage(named: "male")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            cell.sex.tintColor = UIColor(red:0.27, green:0.71, blue:0.88, alpha:1.0)
        case "女":
            sexImg = UIImage(named:"female")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            cell.sex.tintColor = UIColor(red:1.00, green:0.49, blue:0.42, alpha:1.0)
        case "男同":
            sexImg = UIImage(named:"gay")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            cell.sex.tintColor = UIColor(red:0.27, green:0.71, blue:0.88, alpha:1.0)
        case "女同":
            sexImg = UIImage(named:"lesbain")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            cell.sex.tintColor = UIColor(red:1.00, green:0.49, blue:0.42, alpha:1.0)
        default:
            sexImg = UIImage(named: "male")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            print("性別圖示分類失敗")
        }
        cell.sex.image = sexImg
        // 電池圖示設定
        cell.battery.image = UIImage(named:"battery-full")
//        cell.battery.tintColor = UIColor(red:0.18, green:0.80, blue:0.44, alpha:1.0)
        // 在線上燈號
        cell.online.layoutIfNeeded()
        cell.online.image = UIImage(named:"online")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        let cr = (cell.online.frame.size.width)/2
        cell.online.layer.borderWidth = 1
        cell.online.layer.borderColor = UIColor.white.cgColor
        cell.online.layer.cornerRadius = cr
        cell.online.clipsToBounds = true
        
        
        
        if topic.online{
            cell.online.tintColor = UIColor(red:0.15, green:0.88, blue:0.77, alpha:1.0)
        }
        else{
            cell.online.tintColor = UIColor.lightGray
        }
        // Configure the cell...
        
        
        
        return cell
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        hideKeybroad()
        let scroolHeight = self.topicList.contentOffset.y + self.topicList.frame.height
        let contentHeight = self.topicList.contentSize.height
        if scroolHeight >= contentHeight && contentHeight > 0
            && requestUpDataSwitch == true{
            requestUpDataSwitch = false
            //print("撞...撞到最底了 >///<")
            
            
            DispatchQueue.global(qos:DispatchQoS.QoSClass.default).async{ () -> Void in
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
                            DispatchQueue.main.async(execute: {
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
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let block_btn = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "封鎖") { (UITableViewRowAction_parameter, IndexPath_parameter) in
            func excute(){
                let data = self.topics[IndexPath_parameter.row]
                self.block_user(setID: data.owner, topicId: data.topicID)
                self.remove_cell(index: IndexPath_parameter.row)
            }
            // MARK: 改alert
            let owner_name = self.topics[IndexPath_parameter.row].ownerName
            self.conform_excute(title: "封鎖", msg: "封鎖 \(owner_name)？ 將再也無法聯繫他", yes_func: excute)
            
        }
        let report_btn = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "舉報") { (UITableViewRowAction_parameter, IndexPath_parameter) in
            func excute(){
                let id = self.topics[IndexPath_parameter.row].owner
                let topic_id = self.topics[IndexPath_parameter.row].topicID
                self.report(setID: id, topicId: topic_id)
            }
            // MARK: 改alert
            let owner_name = self.topics[IndexPath_parameter.row].ownerName
            self.conform_excute(title: "舉報", msg: "向管理員反應收到  \(owner_name) 的騷擾內容", yes_func: excute)
        }
        block_btn.backgroundColor = UIColor.red
        report_btn.backgroundColor = UIColor.black
        return [block_btn, report_btn]
    }
    func block_user(setID:String, topicId:String){
        let data:NSDictionary = [
            "block_id":setID,
            "topic_id":topicId
        ]
        HttpRequestCenter().privacy_function(msg_type:"block", send_dic: data) { (Dictionary) in
            if let _ = Dictionary.index(where: { (key: String, value: AnyObject) -> Bool in
                if key == "msgtype"{
                    return true
                }
                else{return false}
            }){
                if Dictionary["msgtype"] as! String == "block_success"{
                    //code
                }
            }
        }
    }
    func remove_cell(index:Int) {
        let cell_index_path = IndexPath(row: index, section: 0)
        topics.remove(at: index)
        topicList.beginUpdates()
        topicList.deleteRows(at: [cell_index_path], with: .left)
        topicList.endUpdates()
    }
    func report(setID:String, topicId:String){
        let sendDic:NSDictionary = [
            "report_id":setID,
            "topic_id":topicId
        ]
        HttpRequestCenter().privacy_function(msg_type: "report_topic_title", send_dic: sendDic, inViewAct: { (Dictionary) in
            let msg_type = Dictionary["msg_type"] as! String
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.default, handler: nil))
            if msg_type == "success"{
                alert.title = "舉報"
                alert.message = "感謝您的回報，我們將儘速處理"
                
            }
            else if msg_type == "user_not_exist"{
                alert.title = "錯誤"
                alert.message = "用戶不存在"
            }
            else if msg_type == "topic_not_exist"{
                alert.title = "錯誤"
                alert.message = "話題不存在"
            }
            else if msg_type == "unknown_error"{
                alert.title = "錯誤"
                alert.message = "未知的錯誤"
            }
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
                
            }
        })
    }
    func conform_excute(title:String, msg:String, yes_func:@escaping ()->Void){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: { (_) in
            yes_func()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // socket
    func wsOnMsg(_ msg:Dictionary<String,AnyObject>) {
        if let msg_type:String =  msg["msg_type"] as? String{
            //有人離線
            if msg_type == "off_line"{
                let offLineUser = msg["user_id"] as! String
                
                // 更新本頁資料
                if let topic_sIndex = topics.index(where: {$0.owner==offLineUser}){
                    topics[topic_sIndex].online = false
                    let topicNsIndex = IndexPath(row: topic_sIndex, section:0)
                    self.topicList.reloadRows(at: [topicNsIndex], with: UITableViewRowAnimation.fade)
                }
                
                //更新recenttopic資料
                for recentDataBaseIndex in 0..<nowTopicCellList.count{
                    if offLineUser == nowTopicCellList[recentDataBaseIndex].clientId_detial{
                        nowTopicCellList[recentDataBaseIndex].clientOnline_detial = false
                    }
                }
            }
                
            //有人上線
            else if msg_type == "new_member"{
                let onLineUser = msg["user_id"] as! String
                // 更新本頁資料
                if let topic_sIndex = topics.index(where: {$0.owner==onLineUser}){
                    topics[topic_sIndex].online = true
                    let topicNsIndex = IndexPath(row: topic_sIndex, section:0)
                    self.topicList.reloadRows(at: [topicNsIndex], with: UITableViewRowAnimation.fade)
                }
                
                //更新recenttopic資料
                if let _ = nowTopicCellList.index(where: { (target) -> Bool in
                    if target.clientId_detial == onLineUser{
                        return true
                    }
                    else{return false}
                }){
                    for recentDataBaseIndex in 0..<nowTopicCellList.count{
                        if onLineUser == nowTopicCellList[recentDataBaseIndex].clientId_detial{
                            nowTopicCellList[recentDataBaseIndex].clientOnline_detial = true
                        }
                    }
                }
            }
                
            //關閉話題
            else if msg_type == "topic_closed"{
                let closeTopicIdList:Array<String>? = msg["topic_id"] as? Array
                
                if closeTopicIdList != nil{
                    // 更新本頁資料
                    var removeTopicIndexList:Array<Int> = []
                    for closeTopicId in closeTopicIdList!{
                        let closeTopicIndex = topics.index(where: { (Topic) -> Bool in
                            if Topic.topicID == closeTopicId{
                                return true
                            }
                            else{return false}
                        })
                        if closeTopicIndex != nil{
                            removeTopicIndexList.append(closeTopicIndex! as Int)
                        }
                    }
                    removeTopicIndexList = removeTopicIndexList.sorted(by: >)
                    for removeTopicIndex in removeTopicIndexList{
                        topics.remove(at: removeTopicIndex)
                    }
                    topicList.reloadData()
                    
                    //更新recenttopic資料
                    var removeTopicIndexList2:Array<Int> = []
                    for closeTopicId in closeTopicIdList!{
                        let closeTopicIndex = nowTopicCellList.index(where: { (target) -> Bool in
                            if target.topicId_title == closeTopicId{
                                return true
                            }
                            else{return false}
                        })
                        if closeTopicIndex != nil{
                            removeTopicIndexList2.append(closeTopicIndex! as Int)
                        }
                    }
                    removeTopicIndexList2 = removeTopicIndexList2.sorted(by: >)
                    for removeTopicIndex in removeTopicIndexList2{
                        nowTopicCellList.remove(at: removeTopicIndex)
                    }
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
                
                func updataLastList(_ dataBase:Array<MyTopicStandardType>,newDic:Dictionary<String,AnyObject>) -> Array<MyTopicStandardType>?{
                    var topicWho = newDic["sender"] as! String
                    var returnData = dataBase
                    if topicWho == userData.id{
                        topicWho = newDic["receiver"] as! String
                    }
                    
                    if let dataIndex = returnData.index(where: { (target) -> Bool in
                        
                        if target.clientId_detial! == topicWho
                            && target.topicId_title! == newDic["topic_id"] as! String{
                            return true
                        }
                        else{return false}
                    }){
                        returnData[dataIndex].lastLine_detial = newDic["topic_content"] as? String
                        returnData[dataIndex].lastSpeaker_detial = newDic["sender"] as? String
                        let tempData = returnData[dataIndex]
                        returnData.remove(at: dataIndex)
                        returnData.insert(tempData, at: 0)
                        
                        return returnData
                    }
                    else{return nil}
                }
                for resultDic_s in resultDic{
                    if let newDB = updataLastList(nowTopicCellList,newDic: resultDic_s.1 as! Dictionary<String,AnyObject>){
                        nowTopicCellList = newDB
                    }
                }
                
                
            }
            
            //接收新搜尋
            else if msg_type == "search_topic"{
                
                func transformToTopicType(_ inputDic:Dictionary<String,AnyObject>) -> Array<Topic>{
                    var tempTopicIdList:Array<Int> = []
                    for returnDic_s in inputDic{
                        if let tempTopicId = Int(returnDic_s.0){
                            tempTopicIdList.append(tempTopicId)
                        }
                    }
                    tempTopicIdList.sort(by: >)
                    var topic_list_temp:Array<Topic> = []
                    for tempTopicId in tempTopicIdList{
                        let encodedImageData = inputDic[String(tempTopicId)]!["img"] as! String
                        
                        let decodedimage = base64ToImage(encodedImageData)
                        
                        var finalimg:UIImage
                        if decodedimage != nil{
                            finalimg = decodedimage!
                        }
                        else{
                            finalimg = UIImage(named: "logo")!
                        }
                        //--base64--end
                        var isMe:Bool = false
                        var online:Bool = false
                        
                        if inputDic[String(tempTopicId)]!["is_me"] as! Bool == true{
                            isMe = true
                        }
                        if inputDic[String(tempTopicId)]!["online"] as! Bool == true{
                            online = true
                        }
                        
                        
                        let topic_temp = Topic(
                            owner: inputDic[String(tempTopicId)]!["topic_publisher"] as! String,
                            photo: finalimg,
                            title: inputDic[String(tempTopicId)]!["title"] as! String,
                            hashtags: inputDic[String(tempTopicId)]!["tag"] as! Array,
                            lastline:"最後一句對話" ,
                            topicID: String(tempTopicId),
                            sex:inputDic[String(tempTopicId)]!["sex"] as! String,
                            isMe:isMe,
                            online:online,
                            ownerName:inputDic[String(tempTopicId)]!["name"] as! String
                            )!
                        topic_list_temp.append(topic_temp)
                    }
                    return topic_list_temp
                    
                }
                func getSmallestId(_ inputDic:Dictionary<String,AnyObject>) -> Int?{
                    var tempTopicIdList:Array<Int> = []
                    for returnDic_s in inputDic{
                        if let tempTopicId = Int(returnDic_s.0){
                            tempTopicIdList.append(tempTopicId)
                        }
                    }
                    tempTopicIdList.sort(by: >)
                    if tempTopicIdList.count > 0{
                        return tempTopicIdList[tempTopicIdList.count-1]
                    }
                    else{return nil}
                }
                // 找最小id
                if let tempTopicId = getSmallestId(msg["return_dic"] as! Dictionary<String,AnyObject>){
                    searchKeyAndState["smallest_id"]! = String(tempTopicId)
                }
                
                
                if searchKeyAndState["state"]! == "new"{
                    //如果是新的搜尋
                    
                    //UI
                    topics = transformToTopicType(msg["return_dic"] as! Dictionary<String,AnyObject>)
                    topicList.reloadData()
                    
                }
                else if searchKeyAndState["state"]! == "keep"{
                    topics += transformToTopicType(msg["return_dic"] as! Dictionary<String,AnyObject>)
                }
            }
            else if msg_type == "friend_confirm"{
                fast_alter(inviter: (msg["sender_name"] as? String)!, nav_controller: self.parent as! UINavigationController)
            }
            
            
        }
        
    }
    
    
    

    // MARK: =====以下高義區=====
    // MARK: 設定搜尋列
    func configureTopicSearchController() {
        topicSearchController = TopicSearchController(
            searchResultsController: self,
            searchBarFrame: CGRect(x: 0.0, y: 0.0, width: topicList.frame.size.width, height: 40.0),
            searchBarFont: UIFont(name: "Futura", size: 14.0)!,
            searchBarTextColor: UIColor.orange,
            searchBarTintColor: UIColor.black)
        //configureSearchBar
        
        topicSearchController?.customSearchBar.placeholder = "搜尋"
        
        topicList.tableHeaderView = topicSearchController?.customSearchBar
        
        topicSearchController?.customDelegate = self
    }
    
    // 客製化的代理功能在這
    func didStartSearching(_ searchBar: UISearchBar) {
        //點了搜尋按鈕
    }
    func didTapOnSearchButton(_ searchBar: UISearchBar) {
        //開始查詢
        if searchBar.text != nil{
            if searchKeyAndState["state"]! == "none"{
                topicsBackup = topics
            }
            searchKeyAndState["smallest_id"] = "init"
            searchKeyAndState["key"] = searchBar.text!
            searchKeyAndState["state"] = "new"
            let sendData:NSDictionary = ["msg_type":"search_topic",
                                         "string":searchBar.text!,
                                         "smallest_id":searchKeyAndState["smallest_id"]!!
            ]
            
            socket.write(data:json_dumps(sendData))
        }
    }
    func didTapOnCancelButton(_ searchBar: UISearchBar) {
        //刪除查詢
    }
    func didChangeSearchText(_ searchBar: UISearchBar) {
        // 打字一次搜尋一次
        if searchBar.text != nil{
            if searchBar.text == ""{
                searchKeyAndState["smallest_id"]! = "init"
                searchKeyAndState["key"]! = nil
                searchKeyAndState["state"]! = "none"
                if topicsBackup.count > 0{
                    topics = topicsBackup
                    topicList.reloadData()
                }
                // MARK:硬幹收鍵盤 延遲10ms收鍵盤
                let timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.hideKeybroad), userInfo: nil, repeats: false)
                RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)

            }
        }
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    func hideKeybroad() {
        topicSearchController?.customSearchBar.resignFirstResponder()
    }
    func reLoadTopic(_ topicId:String){
        let removeTopicPosition = topics.index { (Topic) -> Bool in
            if Topic.topicID == topicId{
                return true
            }
            else{return false}
        }
        if removeTopicPosition != nil{
            topics.remove(at: removeTopicPosition! as Int)
            topicList.reloadData()
        }
    }
    func turnTopicDataType(_ inputData:Topic) -> MyTopicStandardType{
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









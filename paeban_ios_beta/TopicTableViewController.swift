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
class TopicTableViewController:UIViewController, ＨttpResquestDelegate,UITableViewDelegate, UITableViewDataSource,webSocketActiveCenterDelegate{
    // MARK: Properties
    
    @IBOutlet weak var newTopicInput: UITextField!
    
    @IBAction func newTopicBtn(sender: AnyObject) {
    }
    
    @IBOutlet weak var searchTagInput: UITextField!
    
    
    @IBAction func searchTagBtn(sender: AnyObject) {
    }
    
    @IBOutlet weak var topicList: UITableView!
    
    @IBOutlet weak var isMe: UIImageView!
    
    
    var topics:[Topic] = []
    var httpOBJ = ＨttpRequsetCenter()
    var requestUpDataSwitch = true
    
    
    //var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        //loadSampleTopics()
        httpOBJ.delegate = self
        topicList.delegate = self
        topicList.dataSource = self
        wsActive.wsad_ForTopicTableViewController = self
        gettopic()
        //socket.delegate = self
        
        
        
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
                        self.topics = self.topics + newValue
                        self.topicList.reloadData()
                    })
                }
            }
            self.httpOBJ.getTopic({ (temp_topic2) in
                temp_topic = temp_topic2
            })
            
        }
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(TopicTableViewController.update), forControlEvents: UIControlEvents.ValueChanged)
        topicList.addSubview(refreshControl)
    }
    
    func update(refreshControl:UIRefreshControl){
        if requestUpDataSwitch == true{
            self.requestUpDataSwitch = false
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            dispatch_async(dispatch_get_global_queue(qos,0)){ () -> Void in
                var temp_topic:Array<Topic>{
                    get{
                        return []
                    }
                    set{
                        dispatch_async(dispatch_get_main_queue(), {
                            self.topics = self.topics + newValue
                            self.topicList.reloadData()
                            refreshControl.endRefreshing()
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
            refreshControl.endRefreshing()
        }
    }
    
    func new_topic_did_load(http_obj:ＨttpRequsetCenter){
        //print("websocket data did load")
    }
    
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    //MARK
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let indexPath = topicList.indexPathForSelectedRow!
        let dataposition:Int = indexPath.row
        let ownerID = topics[dataposition].owner
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
        var onlineImg:UIImage
        if topic.online{onlineImg = UIImage(named:"texting")!}
        //MARK:下面那張圖請改 “不在線上的人圖示”
        else{
            onlineImg = UIImage(named:"topic")!
        }
        cell.online.image = onlineImg

        // Configure the cell...

        return cell
    }
    // MARK:向下滾動更新
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
            }
        }
    }
    
    //NSIndexPath* ipath = [NSIndexPath indexPathForRow: cells_count-1 inSection: sections_count-1];
    //[tableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];

    
    //MARK:websocketDelegate
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
        }
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print(segue.identifier)
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
            topicViewCon.title = "你要插啥？"
            
            
            
//            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
//            dispatch_async(dispatch_get_global_queue(qos,0)){ () -> Void in
//                let httpObj = ＨttpRequsetCenter()
//                httpObj.getTopicContentHistory(selectTopicData.owner,topicId: selectTopicData.topicID, InViewAct: { (returnData2) in
//                    //                returnData2:
//                    //                unblock_level
//                    //                img
//                    //                my_img
//                    //                msg
//                    let myImg = base64ToImage(returnData2["my_img"] as! String)
//                    
//                    let msg = returnData2["msg"] as! Dictionary<String,AnyObject>
//                    
//                    dispatch_async(dispatch_get_main_queue(), {
//                        topicViewCon.myPhoto.image = myImg
//                        
//                        topicViewCon.msg = msg
//                        
//                        
//                        
//                        //chatViewCon.historyMsg = msg
//                    })
//                    
//                    
//                })
//            }
            
            
            
            
        }
        
        
        
        //print(topicOwnerID)
        
    }
    
//    func getHttpData() {
//        let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
//        dispatch_async(dispatch_get_global_queue(qos,0)){ () -> Void in
//            let httpObj = ＨttpRequsetCenter()
//            httpObj.getTopicContentHistory(self.ownerId!,topicId: self.topicId!, InViewAct: { (returnData2) in
//                //                returnData2:
//                //                unblock_level
//                //                img
//                //                my_img
//                //                msg
//                let myImg = base64ToImage(returnData2["my_img"] as! String)
//                
//                let msg = returnData2["msg"] as! Dictionary<String,AnyObject>
//                
//                dispatch_async(dispatch_get_main_queue(), {
//                    self.myPhoto.image = myImg
//                    
//                    let chatViewCon = self.storyboard?.instantiateViewControllerWithIdentifier("chatView2") as! ChatViewController
//                    
//                    
//                    
//                    //chatViewCon.historyMsg = msg
//                })
//                
//                
//            })
//        }
//        //dispatch_async(dispatch_get_main_queue(), {})
//    }
    
    
}









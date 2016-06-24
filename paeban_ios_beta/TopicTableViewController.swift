//
//  TopicTableViewController.swift
//  paeban_ios_test_3
//
//  Created by 尚義 高 on 2016/5/5.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit
public var tagList:[String] = []

// 所有話題清單 其實不是tabelveiw 是 UIview
class TopicTableViewController:UIViewController, httpResquestDelegate,UITableViewDelegate,UITableViewDataSource{
    // MARK: Properties
    
    @IBOutlet weak var newTopicInput: UITextField!
    
    @IBAction func newTopicBtn(sender: AnyObject) {
    }
    
    @IBOutlet weak var searchTagInput: UITextField!
    
    
    @IBAction func searchTagBtn(sender: AnyObject) {
    }
    
    @IBOutlet weak var topicList: UITableView!
    
    
    var topics:[Topic] = []
    var httpOBJ = httpRequsetCenter()
    var requestUpDataSwitch = true
    //var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        //loadSampleTopics()
        
        // 具體要怎麼作 由這個class自己來決定
        httpOBJ.delegate = self
        topicList.delegate = self
        topicList.dataSource = self
        
        
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
    
    func new_topic_did_load(http_obj:httpRequsetCenter){
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
}


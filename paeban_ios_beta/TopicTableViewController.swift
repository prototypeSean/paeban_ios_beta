//
//  TopicTableViewController.swift
//  paeban_ios_test_3
//
//  Created by 尚義 高 on 2016/5/5.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit
public var tagList:[String] = []

// 所有話題清單
class TopicTableViewController: UITableViewController,httpResquestDelegate{
    // MARK: Properties
    
    var topics:[Topic] = []
    var httpOBJ = httpRequsetCenter()
    var requestOldDataSwitch = true

    override func viewDidLoad() {
        super.viewDidLoad()
        //loadSampleTopics()
        httpOBJ.delegate = self
        
        let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
        dispatch_async(dispatch_get_global_queue(qos,0)){ () -> Void in
            self.httpOBJ.getTopic()
            dispatch_async(dispatch_get_main_queue(), {
                let temp_topic = self.httpOBJ.topic_list
                self.topics = self.topics + temp_topic
                self.tableView.reloadData()
            })
        }
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(TopicTableViewController.update), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
    }
    func update(){
        if requestOldDataSwitch == true{
            print("刷新中")
            self.requestOldDataSwitch = false
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            dispatch_async(dispatch_get_global_queue(qos,0)){ () -> Void in
                self.httpOBJ.getTopic()
                let temp_topic = self.httpOBJ.topic_list
                self.topics = temp_topic
                dispatch_async(dispatch_get_main_queue(), {
                    print(self.topics[0].hashtags)
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                    self.requestOldDataSwitch = true
                })
            }
        }
        else{
            self.refreshControl?.endRefreshing()
        }
    }
    
    func loadSampleTopics() {
        
        let photo_1 = UIImage(named: "logo")!
        let topic_1 = Topic(owner: "DK", photo: photo_1, title: "泛泛標題", hashtags: ["tag","tag2","tag3"],lastline:"最後一句對話" ,topicID: "001")!
        
        topics.append(topic_1)
    }
    func new_topic_did_load(http_obj:httpRequsetCenter){
        print("websocket data did load")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return topics.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
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
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let scroolHeight = self.tableView.contentOffset.y + self.tableView.frame.height
        let contentHeight = self.tableView.contentSize.height
        if scroolHeight >= contentHeight && contentHeight > 0
            && requestOldDataSwitch == true{
            requestOldDataSwitch = false
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
                    self.topics += self.httpOBJ.topic_list
                }
                
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                    self.requestOldDataSwitch = true
                    //print(self.httpOBJ.topic_list)
                    //print(self.topics)
                })
            }
            
        }
    }
    
    //NSIndexPath* ipath = [NSIndexPath indexPathForRow: cells_count-1 inSection: sections_count-1];
    //[tableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
    //-----------test---------
}

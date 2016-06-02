//
//  TopicTableViewController.swift
//  paeban_ios_test_3
//
//  Created by 尚義 高 on 2016/5/5.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit



class TopicTableViewController: UITableViewController,httpResquestDelegate {
    // MARK: Properties
    
    var topics:[Topic] = []
    var x:[Topic]{
        get{return topics}
        set{
            print("didset")
            self.tableView.reloadData()
        }
    }
    var sss = httpRequsetCenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSampleTopics()
        sss.delegate = self
        
        let loading_lable = UILabel()
        loading_lable.center = self.view.center
        loading_lable.text = "讀取中..."
        self.tableView.addSubview(loading_lable)
        
        let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
        dispatch_async(dispatch_get_global_queue(qos,0)){ () -> Void in
            self.sss.getTopic()
            let temp_topic = self.sss.topic_list
            dispatch_async(dispatch_get_main_queue(), {
                self.topics = self.topics + temp_topic
                self.tableView.reloadData()
            })
        }
        
        
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func loadSampleTopics() {
        
        let photo_1 = UIImage(named: "logo")!
        let topic_1 = Topic(owner: "DK", photo: photo_1, title: "範例標題", hashtags: ["tag","tag2"],lastline:"最後一句對話" ,topicID: "001")!
        topics.append(topic_1)
    }
    func new_topic_did_load(http_obj:httpRequsetCenter){
        print("didload")
        //topics = topics + sss.topic_list
        //x = topics
        //self.tableView.reloadData()

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
        let cellIdentifier = "TopicCellTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TopicCellTableViewCell
        
        let topic = topics[indexPath.row]
        
        cell.topicTitle.text = topic.title
        cell.topicOwnerImage.image = topic.photo
//        cell.topicHashtags.text = topic.hashtags!

        // Configure the cell...

        return cell
    }
 
}

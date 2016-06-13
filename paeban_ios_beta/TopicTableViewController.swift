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
class TopicTableViewController: UIViewController,httpResquestDelegate,UITableViewDelegate {
    // MARK: Properties
    
    @IBOutlet weak var newTopicInput: UITextField!
    
    @IBAction func newTopicBtn(sender: AnyObject) {
    }
    
    @IBOutlet weak var searchTagInput: UITextField!
    
    
    @IBAction func searchTagBtn(sender: AnyObject) {
    }
    
    
    var topics:[Topic] = []
    var httpOBJ = httpRequsetCenter()

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
        
        
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func loadSampleTopics() {
        
        let photo_1 = UIImage(named: "logo")!
        let topic_1 = Topic(owner: "DK", photo: photo_1, title: "泛泛標題", hashtags: ["tag","tag2","tag3"],lastline:"最後一句對話" ,topicID: "001")!
        
        topics.append(topic_1)
    }
    func new_topic_did_load(http_obj:httpRequsetCenter){
        print("websocket data did load")
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
        let topic = topics[indexPath.row]
        tagList = topic.hashtags!
        let cellIdentifier = "TopicCellTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TopicCellTableViewCell
        
        cell.topicTitle.text = topic.title
        cell.topicOwnerImage.image = topic.photo

        // Configure the cell...

        return cell
    }
 
}

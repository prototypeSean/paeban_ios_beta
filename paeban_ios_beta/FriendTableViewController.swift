//
//  FriendTableViewController.swift
//  paeban_ios_beta
//
//  Created by 工作用 on 2016/9/4.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

class FriendTableViewController: UITableViewController,webSocketActiveCenterDelegate {
    var model:FriendTableViewMedol?
    override func viewDidLoad() {
        super.viewDidLoad()
        model = FriendTableViewMedol()
        wsActive.wasd_ForFriendTableViewController = self
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return model!.getDataCount()
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendTableViewCell", forIndexPath: indexPath) as! FriendTableViewCell
        let cell2 = model!.getCell(indexPath.row, cell: cell)
        return cell2
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let index = self.tableView.indexPathForSelectedRow?.row
        let topicViewCon = segue.destinationViewController as! FriendChatUpViewController
        let getSegueData = model!.getSegueData(index!)
        topicViewCon.setID = userData.id
        topicViewCon.setName = userData.name
        topicViewCon.setImg = userData.img
        topicViewCon.clientId = getSegueData["clientId"] as? String
        topicViewCon.clientName = getSegueData["clientName"] as? String
        topicViewCon.clientImg = getSegueData["clientImg"] as? UIImage
        topicViewCon.title = "好友"
        
        
        
    }
    
    func wsOnMsg(msg:Dictionary<String,AnyObject>){
        let msgtype = msg["msg_type"] as! String
        if msgtype == "online"{
            self.tableView.reloadData()
        }
        else if msgtype == "off_line"{
            self.tableView.reloadData()
        }
        else if msgtype == "new_member"{
            self.tableView.reloadData()
        }
    }
    
    
}









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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return model!.getDataCount()
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendTableViewCell", for: indexPath) as! FriendTableViewCell
        let cell2 = model!.getCell((indexPath as NSIndexPath).row, cell: cell)
        let thePhotoLayer:CALayer = cell2.photo.layer
        thePhotoLayer.masksToBounds = true
        thePhotoLayer.cornerRadius = 6
        
        return cell2
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "friendConBox"{
            let index = (self.tableView.indexPathForSelectedRow as NSIndexPath?)?.row
            let topicViewCon = segue.destination as! FriendChatUpViewController
            let getSegueData = model!.getSegueData(index!)
            topicViewCon.setID = userData.id
            topicViewCon.setName = userData.name
            topicViewCon.setImg = userData.img
            topicViewCon.clientId = getSegueData["clientId"] as? String
            topicViewCon.clientName = getSegueData["clientName"] as? String
            topicViewCon.clientImg = getSegueData["clientImg"] as? UIImage
            topicViewCon.title = "好友"
        }
    }
    
    func wsOnMsg(_ msg:Dictionary<String,AnyObject>){
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









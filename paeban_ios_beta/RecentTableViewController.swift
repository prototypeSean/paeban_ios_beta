import UIKit

class RecentTableViewController: UITableViewController, webSocketActiveCenterDelegate{
    var rTVModel = RecentTableViewModel?()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rTVModel = RecentTableViewModel()
        wsActive.wasd_ForRecentTableViewController = self
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rTVModel!.lenCount()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("nowTopicListCell", forIndexPath: indexPath) as! RecentTableViewCell
        let cell2 = rTVModel!.getCell(indexPath.row,cell: cell)
        
        return cell2
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let index = self.tableView.indexPathForSelectedRow?.row
        let topicViewCon = segue.destinationViewController as! TopicViewController
        let getSegueData = rTVModel!.getSegueData(index!)
        topicViewCon.topicId = getSegueData["topicId"] as? String
        topicViewCon.ownerId = getSegueData["ownerId"] as? String
        topicViewCon.ownerImg = getSegueData["ownerImg"] as? UIImage
        topicViewCon.topicTitle = getSegueData["topicTitle"] as? String
        topicViewCon.title = getSegueData["title"] as? String
        //topicViewCon.delegate = self
    }
    
    func wsOnMsg(msg:Dictionary<String,AnyObject>){
        if let msg_type:String = msg["msg_type"] as? String{

            if msg_type == "topic_msg"{
                self.tableView.reloadData()
            }
            else if msg_type == "new_member"{
                if rTVModel!.clientOnline(msg){
                    self.tableView.reloadData()
                }
            }
            else if msg_type == "off_line"{
                if rTVModel!.clientOffline(msg){
                    self.tableView.reloadData()
                }
            }
            else if msg_type == "topic_closed"{
                if rTVModel!.topicClosed(msg){
                    self.tableView.reloadData()
                }
            }
            
        }
    }
}






import UIKit

class RecentTableViewController: UITableViewController, webSocketActiveCenterDelegate{
    var rTVModel = RecentTableViewModel?()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rTVModel = RecentTableViewModel(data: nowTopicCellList)
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
    func wsOnMsg(msg:Dictionary<String,AnyObject>){
        if let msg_type:String = msg["msg_type"] as? String{

            if msg_type == "topic_msg"{
                let resultDic:Dictionary<String,AnyObject> = msg["result_dic"] as! Dictionary
                rTVModel!.updataDB(resultDic)
                self.tableView.reloadData()
            }
            
        }
    }
}







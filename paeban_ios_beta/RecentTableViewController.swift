import UIKit

class RecentTableViewController: UITableViewController, webSocketActiveCenterDelegate{
    var rTVModel = RecentTableViewModel()
    
//    @IBOutlet weak var ownerPhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rTVModel = RecentTableViewModel()
        rTVModel.reCheckDataBase()
        wsActive.wasd_ForRecentTableViewController = self
//        print(nowTopicCellList)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rTVModel.lenCount()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "nowTopicListCell", for: indexPath) as! RecentTableViewCell
        let cell2 = rTVModel.getCell((indexPath as NSIndexPath).row,cell: cell)
        
//      MARK: cell照片圓角
        let myPhotoLayer:CALayer = cell2.clientImg.layer
        myPhotoLayer.masksToBounds = true
        myPhotoLayer.cornerRadius = 6
        
        return cell2
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "clientModeSegue3"{
            let index = (self.tableView.indexPathForSelectedRow as NSIndexPath?)?.row
            let topicViewCon = segue.destination as! TopicViewController
            let getSegueData = rTVModel.getSegueData(index!)
            topicViewCon.topicId = getSegueData["topicId"] as? String
            topicViewCon.ownerId = getSegueData["ownerId"] as? String
            topicViewCon.ownerImg = getSegueData["ownerImg"] as? UIImage
            topicViewCon.topicTitle = getSegueData["topicTitle"] as? String
            topicViewCon.title = getSegueData["title"] as? String
            //topicViewCon.delegate = self
        }
        
    }
    
    func wsOnMsg(_ msg:Dictionary<String,AnyObject>){
        if let msg_type:String = msg["msg_type"] as? String{

            if msg_type == "topic_msg"{
                self.tableView.reloadData()
            }
            else if msg_type == "new_member"{
                if rTVModel.clientOnline(msg){
                    self.tableView.reloadData()
                }
            }
            else if msg_type == "off_line"{
                if rTVModel.clientOffline(msg){
                    self.tableView.reloadData()
                }
            }
            else if msg_type == "topic_closed"{
                if rTVModel.topicClosed(msg){
                    self.tableView.reloadData()
                }
            }
            else if msg_type == "recentDataCheck"{
                
                let data = msg["data"] as! Dictionary<String,AnyObject>
                for datas in data{
                    self.rTVModel.transformStaticType(datas.0, inputData: datas.1 as! Dictionary<String,AnyObject>){
                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                        })
                        
                    }
                }
                
            }
            
        }
    }
}

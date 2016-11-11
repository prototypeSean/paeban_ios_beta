import UIKit

class RecentTableViewController: UITableViewController, webSocketActiveCenterDelegate{
    var rTVModel = RecentTableViewModel()
    
//    @IBOutlet weak var ownerPhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rTVModel = RecentTableViewModel()
        wsActive.wasd_ForRecentTableViewController = self
//        print(nowTopicCellList)
    }
    override func viewWillAppear(_ animated: Bool) {
        print("into  RecentTableViewController")
        print(socketState)
        rTVModel.reCheckDataBase()
        autoLeap()
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
            let topicViewCon = segue.destination as! TopicViewController
            var getSegueData:Dictionary<String, AnyObject>
            if let index = (self.tableView.indexPathForSelectedRow as NSIndexPath?)?.row{
                getSegueData = rTVModel.getSegueData(index)
            }
            else{
                getSegueData = rTVModel.getSegueData(rTVModel.segueDataIndex!)
            }
            
            topicViewCon.topicId = getSegueData["topicId"] as? String
            topicViewCon.ownerId = getSegueData["ownerId"] as? String
            topicViewCon.ownerImg = getSegueData["ownerImg"] as? UIImage
            topicViewCon.topicTitle = getSegueData["topicTitle"] as? String
            topicViewCon.title = getSegueData["title"] as? String
            
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
    
    // internal func
    func autoLeap(){
        if notificationSegueInf != [:]{
            let segue_topic_id = notificationSegueInf["topic_id"]
            let segue_user_id = notificationSegueInf["user_id"]
            
            var targetData_Dickey:Array<MyTopicStandardType>.Index?
            
            var while_pertect = 5000
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                while targetData_Dickey == nil && while_pertect >= 0{
                    
                    targetData_Dickey = self.rTVModel.recentDataBase.index(where: { (MyTopicStandardType) -> Bool in
                        if MyTopicStandardType.topicId_title == segue_topic_id && MyTopicStandardType.clientId_detial == segue_user_id{
                            return true
                        }
                        else{return false}
                    })
                    
                    if targetData_Dickey != nil{
                        DispatchQueue.main.async {
                            self.rTVModel.segueDataIndex = targetData_Dickey! as Int
                            self.performSegue(withIdentifier: "clientModeSegue3", sender: nil)
                            notificationSegueInf = [:]
                        }
                        
                    }
                    usleep(100000)
                    while_pertect -= 100
                }
                //self.segueData = nil
                notificationSegueInf = [:]
            }
            
        }
    }
}

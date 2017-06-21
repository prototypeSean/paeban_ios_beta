import UIKit

class RecentTableViewController: UITableViewController, webSocketActiveCenterDelegate, RecentTableViewModelDelegate, TopicViewControllerDelegate{
    var rTVModel = RecentTableViewModel()
    
    // data source
    override func viewDidLoad() {
        super.viewDidLoad()
        rTVModel = RecentTableViewModel()
        rTVModel.delegate = self
        wsActive.wasd_ForRecentTableViewController = self
//        print(nowTopicCellList)
        // 讓整個VIEW往上縮起tabbar的高度
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, (self.tabBarController?.tabBar.frame)!.height, 0);
    }
    override func viewWillAppear(_ animated: Bool) {
        print("recent viewWillAppear")
        //self.rTVModel.send_leave_topic()
        rTVModel.reCheckDataBase()
        self.update_badges()
        //autoLeap()
    }
    override func viewDidAppear(_ animated: Bool) {
        rTVModel.chat_view = nil
        self.show_leave_topic_master_alert()
    }
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
            topicViewCon.setID = getSegueData["ownerId"] as? String
            topicViewCon.setName = getSegueData["ownerName"] as? String
            
            topicViewCon.ownerId = getSegueData["ownerId"] as? String
            topicViewCon.topicTitle = getSegueData["topicTitle"] as? String
            topicViewCon.title = getSegueData["title"] as? String
            topicViewCon.delegate = self
            rTVModel.chat_view = topicViewCon
        }
        
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .default, title: "刪除") { (UITableViewRowAction_parameter, IndexPath_parameter) in
//            self.rTVModel.add_leave_topic_table(index: indexPath.row)
//            self.rTVModel.send_leave_topic()
            //self.rTVModel.remove_cell(index: indexPath.row)
            let select_data = self.rTVModel.recentDataBase[indexPath.row]
            let topic_id = self.rTVModel.recentDataBase[indexPath.row].topicId_title!
            Ignore_list_center().add_ignore_list(topic_id_in: select_data.topicId_title!, client_id: select_data.clientId_detial!)
            sql_database.delete_recent_topic(topic_id_in:topic_id)
            self.rTVModel.reCheckDataBase()
        }
        
        delete.backgroundColor = UIColor.gray
        
        
        
        return [delete]
        
    }
    
    
    // delegate
    func wsOnMsg(_ msg:Dictionary<String,AnyObject>){
        if let msg_type:String = msg["msg_type"] as? String{
            
            if msg_type == "topic_msg"{
                rTVModel.recive_topic_msg(msg:msg)
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
            else if msg_type == "friend_confirm"{
                fast_alter(inviter: (msg["sender_name"] as? String)!, nav_controller: self.parent as! UINavigationController)
            }
//            else if msg_type == "leave_topic_client"{
//                if let topic_id = msg["topic_id"] as? String{
//                    sql_database.remove_topic_from_topic_table(topic_id_input: topic_id)
//                }
//            }
            else if msg["msg_type"] as! String == "leave_topic_master_client"{
                let topic_id = msg["topic_id"] as! String
                let owner_name = msg["owner_name"] as! String
                self.rTVModel.add_leave_topic_master_list(topic_id_input: topic_id, owner_name_input: owner_name)
                self.show_leave_topic_master_alert()
                self.rTVModel.remove_cell(by: topic_id)
                self.update_badges()
            }
            
        }
    }
    func wsReconnected(){
        self.rTVModel.reCheckDataBase()
        //self.rTVModel.send_leave_topic()
        self.update_badges()
    }
    func model_relodata(){
        self.tableView.reloadData()
    }
    func model_relod_row(index_path_list:Array<IndexPath>, option:UITableViewRowAnimation){}
    func model_delete_row(index_path_list:Array<IndexPath>, option:UITableViewRowAnimation){
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: index_path_list, with: option)
        self.tableView.endUpdates()
    }
    func topic_has_been_closed(_ topicID: String) {
        let msg_dic:Dictionary<String,AnyObject> = ["topic_id": topicID as AnyObject]
        if rTVModel.topicClosed(msg_dic){
            self.tableView.reloadData()
        }
    }
    func model_insert_row(index_path_list:Array<IndexPath>, option:UITableViewRowAnimation){}
    func segue_to_chat_view(detail_cell_obj:MyTopicStandardType){}
    
    
    // internal func
    func autoLeap(){
        if notificationSegueInf != [:]{
            let parent = self.parent as! UINavigationController
            parent.popToRootViewController(animated: false)
            let segue_topic_id = notificationSegueInf["topic_id"]
            let segue_user_id = notificationSegueInf["user_id"]
            
            var targetData_Dickey:Array<MyTopicStandardType>.Index?
            
            var while_pertect = 5000
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                while targetData_Dickey == nil && while_pertect >= 0{
                    
                    targetData_Dickey = self.rTVModel.recentDataBase.index(where: { (MyTopicStandardType) -> Bool in
                        if MyTopicStandardType.topicId_title == segue_topic_id && MyTopicStandardType.clientId_detial == segue_user_id{
                            return true
                        }
                        else{return false}
                    })
                    
                    if targetData_Dickey != nil{
                        DispatchQueue.main.async {
                            notificationSegueInf = [:]
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
    func update_badges(){
        let tab_bar = self.parent?.parent as! TabBarController
        tab_bar.update_badges()
    }
    func show_leave_topic_master_alert(){
        if self.rTVModel.chat_view == nil{
            for alert_data in self.rTVModel.leave_topic_master_list{
                let alert = UIAlertController(title: "通知".localized(withComment: "RecentTableViewController"), message: String(format: NSLocalizedString("用戶%@ 已將您移出話題%@", comment: "RecentTableViewController"), alert_data["owner_name"]!, alert_data["topic_title"]!), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "確認".localized(withComment: "RecentTableViewController"), style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            self.rTVModel.leave_topic_master_list = []
        }
    }
}





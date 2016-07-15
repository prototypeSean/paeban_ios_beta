//
//  MyTopicTableViewCell.swift
//  paeban_ios_test_3
//
//  Created by 尚義 高 on 2016/5/6.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

class MyTopicTableViewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var topicTitle: UILabel!
    @IBOutlet weak var unReadS: UILabel!
    @IBOutlet weak var unReadM: UILabel!
    
    @IBOutlet weak var topicTableDetail: UITableView!
    
    var dataList:Array<MyTopicDetail>?
    var heightOfCell:CGFloat?
    
    func setDelegate(){
        topicTableDetail.delegate = self
        topicTableDetail.dataSource = self
        topicTableDetail.scrollEnabled = false
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func reloadCell(){
        topicTableDetail.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellID = "cell2"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! TopicSecTableViewCell
        
        let topic = dataList![indexPath.row]
        
        cell.clientName.text = topic.clientName
        cell.speaker.text = topic.lastSpeaker
        cell.lastLine.text = topic.lastLine
        cell.photo.image = topic.clientPhoto
        cell.sexLogo.image = letoutSexLogo(topic.clientSex)
        cell.isTruePhoto.image = letoutIsTruePhoto(topic.clientIsRealPhoto)
        letoutOnlineLogo(topic.clientOnline,cellOnlineLogo: cell.onlineLogo)

        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return heightOfCell!
    }
    
    
    func letoutSexLogo(sex:String) -> UIImage {
        var sexImg:UIImage
        switch sex {
        case "男":
            sexImg = UIImage(named: "male")!
        case "女":
            sexImg = UIImage(named:"gay")!
        case "男同":
            sexImg = UIImage(named:"gay")!
        case "女同":
            sexImg = UIImage(named:"lesbain")!
        default:
            sexImg = UIImage(named: "male")!
            print("性別圖示分類失敗")
        }
        return sexImg
    }
    func letoutIsTruePhoto(isTruePhoto:Bool) -> UIImage {
        var isMeImg:UIImage
        if isTruePhoto{isMeImg = UIImage(named:"True_photo")!}
        else{isMeImg = UIImage(named:"Fake_photo")!}
        return isMeImg
    }
    func letoutOnlineLogo(isOnline:Bool,cellOnlineLogo:UIImageView){

        cellOnlineLogo.image = UIImage(named:"texting")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        
        if isOnline{
            cellOnlineLogo.tintColor = UIColor(red:0.98, green:0.43, blue:0.32, alpha:1.0)
        }
            //MARK:下面那張圖請改 “不在線上的人圖示”
        else{
            //print("online:false")
            cellOnlineLogo.tintColor = UIColor.grayColor()
        }
    }
    
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    //MARK:施工中
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print("xxx")
    }
    
    
    
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //let chatViewCon = segue.destinationViewController as! ChatViewController
        print("segue")
        //chatViewCon.setID = userData.id
        //chatViewCon.setName = userData.name
//        chatViewCon.topicId = self.topicId
//        chatViewCon.ownerId = self.ownerId
//        if self.msg == nil {
//            self.contanterView = chatViewCon
//        }
//        else{
//            chatViewCon.historyMsg = self.msg!
//        }
    }
    

}

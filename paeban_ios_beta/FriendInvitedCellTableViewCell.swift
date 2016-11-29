//
//  FriendInvitedCellTableViewCell.swift
//  paeban_ios_beta
//
//  Created by 尚義 高 on 2016/11/25.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

class FriendInvitedCellTableViewCell: UITableViewCell {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var online: UIImageView!
    @IBOutlet weak var true_photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBAction func ok_btn(_ sender: AnyObject) {
    }
    @IBAction func no_btn(_ sender: AnyObject) {
    }
    var id:String?
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func remove_self(){
        
    }
    
    func friend_confirm(answer:String){
        let send_dic:NSDictionary = [
            "msg_type":"friend_confirm",
            "friend_id":self.id!,
            "answer":answer
        ]
        socket.write(data: json_dumps(send_dic))
    }

}








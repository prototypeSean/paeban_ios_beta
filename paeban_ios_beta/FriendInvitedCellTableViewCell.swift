//
//  FriendInvitedCellTableViewCell.swift
//  paeban_ios_beta
//
//  Created by 尚義 高 on 2016/11/25.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit
protocol FriendInvitedCellTableViewCell_delegate {
    func slide_left(row_id:String)
}


class FriendInvitedCellTableViewCell: UITableViewCell {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var online: UIImageView!
    @IBOutlet weak var true_photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var ok_btn: UIButton!
    var id:String?
    var delegate:FriendInvitedCellTableViewCell_delegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let swipeLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.slide))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.addGestureRecognizer(swipeLeft)
    }
    func slide(){
        self.delegate?.slide_left(row_id: self.id!)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    

}








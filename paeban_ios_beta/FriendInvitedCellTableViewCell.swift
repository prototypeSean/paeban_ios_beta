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
    @IBOutlet weak var no_btn_Outlet: UIButton!
    @IBOutlet weak var ok_btn_Outlet: UIButton!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var online: UIImageView!
    @IBOutlet weak var true_photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBAction func ok_btn(_ sender: AnyObject) {
    }
    @IBAction func no_btn(_ sender: AnyObject) {
    }

    
    @IBAction func no_btn_touchDown(_ sender: AnyObject) {
        no_btn_Outlet.imageView?.image = UIImage(named:"cross")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        no_btn_Outlet.imageView?.tintColor = UIColor.red
    }
    @IBAction func ok_btn_touchDown(_ sender: AnyObject) {
        ok_btn_Outlet.imageView?.image = UIImage(named:"check")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        ok_btn_Outlet.imageView?.tintColor = UIColor.green
    }
    
    
    
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
    override func willTransition(to state: UITableViewCellStateMask) {
        //code
    }
    

}








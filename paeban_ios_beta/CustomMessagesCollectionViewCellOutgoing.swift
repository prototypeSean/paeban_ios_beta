//
//  CustomMessagesCollectionViewCellOutgoing.swift
//  paeban_ios_beta
//
//  Created by 尚義 高 on 2017/1/7.
//  Copyright © 2017年 尚義 高. All rights reserved.
//

import UIKit

class CustomMessagesCollectionViewCellOutgoing: CustomMessagesCollectionViewCell {
    
    var chat_view_controller:ChatViewController?
    var frient_chat_view_controller:FriendChatViewController?
    
    @IBOutlet weak var reloadBTN: UIButton!
    
    @IBOutlet weak var reloadBtnContainer: UIView!
    
    @IBOutlet weak var resendingText: UILabel!

    @IBOutlet weak var reSending: UIActivityIndicatorView!

    @IBAction func resend_action(_ sender: Any) {
        if chat_view_controller != nil{
            chat_view_controller?.send_all_msg()
        }
        frient_chat_view_controller?.send_all_msg()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.messageBubbleTopLabel.textAlignment = NSTextAlignment.right
        self.cellBottomLabel.textAlignment = NSTextAlignment.right
    }
    
    override class func nib() -> UINib {
        return UINib(nibName: "CustomMessagesCollectionViewCellOutgoing", bundle: nil)
    }
    
    override class func cellReuseIdentifier() -> String {
        return "CustomMessagesCollectionViewCellOutgoing"
    }
    
    
    func hideResendBtn(){
        reloadBtnContainer.isHidden = true
        reloadBTN.isHidden = true
    }
    
    func showResendBtn(){
        reloadBtnContainer.isHidden = false
        reloadBTN.isHidden = false
        reSending.stopAnimating()
    }
    
    func showResending(){
        reloadBtnContainer.isHidden = false
        reloadBTN.isHidden = true
        reSending.startAnimating()
    }

}











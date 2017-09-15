//
//  SettingProfilePicViewController.swift
//  paeban_ios_beta
//
//  Created by 尚義 高 on 2016/11/5.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

class SettingProfilePicViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate, UIAlertViewDelegate{
    var imageViewTemp:UIImageView?
//    var imgView:UIImageView?
    
    let profilePicImg = UIImageView()
    
    var picker:UIImagePickerController?=UIImagePickerController()
    var popover:UIPopoverController?=nil
    
    @IBOutlet weak var profilePicBtn: UIButton!
    @IBOutlet weak var profilePicShadow: UIView!
    @IBAction func change_btn(_ sender: AnyObject) {
        let alert:UIAlertController=UIAlertController(title: "選取照片".localized(withComment: "SettingProfilePicViewController"), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)

        let gallaryAction = UIAlertAction(title: "相簿".localized(withComment: "SettingProfilePicViewController"), style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            self.openGallary()
        }
        let cameraAction = UIAlertAction(title: "相機".localized(withComment: "SettingProfilePicViewController"), style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            self.openCamera()
            
        }
        let cancelAction = UIAlertAction(title: "取消".localized(withComment: "SettingProfilePicViewController"), style: UIAlertActionStyle.cancel)
        {
            UIAlertAction in
            
        }
        
        // Add the actions
        picker?.delegate = self
        picker!.allowsEditing = true
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        // Present the controller
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            
            popover=UIPopoverController(contentViewController: alert)
            popover!.present(from: self.view.frame, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
        }
    }
    func openGallary()
    {
        picker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.present(picker!, animated: true, completion: nil)
        }
        else
        {
            popover=UIPopoverController(contentViewController: picker!)
            popover!.present(from: self.view.frame, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
        }
    }
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            picker!.sourceType = UIImagePickerControllerSourceType.camera
            self .present(picker!, animated: true, completion: nil)
        }
        else
        {
            openGallary()
        }
    }

    // MARK:override
    override func viewDidLoad() {
        super.viewDidLoad()
        picker!.delegate=self
    }
    override func viewDidLayoutSubviews() {
        setMyOldImg()
    }
    
    // MARK:internal func

    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let jpegImgData = UIImageJPEGRepresentation(image, 100)
        let jpegImg = UIImage(data: jpegImgData!)
        let scale = newWidth / jpegImg!.size.width
        let newHeight = jpegImg!.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        jpegImg!.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    func addClientImg(img:UIImage){
//        let imageView = UIImageView(image: resizeImage(image: img, newWidth: 200))
//        imageViewTemp = imageView
//        imageView.frame = view.bounds
        profilePicImg.image = img
    }
    func setMyOldImg(){
//        imgView = UIImageView()
//        imgView?.image = userData.img
//        let long = self.view.frame.width/2
//        imgView?.frame = CGRect(x: 0, y: 0, width:long , height: long)
        
        // 開始設定照片
        profilePicShadow.backgroundColor = UIColor.clear
        profilePicShadow.layer.shadowColor = UIColor(red:0.57, green:0.57, blue:0.57, alpha:1).cgColor
        profilePicShadow.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        profilePicShadow.layer.shadowOpacity = 1
        profilePicShadow.layer.shadowRadius = 2
//        print(profilePicShadow.bounds)
        // add the border to subview 第二層做邊框（這邊設0因為不需要）
        let profilePicborderView = UIView()
        profilePicborderView.frame = profilePicShadow.bounds
        profilePicborderView.layer.cornerRadius = profilePicShadow.frame.width/2
        profilePicborderView.layer.borderColor = UIColor.white.cgColor
        profilePicborderView.layer.borderWidth = 2
        profilePicborderView.layer.masksToBounds = true
        profilePicShadow.addSubview(profilePicborderView)
        // add any other subcontent that you want clipped 最上層才放圖片進去
        profilePicImg.image = userData.img
        profilePicImg.frame = profilePicborderView.bounds
//        profilePicBtn.layoutIfNeeded()
//        profilePicBtn.clipsToBounds = true
        profilePicborderView.addSubview(profilePicImg)
        // 莫名其妙成功了的一行
        
        //==============test============
        //profilePicImg.addSubview(profilePicBtn)
        profilePicBtn.isHidden = true
        let test_view = UIView()
        test_view.backgroundColor = UIColor.gray
        test_view.frame = CGRect(
            x: CGFloat(0),
            y: (profilePicImg.frame.height * 0.8),
            width: profilePicImg.frame.width,
            height: (profilePicImg.frame.height * 0.2)
        )
        profilePicImg.addSubview(test_view)
        let label = UILabel()
        label.textColor = UIColor.white
        label.text = "更換照片"
        label.sizeToFit()
        print(label.frame)
        label.frame = CGRect(
            x: CGFloat((test_view.frame.width - label.frame.width)/2),
            y: CGFloat((test_view.frame.height - label.frame.height)/2),
            width: label.frame.width,
            height: label.frame.height
        )
        //label.center = test_view.center
        test_view.addSubview(label)
        
        
        
        //print(profilePicImg.frame.size.height,profilePicImg.frame.size.width)
        
//        profilePicImg.isUserInteractionEnabled = true
//        let tapAction = UITapGestureRecognizer(target: self, action: #selector(addImgBtn))
//        profilePicImg.addGestureRecognizer(tapAction)
        
        
        
//        self.view.addSubview(imgView!)
    }
    
    
    // delegate -> UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        addClientImg(img: image)
        
        picker.dismiss(animated: true) {
            //code
        }
        
    }
}








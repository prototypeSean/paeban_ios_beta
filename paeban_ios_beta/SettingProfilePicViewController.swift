//
//  SettingProfilePicViewController.swift
//  paeban_ios_beta
//
//  Created by 尚義 高 on 2016/11/5.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

class SettingProfilePicViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var imageViewTemp:UIImageView?
//    var imgView:UIImageView?
    
    let profilePicImg = UIImageView()
    
    @IBOutlet weak var profilePicBtn: UIButton!
    @IBOutlet weak var profilePicShadow: UIView!
    // MARK:override
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidLayoutSubviews() {
        setMyOldImg()
    }
    
    // MARK:internal func
    func addImgBtn(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置媒体类型
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: UIImagePickerControllerSourceType.photoLibrary)!
            //指定图片控制器类型
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            //设置是否允许编辑
            picker.allowsEditing = true
            //弹出控制器，显示界面
            self.present(picker, animated: true, completion: {
                () -> Void in
            })
        }else{
            print("相簿讀取錯誤")
        }
    }
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
        let imageView = UIImageView(image: resizeImage(image: img, newWidth: 200))
        imageViewTemp = imageView
        imageView.frame = view.bounds
        profilePicImg.image = imageView.image
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
        profilePicImg.addSubview(profilePicBtn)
        
        print(profilePicImg.frame.size.height,profilePicImg.frame.size.width)
        
        profilePicImg.isUserInteractionEnabled = true
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(addImgBtn))
        profilePicImg.addGestureRecognizer(tapAction)
        
        
        
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








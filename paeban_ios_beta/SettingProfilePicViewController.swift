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
    var imgView:UIImageView?
    
    // MARK:override
    override func viewDidLoad() {
        super.viewDidLoad()
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
        imgView?.image = imageView.image
    }
    func setMyOldImg(){
        imgView = UIImageView()
        imgView?.image = userData.img
        imgView?.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        imgView?.isUserInteractionEnabled = true
        //let gesture = UITapGestureRecognizer(target: self, action: Selector(("addImgBtn:")))
        // or for swift 2 +
        let gest = UITapGestureRecognizer(target: self, action: #selector(addImgBtn))
        imgView?.addGestureRecognizer(gest)
        
        
        
        self.view.addSubview(imgView!)
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








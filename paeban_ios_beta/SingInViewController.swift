//
//  SingInViewController.swift
//  paeban_ios_beta
//
//  Created by 工作用 on 2016/10/2.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

class SingInViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    let scrollView = UIScrollView()
    let singInModel = SingInModel()
    var imageViewTemp:UIImageView?
    
    var picker:UIImagePickerController?=UIImagePickerController()
    var popover:UIPopoverController?=nil
    
    @IBAction func selectImage(sender: AnyObject) {
        
        let imgPicker = UIImagePickerController()
        imgPicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        imgPicker.modalPresentationStyle = UIModalPresentationStyle.popover
        
        self.present(imgPicker, animated: true, completion: nil)
        
        let popper = imgPicker.popoverPresentationController
        // returns a UIPopoverPresentationController
        popper?.barButtonItem = sender as? UIBarButtonItem
        
    }
    
    @IBAction func addImgBtn(_ sender: AnyObject) {
        let alert:UIAlertController=UIAlertController(title: "選取照片".localized(withComment: "SettingProfilePicViewController"), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        //        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default)
        //        {
        //            UIAlertAction in
        //            self.openCamera()
        //
        //        }
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
        //        addImgBtn()
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
    
    @IBOutlet var addPhotoBG: UIView!
    @IBOutlet weak var addPhotoBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPhotoBG.layoutIfNeeded()
        addPhotoBG.layer.backgroundColor = UIColor(red:0.90, green:0.89, blue:0.88, alpha:1.0).cgColor
        addPhotoBG.layer.borderWidth = 1
        
        let avatorRadious = addPhotoBG.layer.bounds.size.width/4
//        print(avatorRadious)
//        print(addPhotoBG.layer.bounds.size.width)
        addPhotoBG.layer.cornerRadius = avatorRadious
        addPhotoBG.clipsToBounds = true
        addPhotoBG.layer.borderColor = UIColor.gray.cgColor
    }
    
    
    
    
    
    func addClientImg(img:UIImage){
        let imageView = UIImageView(image: singInModel.resizeImage(image: img, newWidth: 200))
        imageViewTemp = imageView
        imageView.frame = view.bounds
        view.addSubview(imageView)
    }
    
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
    
    
    // delegate -> UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        addClientImg(img: image)
        
        picker.dismiss(animated: true) { 
            //code
        }
        
    }

    
}





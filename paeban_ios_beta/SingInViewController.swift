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
    
    
    @IBAction func addImgBtn(_ sender: AnyObject) {
        addImgBtn()
    }
    @IBOutlet var addPhotoBG: UIView!
    @IBOutlet weak var addPhotoBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPhotoBG.layoutIfNeeded()
        addPhotoBG.layer.backgroundColor = UIColor(red:0.90, green:0.89, blue:0.88, alpha:1.0).cgColor
        addPhotoBG.layer.borderWidth = 1
        
        let avatorRadious = addPhotoBG.layer.bounds.size.width/4
        print(avatorRadious)
        print(addPhotoBG.layer.bounds.size.width)
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
            print("SingInViewController＿flag_1")
            let picker = UIImagePickerController()
            //设置代理
            print("2")
            picker.delegate = self
            //设置媒体类型
            print("3")
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: UIImagePickerControllerSourceType.photoLibrary)!
            
            //指定图片控制器类型
            print("4")
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            //设置是否允许编辑
            print("5")
            picker.allowsEditing = true
            //弹出控制器，显示界面
            print("6")
            
            self.present(picker, animated: true, completion: {
                () -> Void in
            })
            print("7")
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
    
    
    // delegate -> UIScrollViewDelegate

    
}





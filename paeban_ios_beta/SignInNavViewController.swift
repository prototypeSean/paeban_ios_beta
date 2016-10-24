//
//  SignInNavViewController.swift
//  paeban_ios_beta
//
//  Created by 尚義 高 on 2016/10/20.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

class SignInNavViewController: UINavigationController  {
    let gradientLayer = CAGradientLayer()
    
    
    fileprivate func imageLayerForGradientBackground() -> UIImage {
        
        var updatedFrame = self.navigationBar.bounds
        // 包含上層狀態列
        updatedFrame.size.height += 20
        let layer = CAGradientLayer.gradientLayerForBounds(bounds: updatedFrame)
        UIGraphicsBeginImageContext(layer.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.isTranslucent = false
        self.navigationBar.tintColor = UIColor.white
        let fontDictionary = [ NSForegroundColorAttributeName:UIColor.white ]
        self.navigationBar.titleTextAttributes = fontDictionary
        self.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
}

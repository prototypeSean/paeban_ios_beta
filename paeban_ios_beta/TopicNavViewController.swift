//
//  TopicNavViewController.swift
//  paeban_ios_test_3
//
//  Created by 尚義 高 on 2016/5/29.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

class TopicNavViewController: UINavigationController {
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

        self.tabBarController?.tabBar.tintColor = UIColor(red:0.98, green:0.43, blue:0.32, alpha:1.0)
        // 做漸層
//        self.navigationBar.barTintColor = UIColor.whiteColor()
//        
//        gradientLayer.frame = self.navigationBar.bounds
//        
//        let color1 = UIColor(red:1.00, green:0.32, blue:0.18, alpha:1).CGColor as CGColorRef
//        let color2 = UIColor(red:0.94, green:0.60, blue:0.10, alpha:1).CGColor as CGColorRef
//        gradientLayer.colors = [color1, color2]
//        gradientLayer.locations = [0.0, 1.0]
//        
//        self.view.layer.addSublayer(gradientLayer)
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

// 做漸層的圖層
extension CAGradientLayer {
    class func gradientLayerForBounds(bounds: CGRect) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = bounds
        let color1 = UIColor(red:1.00, green:0.32, blue:0.18, alpha:0.92).cgColor
//      let color2 = UIColor(red:0.94, green:0.60, blue:0.10, alpha:1).CGColor
        let color3 = UIColor(red:0.98, green:0.49, blue:0.29, alpha:1.0).cgColor
        layer.colors = [color1,color3]
        return layer
    }
}



//
//  MytopicNavViewController.swift
//  paeban_ios_beta
//
//  Created by 尚義 高 on 2016/10/2.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

class MytopicNavViewController: TopicNavViewController{
    override func animateGradient(){}
//    let gradientLayer = CAGradientLayer()
//    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.navigationBar.isTranslucent = false
//        createColorSets()
//        self.navigationBar.tintColor = UIColor.white
//        
//        let fontDictionary = [ NSForegroundColorAttributeName:UIColor.white ]
//        self.navigationBar.titleTextAttributes = fontDictionary
//        //      原本TAB的顏色UIColor(red:0.98, green:0.43, blue:0.32, alpha:1.0)
//        self.tabBarController?.tabBar.tintColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
//        
//        
//        
//        //self.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
//        
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        gradientBackgroung()
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        animateGradient()
//        
//    }
//    
//    var colorSets = [[CGColor]]()
//    var currentColorSet: Int!
//    let gradient = CAGradientLayer()
//    
//    
//    func createColorSets() {
//        //        colorSets.append([#colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1).cgColor, #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor])
//        colorSets.append([#colorLiteral(red: 0.9899128079, green: 0.4874264598, blue: 0.2562194467, alpha: 1).cgColor, #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1).cgColor])
//        colorSets.append([#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1).cgColor, #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1).cgColor])
//        colorSets.append([#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1).cgColor, #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,])
//        currentColorSet = 0
//    }
//    
//    func gradientBackgroung(){
//        // 製作包含上層狀態列跟NAV的漸層圖曾
//        var newNavFrame = self.navigationBar.bounds.offsetBy(dx: 0.0, dy: 0.0)
//        newNavFrame.size.height += 20
//        
//        gradient.frame = newNavFrame
//        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
//        gradient.endPoint = CGPoint(x: 1.0, y: 0.0)
//        gradient.colors = colorSets[currentColorSet]
//        //        self.navigationBar.layer.insertSublayer(gradient, at: 0)
//        self.navigationBar.layer.sublayers![0].insertSublayer(gradient, at: 0)
//        
//    }
//    
//    func animateGradient(){
//        if currentColorSet < colorSets.count - 1 {
//            currentColorSet! += 1
//        }
//        else {
//            currentColorSet = 0
//        }
//        let colorChangeAnimation = CABasicAnimation(keyPath: "colors")
//        colorChangeAnimation.delegate = self
//        colorChangeAnimation.duration = 30.0
//        colorChangeAnimation.toValue = colorSets[currentColorSet]
//        colorChangeAnimation.fillMode = kCAFillModeForwards
//        colorChangeAnimation.isRemovedOnCompletion = false
//        gradient.add(colorChangeAnimation, forKey: "colorChange")
//    }
//    
//    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
//        if flag {
//            //            print(currentColorSet)
//            gradient.colors = colorSets[currentColorSet]
//            animateGradient()
//        }
//    }
//
//    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
}

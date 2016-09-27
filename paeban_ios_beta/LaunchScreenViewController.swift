//
//  LaunchScreenViewController.swift
//  paeban_ios_test_3
//
//  Created by 尚義 高 on 2016/5/30.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

class LaunchScreenViewController: UIViewController {

    @IBOutlet weak var launchTextBG: UIView!
    
    @IBOutlet weak var label1: UILabel!
   
    @IBOutlet weak var label2: UILabel!
    
    

    let image = UIImage(named: "launchscreen_1242 x 2208")
    
//    @IBOutlet weak var launchTexts: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        perform(#selector(LaunchScreenViewController.showLoginView), with: nil, afterDelay: 0)
    }
    
    func showLoginView() {
        performSegue(withIdentifier: "showLogin", sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // 原本的手動漸層改為圖片
        let launchTextBGLayer = CAGradientLayer()
        launchTextBGLayer.frame = launchTextBG.bounds
        let color1 = UIColor(red:0.5, green:0.5, blue:0.5, alpha:1).cgColor as CGColor
        let color2 = UIColor(red:0.99, green:0.50, blue:0.14, alpha:1.0).cgColor as CGColor
        launchTextBGLayer.colors = [color1, color2]
        launchTextBG.layer.addSublayer(launchTextBGLayer)
        
        launchTextBGLayer.mask = label1.layer
        label1.layer.addSublayer(label2.layer)
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

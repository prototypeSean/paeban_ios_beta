//
//  TPage_1ViewControllerViewController.swift
//  paeban_ios_beta
//
//  Created by 尚義 高 on 2016/11/29.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

class TPage_1ViewController: UIViewController {

    @IBOutlet weak var img_p1: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        img_p1.image = UIImage(named: "Tutorial_P1")
    }
    override func viewDidDisappear(_ animated: Bool) {
        img_p1.image = nil
        self.view = nil
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

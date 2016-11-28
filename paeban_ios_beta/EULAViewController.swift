//
//  EULAViewController.swift
//  paeban_ios_beta
//
//  Created by 尚義 高 on 2016/11/27.
//  Copyright © 2016年 尚義 高. All rights reserved.
//

import UIKit

class EULAViewController: UIViewController {

    @IBOutlet weak var EULAContentText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.EULAContentText.setContentOffset(CGPoint.zero, animated: false)
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

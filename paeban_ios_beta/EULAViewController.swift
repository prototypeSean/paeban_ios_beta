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
    @IBAction func return_to_mmain_vc(_ sender: AnyObject) {
        print("++++++++")
        print(self)
        print(self.parent)
        let nav_vc = self.parent?.parent as? UINavigationController
        
        //self.view.removeFromSuperview()
        if nav_vc != nil{
            nav_vc!.popToRootViewController(animated: true)
        }
        //let page_vc = self.parent as? TutorialPageViewController
        //print(page_vc?.childViewControllers)
        
        // test
        DispatchQueue.global(qos: .default).async {
            sleep(1)
            let vc_list = [self.getViewController(indentifier: "TPage_1ViewController"),
                           self.getViewController(indentifier: "TPage_2ViewController"),
                           self.getViewController(indentifier: "TPage_3ViewController"),
                           self.getViewController(indentifier: "TPage_4ViewController"),
                           self.getViewController(indentifier: "EULAViewController")
            ]
            for vc_s in vc_list{
                vc_s.view = nil
                vc_s.dismiss(animated: false, completion: nil)
            }
            // test
            
            print("done")
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.EULAContentText.setContentOffset(CGPoint.zero, animated: false)
    }
    private func getViewController(indentifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "\(indentifier)")
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

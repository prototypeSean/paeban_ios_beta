//
//  TutoriaInsideViewController.swift
//  paeban_ios_beta
//
//  Created by 高尚義 on 2017/6/13.
//  Copyright © 2017年 尚義 高. All rights reserved.
//

import UIKit

class TutoriaInsideViewController: UIPageViewController, UIPageViewControllerDataSource {
        //所有页面的视图控制器
        private(set) lazy var allViewControllers: [UIViewController] = {
            return [self.getViewController(indentifier: "TPage_1ViewController"),
                    self.getViewController(indentifier: "TPage_2ViewController"),
                    self.getViewController(indentifier: "TPage_3ViewController"),
                    self.getViewController(indentifier: "TPage_4ViewController"),
                    self.getViewController(indentifier: "TPage_5ViewController"),
                    ]
        }()

        //页面加载完毕
        override func viewDidLoad() {
            super.viewDidLoad()
            
            //数据源设置
            dataSource = self
            
            //设置首页
            if let firstViewController = allViewControllers.first {
                setViewControllers([firstViewController],
                                   direction: .forward,
                                   animated: true,
                                   completion: nil)
            }
        }
        
        //根据indentifier获取Storyboard里的视图控制器
        private func getViewController(indentifier: String) -> UIViewController {
            return UIStoryboard(name: "Main", bundle: nil) .
                instantiateViewController(withIdentifier: "\(indentifier)")
        }
        
        //获取前一个页面
        func pageViewController(_ pageViewController: UIPageViewController,
                                viewControllerBefore
            viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = allViewControllers.index(of: viewController) else {
                return nil
            }
            
            let previousIndex = viewControllerIndex - 1
            
            guard previousIndex >= 0 else {
                return nil
            }
            
            guard allViewControllers.count > previousIndex else {
                return nil
            }
            
            return allViewControllers[previousIndex]
        }
        
        //获取后一个页面
        func pageViewController(_ pageViewController: UIPageViewController,
                                viewControllerAfter
            viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = allViewControllers.index(of: viewController) else {
                return nil
            }
            
            let nextIndex = viewControllerIndex + 1
            let orderedViewControllersCount = allViewControllers.count
            
            guard orderedViewControllersCount != nextIndex else {
                return nil
            }
            
            guard orderedViewControllersCount > nextIndex else {
                return nil
            }
            
            return allViewControllers[nextIndex]
        }
}

//
//  TopicSearchController.swift
//  paeban_ios_beta
//
//  Created by 尚義 高 on 2016/6/24.
//  Copyright © 2016年 尚義 高. All rights reserved.
//
protocol TopicSearchControllerDelegate {
    func didStartSearching(searchBar: UISearchBar)
    
    func didTapOnSearchButton(searchBar: UISearchBar)
    
    func didTapOnCancelButton(searchBar: UISearchBar)
    
    func didChangeSearchText(searchBar: UISearchBar)
}

import UIKit

class TopicSearchController: UISearchController, UISearchBarDelegate {

    var customDelegate: TopicSearchControllerDelegate!
    var customSearchBar: TopicSearchBar!
    
    init(searchResultsController: UIViewController!, searchBarFrame: CGRect, searchBarFont: UIFont, searchBarTextColor: UIColor, searchBarTintColor: UIColor) {
        super.init(searchResultsController: searchResultsController)
        
        configureSearchBar(searchBarFrame, font: searchBarFont, textColor: searchBarTextColor, bgColor: searchBarTintColor)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureSearchBar(frame: CGRect, font: UIFont, textColor: UIColor, bgColor: UIColor) {
        customSearchBar = TopicSearchBar(frame: frame, font: font , textColor: textColor)
        customSearchBar.barTintColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        customSearchBar.tintColor = textColor
        customSearchBar.showsBookmarkButton = false
        customSearchBar.showsCancelButton = false
        
        customSearchBar.delegate = self
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        customDelegate.didStartSearching(searchBar)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        customSearchBar.resignFirstResponder()
        customDelegate.didTapOnSearchButton(searchBar)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        customSearchBar.resignFirstResponder()
        customDelegate.didTapOnCancelButton(searchBar)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        customDelegate.didChangeSearchText(searchBar)
    }
}

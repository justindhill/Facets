//
//  OZLSearchController.swift
//  Facets
//
//  Created by Justin Hill on 1/2/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

class OZLSearchController: UISearchController {
    
    // UISearchController doesn't play nice with UISearchBarStyleMinimal. Just make the superview
    // of the search bar's container the same background color as the search bar
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.searchBar.superview?.backgroundColor = self.searchBar.backgroundColor
        
        if let nav = self.presentingViewController as? UINavigationController {
            if let resultSubviews = self.searchResultsController?.view.subviews {
                for view in resultSubviews {
                    if let view = view as? UIScrollView {
                        view.contentInset.top = self.topLayoutGuide.length + nav.navigationBar.frame.size.height
                        break;
                    }
                }
            }
        }
    }
}

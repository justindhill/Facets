//
//  OZLSplitViewPlaceholderPaneViewController.swift
//  Facets
//
//  Created by Justin Hill on 12/27/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

import UIKit

class OZLSplitViewPlaceholderPane: UIViewController {
    convenience init() {
        self.init(nibName: "OZLSplitViewPlaceholderPane", bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

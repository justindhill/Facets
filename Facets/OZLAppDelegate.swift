//
//  OZLAppDelegate.swift
//  Facets
//
//  Created by Justin Hill on 1/1/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit

class OZLAppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        #if !DEBUG
            BITHockeyManager.sharedHockeyManager().configureWithIdentifier("8d240e4921f15253d040d9347ad7d9ac")
            BITHockeyManager.sharedHockeyManager().startManager()
            BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation()
        #endif
        
        OZLNetwork.sharedInstance()
        OZLSingleton.sharedInstance()
        
        NSURLProtocol.registerClass(OZLURLProtocol.self)

        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.tintColor = UIColor.facetsBrandColor()
        self.window?.backgroundColor = UIColor.whiteColor()
        
        let vc = OZLMainTabControllerViewController()
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
        
        return true
    }
}

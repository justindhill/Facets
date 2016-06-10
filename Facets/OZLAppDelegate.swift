//
//  OZLAppDelegate.swift
//  Facets
//
//  Created by Justin Hill on 1/1/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit
import HockeySDK

class OZLAppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        if OZLThirdPartyIntegrations.Enabled {
            #if !DEBUG
                BITHockeyManager.sharedHockeyManager().configureWithIdentifier(OZLThirdPartyIntegrations.HockeyApp.AppKey)
                BITHockeyManager.sharedHockeyManager().startManager()
                BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation()
            #endif

            HelpshiftCore.initializeWithProvider(HelpshiftAll.sharedInstance())
            HelpshiftCore.installForApiKey(OZLThirdPartyIntegrations.Helpshift.APIKey,
                domainName: OZLThirdPartyIntegrations.Helpshift.Domain,
                appID: OZLThirdPartyIntegrations.Helpshift.AppId
            )
        }

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

    func applicationDidBecomeActive(application: UIApplication) {
        OZLSingleton.sharedInstance().startSessionUpkeep()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        OZLSingleton.sharedInstance().suspendSessionUpkeep()
    }
}

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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if OZLThirdPartyIntegrations.Enabled {
            #if !DEBUG
                BITHockeyManager.shared().configure(withIdentifier: OZLThirdPartyIntegrations.HockeyApp.AppKey)
                BITHockeyManager.shared().start()
                BITHockeyManager.shared().authenticator.authenticateInstallation()
            #endif

            HelpshiftCore.initialize(with: HelpshiftAll.sharedInstance())
            HelpshiftCore.install(forApiKey: OZLThirdPartyIntegrations.Helpshift.APIKey,
                domainName: OZLThirdPartyIntegrations.Helpshift.Domain,
                appID: OZLThirdPartyIntegrations.Helpshift.AppId
            )
        }

        OZLNetwork.sharedInstance()
        OZLSingleton.sharedInstance()

        URLProtocol.registerClass(OZLURLProtocol.self)

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.tintColor = UIColor.facetsBrand()
        self.window?.backgroundColor = UIColor.white

        let vc = OZLMainTabControllerViewController()
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        OZLSingleton.sharedInstance().startSessionUpkeep()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        OZLSingleton.sharedInstance().suspendSessionUpkeep()
    }
}

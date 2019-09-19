//
//  AppDelegate.swift
//  Serial
//
//  Created by Ayden Panhuyzen on 2019-04-04.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        applyAppearance()
        return true
    }
    
    private func applyAppearance() {
        window?.tintColor = UIColor(named: "tint")
        UITextField.appearance().keyboardAppearance = .dark
        UIScrollView.appearance().indicatorStyle = .white
        UITableViewCell.appearance().backgroundColor = UIColor(named: "tableViewCellBackground")
        UITableViewCell.appearance().selectedBackgroundView = {
            let view = UIView()
            view.backgroundColor = UIColor(named: "tableViewCellSelectionBackground")
            return view
        }()
        UITextField.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).textColor = UIColor(named: "textFieldText")
        UILabel.appearance(whenContainedInInstancesOf: [UITextField.self]).textColor = UIColor(named: "textFieldPlaceholder")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    private func returnToHome() -> ViewController? {
        guard let root = window?.rootViewController as? UINavigationController else { return nil }
        root.popToRootViewController(animated: false)
        root.presentedViewController?.dismiss(animated: false, completion: nil)
        return root.viewControllers.first as? ViewController
    }
}

extension AppDelegate {
    private enum LaunchShortcut: String {
        case scan
        
        init?(shortcutItem: UIApplicationShortcutItem) {
            guard let identifier = shortcutItem.type.split(separator: ".").last else { return nil }
            self.init(rawValue: String(identifier))
        }
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard let shortcut = LaunchShortcut(shortcutItem: shortcutItem) else { completionHandler(false); return }
        switch shortcut {
        case .scan:
            returnToHome()?.showCamera()
        }
    }
}

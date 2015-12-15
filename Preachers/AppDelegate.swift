//
//  AppDelegate.swift
//  Preachers
//
//  Created by Abel Anca on 9/18/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit
import Parse
//import Fabric
//import Crashlytics
import ReachabilitySwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let defaults            = NSUserDefaults.standardUserDefaults()
    
    /// Reachability class for getting status of network
    var reachability: Reachability?
    
    /// Save network connection status
    var bIsNetworkReachable = false

    
    // only for test !!
    var curUserID: String?
    
    lazy var storyboardLogin: UIStoryboard = {
        var storyboard      = UIStoryboard(name: "Login", bundle: nil)
        
        return storyboard
        }()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //Fabric.with([Crashlytics.self()])
        Parse.setApplicationId("fnNa3HlNjZ8P04TM9nattQ4Gk2hspRvEb1xGYf2z", clientKey: "6gh1zhWnoDJkv6OX7SXLwAdQYxej4aHJZZvhmvXy")
        
        loadCurrentUser()
        
        checkNetworkConnection()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        checkNetworkConnection()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - Custom Methods
    
    func loadCurrentUser() {
        if let objectID = defaults.objectForKey(k_UserDef_LoggedInUserID) as? String {
            curUserID = objectID
        }
    }
    
    // MARK: - Reachability Methods
    
    func checkNetworkConnection() {
        do {
            let reachability = try Reachability.reachabilityForInternetConnection()
            self.reachability = reachability
        } catch {
            print("Unable to create Reachability")
            return
        }
        
        if let tempReachability = reachability {
            tempReachability.whenReachable = { reachability in
                // keep in mind this is called on a background thread
                // and if you are updating the UI it needs to happen
                // on the main thread, like this:
                dispatch_async(dispatch_get_main_queue()) {
                    if reachability.isReachableViaWiFi() {
                        print("Reachable via WiFi")
                    } else {
                        print("Reachable via Cellular")
                    }
                    
                    self.bIsNetworkReachable = true
                }
            }
            
            tempReachability.whenUnreachable = { reachability in
                // keep in mind this is called on a background thread
                // and if you are updating the UI it needs to happen
                // on the main thread, like this:
                dispatch_async(dispatch_get_main_queue()) {
                    print("Not reachable")
                    
                    self.bIsNetworkReachable = false
                }
            }
            
            if tempReachability.isReachable() {
                bIsNetworkReachable = true
            }
            else {
                bIsNetworkReachable = false
            }
            
            do {
                try tempReachability.startNotifier()
            } catch {
                print("Unable to start notifier")
            }
        }
    }

}

// MARK: - Convenience Construction

let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
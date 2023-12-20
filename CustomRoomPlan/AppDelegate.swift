//
//  AppDelegate.swift
//  CustomRoomPlan
//
//  Created by Oleh on 20.12.2023.
//

import UIKit
import RoomPlan

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        var configurationName = "Default Configuration"
        if !RoomCaptureSession.isSupported {
            configurationName = "Unsupported Device"
        }
        return UISceneConfiguration(name: configurationName, sessionRole: connectingSceneSession.role)
    }
}


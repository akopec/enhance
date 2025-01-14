//
//  AppDelegate.swift
//  Enhance
//
//  Created by Jonathan Baker on 1/10/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let navBarAppearance = UINavigationBarAppearance()

        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(named: "ZoomEnhanceTeal")

        let titleTextAttributes: [NSAttributedString.Key : Any]  = [
            .font: UIFont.systemFont(ofSize: 20, weight: .heavy),
            .foregroundColor: UIColor.white
        ]

        navBarAppearance.titleTextAttributes = titleTextAttributes
        navBarAppearance.largeTitleTextAttributes = titleTextAttributes

        let barButtonTextAttributes: [NSAttributedString.Key : Any]  = [
            .font: UIFont.systemFont(ofSize: 16, weight: .bold),
        ]

        let barButtonItemAppearance = UIBarButtonItemAppearance(style: .plain)

        barButtonItemAppearance.normal.titleTextAttributes = barButtonTextAttributes
        barButtonItemAppearance.disabled.titleTextAttributes = barButtonTextAttributes
        barButtonItemAppearance.highlighted.titleTextAttributes = barButtonTextAttributes
        barButtonItemAppearance.focused.titleTextAttributes = barButtonTextAttributes

        navBarAppearance.buttonAppearance = barButtonItemAppearance
        navBarAppearance.backButtonAppearance = barButtonItemAppearance
        navBarAppearance.doneButtonAppearance = barButtonItemAppearance

        let navBar = UINavigationBar.appearance()
        navBar.tintColor = .white
        navBar.standardAppearance = navBarAppearance
        navBar.scrollEdgeAppearance = navBarAppearance
        navBar.compactAppearance = navBarAppearance
        navBar.compactScrollEdgeAppearance = navBarAppearance

        let toolbarAppearance = UIToolbarAppearance()
        toolbarAppearance.configureWithOpaqueBackground()
        toolbarAppearance.backgroundColor = UIColor(named: "ZoomEnhanceTeal")
        toolbarAppearance.buttonAppearance = barButtonItemAppearance

        let toolbar = UIToolbar.appearance()
        toolbar.tintColor = .white
        toolbar.standardAppearance = toolbarAppearance
        toolbar.compactAppearance = toolbarAppearance
        toolbar.scrollEdgeAppearance = toolbarAppearance
        toolbar.compactScrollEdgeAppearance = toolbarAppearance


        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

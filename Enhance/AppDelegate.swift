//
//  AppDelegate.swift
//  Enhance
//
//  Created by Jonathan Baker on 4/22/17.
//
//

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties

    var window: UIWindow?


    // MARK: - UIApplicationDelegate

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        configureAppearance()
        configureWindow()
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }


    // MARK: - Private

    private func configureWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: PhotoSelectionViewController())
        window?.makeKeyAndVisible()
    }

    private func configureAppearance() {
        UINavigationBar.appearance().barStyle = .black
        UINavigationBar.appearance().barTintColor = Color.teal()
        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: Font.GTWalsheimProBoldOblique(size: 20)
        ]
    }
}

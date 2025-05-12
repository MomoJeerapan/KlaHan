//
//  KlaHanApp.swift
//  KlaHan
//
//  Created by COSCI_LAB on 26/4/2568 BE.
//

import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}


@main
struct KlaHanApp: App {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                HomeView() // หรือ HomeView
            } else {
                ContentView() // หรือ LoginView
            }
        }    }
}




//
//  FaithDateApp.swift
//  App
//
//  Created by MacBook on 4/17/25.
//

import SwiftUI
import FirebaseCore

// Define a class to handle AppDelegate responsibilities
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure() // Configure Firebase
    return true
  }
}

@main
struct FaithDateApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthenticationViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}

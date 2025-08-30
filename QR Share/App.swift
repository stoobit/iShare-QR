//
//  QR_ShareApp.swift
//  QR Share
//
//  Created by Till Brügmann on 11.09.24.
//

import SwiftUI

@main
struct QR_ShareApp: App {
    var body: some Scene {
        WindowGroup {
            if let data = UserDefaults(suiteName: "group.stoobitshare.com") {
                ContentView()
                    .defaultAppStorage(data)
            } else {
                ContentView()
            }
        }
    }
}

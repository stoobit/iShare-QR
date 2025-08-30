//
//  ContentView.swift
//  QR Share
//
//  Created by Till Brügmann on 11.09.24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                ContentUnavailableView(
                    "Step 1", systemImage: "square.and.arrow.up",
                    description: Text("Share a file on this device.")
                )
                
                ContentUnavailableView(
                    "Step 2", systemImage: "qrcode",
                    description: Text("Create a QR-Code with stoobit share.")
                )
                
                ContentUnavailableView(
                    "Step 3", systemImage: "iphone.gen3",
                    description: Text("Scan the code with another device to receive the file.")
                )
                
                Text("Your files are uploaded to tmpfiles.org and temporarily stored for 60 minutes.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
            }
            .foregroundStyle(Color.primary, Color.blue)
            .navigationTitle("stoobit share")
        }
    }
}

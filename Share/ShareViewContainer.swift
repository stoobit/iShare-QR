//
//  ShareViewContainer.swift
//  Share
//
//  Created by Till Brügmann on 30.08.25.
//

import SwiftUI
import Social
import Analytics

struct ShareViewContainer: View {
    @Environment(\.openURL) var openURL
    @State var model = ShareViewModel()
    
    var itemProviders: [NSItemProvider]
    var extensionContext: NSExtensionContext?
    
    var body: some View {
        NavigationStack {
            List {
               Section {
                    NavigationLink {
                        OptionWiFiView(
                            itemProviders: itemProviders,
                            extensionContext: extensionContext
                        )
                    } label: {
                        ShareOption(
                            "WiFi Sharing", systemImage: "wifi",
                            description: "Faster, but only works if all devices are on the same Wi-Fi."
                        )
                    }
                    
                    NavigationLink {
                        OptionCloudView(
                            itemProviders: itemProviders,
                            extensionContext: extensionContext
                        )
                    } label: {
                        ShareOption(
                            "Cloud Sharing", systemImage: "cloud",
                            description: "Works anywhere, but file transfer might be a bit slower."
                        )
                    }
                } header: {
                    Text("Options")
                } footer: {
                    Text("Select an option to share your files via a QR code.")
                }
                
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(Color.accentColor)
                        .frame(maxHeight: .infinity)
                        .font(.title)
                    
                    VStack(alignment: .leading) {
                        Text("Premium")
                            .font(.headline)
                        
                        Text("Share multiple files at once.")
                            .foregroundStyle(Color.secondary)
                            .font(.footnote)
                    }
                    
                    Spacer(minLength: 0)
                    
                    Button(action: openApp) {
                        Text("View")
                            .font(.headline)
                            .padding(.vertical, 7)
                            .padding(.horizontal, 13)
                            .background(.ultraThickMaterial)
                            .foregroundStyle(Color.accentColor)
                            .clipShape(.capsule)
                    }
                    .buttonStyle(.plain)
                    .frame(maxHeight: .infinity)
                }
                .padding(5)
            }
            .navigationTitle("stoobit share")
            .overlay(alignment: .bottom) {
                Text("Thank you for using stoobit share.")
                    .foregroundStyle(Color.secondary)
                    .font(.footnote)
            }
            .toolbar {
                if #available(iOS 26, *) {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", systemImage: "xmark") {
                            dismiss()
                        }
                    }
                } else {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func ShareOption(
        _ title: String, systemImage: String, description: String
    ) -> some View {
        HStack(alignment: .top, spacing: 20) {
            Image(systemName: systemImage)
                .foregroundStyle(Color.accentColor)
                .font(.largeTitle)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .foregroundStyle(Color.secondary)
            }
        }
        .padding(5)
    }
    
    func dismiss() {
        extensionContext?.completeRequest(returningItems: [])
    }
    
    func openApp() {
        openURL(URL(string: "stoobitshare")!)
    }
}

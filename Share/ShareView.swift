//
//  ShareView.swift
//  Share
//
//  Created by Till Brügmann on 11.09.24.
//

import SwiftUI
import UniformTypeIdentifiers
import Social
import Analytics

struct ShareView: View {
    @State var model = ShareViewModel()
    
    var itemProviders: [NSItemProvider]
    var extensionContext: NSExtensionContext?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Group {
                    Rectangle()
                        .foregroundStyle(Color.blue.gradient)
                    Rectangle()
                        .foregroundStyle(.regularMaterial)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all)
                
                VStack {
                    Spacer()
                    QRView()
                    Spacer()
                    
                    Text("Scan this QR code with another device to download this file.")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .padding()
                        .padding(.horizontal)
                        .modifier(BackgroundViewModifier())
                        .padding(.horizontal)
                        
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("stoobit share")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: dismiss)
                }
            }
        }
        .ignoresSafeArea(.all)
        .task {
            await model.share(itemProviders: itemProviders)
        }
    }
    
    @ViewBuilder func QRView() -> some View {
        let description = Text("Make sure you are connected to the internet.")
        
        if let _ = model.error {
            ContentUnavailableView(
                "Upload Failed",
                systemImage: "wifi.slash",
                description: description
            )
            .foregroundStyle(Color.primary)
        } else if let qrcode = model.qrcode  {
            Image(uiImage: qrcode)
                .resizable()
                .interpolation(.none)
                .renderingMode(.template)
                .foregroundStyle(Color.primary)
                .scaledToFit()
                .frame(width: 190, height: 190)
                .padding()
        } else {
            ProgressView()
                .controlSize(.extraLarge)
        }
    }
    
    func dismiss() {
        extensionContext?.completeRequest(returningItems: [])
    }
}

struct BackgroundViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect()
        } else {
            content
                .background(.quaternary, in: Capsule())
        }
    }
}

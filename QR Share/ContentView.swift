//
//  ContentView.swift
//  QR Share
//
//  Created by Till Brügmann on 11.09.24.
//

import SwiftUI
import StoreKit

struct ContentView: View {
    @AppStorage("Premium") var isPremium: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                if isPremium == false {
                    Section("Premium") {
                        ProductView(id: "com.stoobit.qrshare.premium")
                            .productViewStyle(CustomProductStyle())
                            .padding(5)
                            .onInAppPurchaseCompletion { product, result in
                                if case .success(.success(_)) = result {
                                    withAnimation {
                                        isPremium = true
                                    }
                                }
                            }
                    }
                }
                
                Section("How It Works") {
                    Instruction(
                        "Step 1", systemImage: "square.and.arrow.up",
                        description: Text("Share on one or multiple files on this device.")
                    )
                
                    Instruction(
                        "Step 2", systemImage: "qrcode",
                        description: Text("Create a QR code to share your file(s) locally or across networks.")
                    )
                
                    Instruction(
                        "Step 3", systemImage: "iphone.gen3",
                        description: Text("Scan the code with another device to receive the file(s).")
                    )
                }
            }
            .foregroundStyle(Color.primary, Color.blue)
            .navigationTitle("stoobit share")
            .scrollIndicators(.hidden)
        }
    }
    
    @ViewBuilder
    func Instruction(_ title: String, systemImage: String, description: Text) -> some View {
        HStack(alignment: .top, spacing: 20) {
            Image(systemName: systemImage)
                .foregroundStyle(Color.accentColor)
                .font(.largeTitle)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                
                description
                    .foregroundStyle(Color.secondary)
            }
        }
        .padding(5)
    }
}

struct CustomProductStyle: ProductViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        switch configuration.state {
        case .loading:
            ProgressView()
        case .success(let product):
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "crown.fill")
                    .foregroundStyle(Color.accentColor)
                    .frame(maxHeight: .infinity)
                    .font(.title)
                
                VStack(alignment: .leading) {
                    Text(product.displayName)
                        .font(.headline)
                    
                    Text(product.description)
                        .foregroundStyle(Color.secondary)
                        .font(.footnote)
                }
                
                Spacer(minLength: 0)
                
                Button(action: { configuration.purchase() }) {
                    Text(product.displayPrice)
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
        default:
            Text("Something goes wrong...")
        }
    }
}

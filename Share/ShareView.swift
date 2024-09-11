//
//  ShareView.swift
//  Share
//
//  Created by Till Brügmann on 11.09.24.
//

import SwiftUI
import UniformTypeIdentifiers
import Social

struct ShareView: View {
    var itemProviders: [NSItemProvider]
    var extensionContext: NSExtensionContext?
    
    var body: some View {
        VStack {
            Text("iShare QR")
                .font(.largeTitle.bold())
            
            Spacer()
            
            Spacer()
            
            Button(action: dismiss) {
                Text("Done")
                    .foregroundStyle(Color.white)
                    .font(.headline)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color.main)
                    .clipShape(.capsule)
            }
            .padding(.vertical)
        }
        .padding(30)
        .onAppear(perform: share)
    }
    
    func dismiss() {
        extensionContext?.completeRequest(returningItems: [])
    }
    
    func share() {
        DispatchQueue.global(qos: .userInteractive).async {
            guard let item = itemProviders.first else {
                return
            }
            
            guard let type = item.registeredContentTypes.first else {
                return
            }
            
            let _ = item.loadDataRepresentation(for: type) { data, _ in
                if let data = data {
                    print(data)
                }
            }
        }
    }
}

//
//  ShareView.swift
//  Share
//
//  Created by Till Brügmann on 11.09.24.
//

import SwiftUI
import UniformTypeIdentifiers
import CoreImage.CIFilterBuiltins
import Social

struct ShareView: View {
    @State var result: String = ""
    
    var itemProviders: [NSItemProvider]
    var extensionContext: NSExtensionContext?
    
    var body: some View {
        VStack {
            Text("iShare QR")
                .font(.largeTitle.bold())
                .padding(.bottom, 5)
            
            Text("Scan this QR-Code with another device to download this file.")
                .multilineTextAlignment(.center)
            
            Spacer()
            
            if result == "" {
                ProgressView()
                    .controlSize(.extraLarge)
            } else if result == "error" {
                ContentUnavailableView(
                    "Upload Failed", systemImage: "wifi.slash",
                    description: Text(
                        "Make sure you are connected to the internet."
                    )
                )
                .foregroundStyle(Color.primary, Color.blue)
            } else {
                ResultView()
            }
            
            Spacer()
            
            Button(action: dismiss) {
                Text("Done")
                    .foregroundStyle(Color.primary)
                    .font(.headline)
                    .frame(width: 100, height: 50)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(.capsule)
            }
        }
        .padding([.top, .horizontal], 30)
        .padding(
            .bottom, UIDevice.current.userInterfaceIdiom == .pad ? 30 : 0
        )
        .task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            share()
        }
    }
    
    @ViewBuilder func ResultView() -> some View {
        if result == "error" {
            ContentUnavailableView(
                "Ein Fehler ist aufgetreten.",
                systemImage: "exclamationmark.triangle.fill"
            )
        } else if result == "" {
            ProgressView()
        } else {
            Image(uiImage: generateQRCode(from: result))
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: 190)
                .padding()
                .background {
                    Rectangle()
                        .foregroundStyle(.blue)
                        .clipShape(.rect(cornerRadius: 20))
                }
        }
    }
    
    func generateQRCode(from string: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            
            let maskFilter = CIFilter.blendWithMask()
            maskFilter.maskImage = outputImage.applyingFilter("CIColorInvert")
            maskFilter.inputImage = CIImage(color: CIColor(color: .white))
            let coloredImage = maskFilter.outputImage!
            
            if let cgimg = context.createCGImage(coloredImage, from: coloredImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
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
                    Task {
                        await store(data: data, type: type)
                    }
                }
            }
        }
    }
    
    func store(data: Data, type: UTType) {
        do {
            guard let filetype = type.preferredFilenameExtension else {
                return
            }
            
            let url = URL.documentsDirectory.appending(
                path: "temporary.\(filetype)"
            )
            
            print(url)
            try data.write(to: url, options: [.atomic])
            
            upload(to: url)
        } catch {
            
        }
    }
}

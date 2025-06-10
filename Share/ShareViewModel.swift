//
//  ShareViewModel.swift
//  Share
//
//  Created by Till Brügmann on 10.06.25.
//

import Analytics
import UIKit.UIImage
import UniformTypeIdentifiers
import CoreImage.CIFilterBuiltins

@Observable final class ShareViewModel {
    var analytics = Analytics(key: "1fafa0f31d10d9725fac48d5f1dbae2e")
    
    var error: Error?
    var qrcode: UIImage?
    
    func share(itemProviders: [NSItemProvider]) async {
        guard let item = itemProviders.first else {
            return
        }
        guard let type = item.registeredContentTypes.first else {
            return
        }
        
        if type == .url {
            analytics.track("File Upload", properties: [
                "state": "success",
                "filetype": "url"
            ])
            analytics.flush()
            
            do {
                let url = try await item
                    .loadItem(forTypeIdentifier: type.identifier) as? URL
                
                if let url = url {
                    self.qrcode = generate(from: url.absoluteString)
                }
            } catch {
                self.error = error
            }
            
            return
        }
        
        let _ = item.loadDataRepresentation(for: type) { data, _ in
            if let data = data {
                self.store(data: data, type: type)
            }
        }
    }
    
    private func store(data: Data, type: UTType) {
        do {
            guard let filetype = type.preferredFilenameExtension else {
                return
            }
            
            let url = URL.documentsDirectory
                .appending(path: "sharedfile.\(filetype)")
            
            try data.write(to: url, options: [.atomic])
            upload(to: url)
        } catch {
            self.error = error
        }
    }
    
    private func upload(to fileurl: URL) {
        let request: URLRequest
        
        do {
            request = try createRequest(fileurl: fileurl)
            analytics.track("API Connection", properties: ["state": "success"])
            analytics.flush()
        } catch {
            analytics.track("API Connection", properties: ["state": "failure"])
            analytics.flush()
            
            self.error = error
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            do {
                guard let data = data, error == nil else {
                    self.error = error
                    return
                }
                
                let model = try JSONDecoder().decode(
                    FetchModel.self, from: data
                )
                
                var temporary = model.data.url
                temporary.replace(
                    "tmpfiles.org/", with: "tmpfiles.org/dl/"
                )
                
                self.analytics.track(
                    "File Upload",
                    properties: [
                        "state": "success",
                        "filetype": fileurl.pathExtension.lowercased()
                    ]
                )
                self.analytics.flush()
                
                self.qrcode = self.generate(from: temporary)
            } catch {
                self.analytics.track(
                    "File Upload", properties: [
                        "state": "success",
                        "filetype": fileurl.pathExtension.lowercased()
                    ]
                )
                self.analytics.flush()
                
                self.error = error
            }
            
            try? FileManager.default
                .removeItem(atPath: fileurl.path)
        }
        
        task.resume()
    }
    
    private func generate(from string: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            
            let maskFilter = CIFilter.blendWithMask()
            maskFilter.maskImage = outputImage.applyingFilter("CIColorInvert")
            maskFilter.inputImage = CIImage(color: CIColor(color: .label))
            let coloredImage = maskFilter.outputImage!
            
            if let cgimg = context.createCGImage(coloredImage, from: coloredImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    
    // MARK: - REQUEST HELPER METHODS
    private func createRequest(fileurl: URL) throws -> URLRequest {
        let boundary = generateBoundaryString()
        
        let url = URL(string: "https://tmpfiles.org/api/v1/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try createBody(
            filePathKey: "file", urls: [fileurl], boundary: boundary
        )
        
        return request
    }
    
    private func createBody(with parameters: [String: String]? = nil, filePathKey: String, urls: [URL], boundary: String) throws -> Data {
        var body = Data()
        
        parameters?.forEach { key, value in
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }
        
        for url in urls {
            let filename = url.lastPathComponent
            let data = try Data(contentsOf: url)
            
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(filename)\"\r\n")
            body.append("Content-Type: \(url.mimeType)\r\n\r\n")
            body.append(data)
            body.append("\r\n")
        }
        
        body.append("--\(boundary)--\r\n")
        return body
    }
    
    private func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
}


extension URL {
    var mimeType: String {
        return UTType(filenameExtension: pathExtension)?.preferredMIMEType ?? "application/octet-stream"
    }
    
    var filename: String {
        self.deletingPathExtension().lastPathComponent
    }
}

extension Data {
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}

struct FetchModel: Codable {
    let status: String?
    let data: FetchContent
}

struct FetchContent: Codable {
    let url: String
}


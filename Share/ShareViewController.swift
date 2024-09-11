//
//  ShareViewController.swift
//  Share
//
//  Created by Till Brügmann on 11.09.24.
//

import UIKit
import Social
import SwiftUI

class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        
        if let itemProviders = (
            extensionContext!.inputItems.first as? NSExtensionItem
        )?.attachments {
            
            let hostingView = UIHostingController(rootView: ShareView(
                itemProviders: itemProviders,
                extensionContext: extensionContext
            ))
            
            hostingView.view.frame = view.frame
            view.addSubview(hostingView.view)
        }
    }
}

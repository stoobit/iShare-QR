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
            
            addChild(hostingView)
            hostingView.view
                .translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(hostingView.view)
            hostingView.didMove(toParent: self)
            
            NSLayoutConstraint.activate([
                hostingView.view.widthAnchor.constraint(
                    equalTo: view.widthAnchor, multiplier: 1
                ),
                hostingView.view.heightAnchor.constraint(
                    equalTo: view.heightAnchor, multiplier: 1
                ),
                hostingView.view.centerXAnchor.constraint(
                    equalTo: view.centerXAnchor
                ),
                hostingView.view.centerYAnchor.constraint(
                    equalTo: view.centerYAnchor
                )
            ])
        }
    }
}

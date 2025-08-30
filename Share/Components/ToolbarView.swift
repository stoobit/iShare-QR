//
//  ToolbarView.swift
//  Share
//
//  Created by Till Brügmann on 30.08.25.
//

import SwiftUI

struct ToolbarView: ToolbarContent {
    var dismiss: () -> Void
    
    var body: some ToolbarContent {
        if #available(iOS 26, *) {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close", systemImage: "xmark") {
                    dismiss()
                }
            }
        } else {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    dismiss()
                }
            }
        }
    }
}

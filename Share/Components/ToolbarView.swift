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
            ToolbarItem(placement: .confirmationAction) {
                Button("Close", action: dismiss)
            }
        } else {
            ToolbarItem(placement: .confirmationAction) {
                Button("Close", action: dismiss)
                    .foregroundStyle(Color.primary)
            }
        }
    }
}

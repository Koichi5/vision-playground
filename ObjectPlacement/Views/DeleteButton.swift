//
//  DeleteButton.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/01/30.
//

import SwiftUI

struct DeleteButton: View {
    var deletionHandler: (() -> Void)?
    var body: some View {
        Button {
            if let deletionHandler {
                deletionHandler()
            }
        } label: {
             Image(systemName: "trash")
        }
        .accessibilityLabel("Delete object")
        .glassBackgroundEffect()
    }
}

#Preview {
    DeleteButton()
}

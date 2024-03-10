//
//  Day25ContentViewOther.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/10.
//

import SwiftUI
import RealityKit
import UniformTypeIdentifiers

struct Day25ContentViewOther: View {
    
    var viewModel: Day25ViewModel
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        VStack {
            TargetView(items: viewModel.rightListItems)
                .dropDestination(for: String.self) { items, location in
                    for item in items {
                        viewModel.leftListItems.removeAll() { $0 == item }
                        if !viewModel.rightListItems.contains(item) {
                            viewModel.rightListItems.append(item)
                        }
                    }
                    return true
                }
        }
        .padding()
    }
}

//
//  Day17ContentVIew.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/09.
//

import SwiftUI

struct Day17ContentView: View {
    
    var viewModel: Day17ViewModel
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        NavigationStack {
            Day17ObjectsView(viewModel: viewModel)
        }
        .ornament(
            visibility: .visible, attachmentAnchor: .scene(.bottom)) {
                Day17BottomControls(viewModel: viewModel)
                    .padding(.top, 50)
            }
    }
}

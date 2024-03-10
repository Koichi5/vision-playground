//
//  Day25ContentView.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/10.
//

import SwiftUI
import RealityKit
import UniformTypeIdentifiers

struct Day25ContentView: View {
    
    var viewModel: Day25ViewModel
    
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        VStack {
            TargetView(items: viewModel.leftListItems)
                .dropDestination(for: String.self) { items, location in
                    for item in items { viewModel.rightListItems.removeAll { $0 == item }
                        if !viewModel.leftListItems.contains(item) {
                            viewModel.leftListItems.append(item)
                        }
                    }
                    return true
                }
        }
        .padding()
        .onAppear() {
            openWindow(id: "other")
        }
    }
}

struct TargetView: View {
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color(.secondarySystemFill))
                
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                            .padding(12)
                            .cornerRadius(8)
                            .shadow(radius: 1, x: 1, y: 1)
                            .draggable(item)
                    }
                    Spacer()
                }
                .padding(.vertical)
            }
        }
    }
}

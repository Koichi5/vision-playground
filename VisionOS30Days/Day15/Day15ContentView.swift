//
//  Day15ContentView.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/08.
//

import SwiftUI

struct Day15ContentView: View {
    
    @Environment(Day15ViewModel.self) private var model
    
    var body: some View {
        @Bindable var model = model
        
        NavigationStack {
            VStack {
                WindowToggle(
                    title: model.selectedType.title, id: "model", isShowing: $model.isShowing)
            }
        }
    }
    
    private struct WindowToggle: View {
        var title: String
        var id: String
        @Binding var isShowing: Bool
        
        @Environment(\.openWindow) private var openWindow
        @Environment(\.dismissWindow) private var dismissWindow
        
        var body: some View {
            Toggle(title, isOn: $isShowing)
                .onChange(of: isShowing) { wasShowing, isShowing in
                    if isShowing {
                        openWindow(id: id)
                    } else {
                        dismissWindow(id: id)
                    }
                }
                .toggleStyle(.button)
        }
    }
}

#Preview {
    Day15ContentView()
}

//
//  Day15HomeView.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/08.
//

import SwiftUI

struct Day15HomeView: View {
    
    @Environment(Day15ViewModel.self) private var model
    
    var body: some View {
        
        @Bindable var model = model
        
        TabView(selection: $model.selectedType) {
            ForEach(Day15ViewModel.SelectionType.allCases) { selectionType in
                Day15ContentView()
                    .environment(model)
                    .tag(selectionType)
                    .tabItem {
                        Label(
                            selectionType.title,
                            systemImage: selectionType.imageName
                        )
                    }
            }
        }
    }
}

#Preview {
    Day15HomeView()
}

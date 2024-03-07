//
//  Day11ContentView.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/08.
//

import SwiftUI

struct Day11ContentView: View {
    
    @Environment(Day11ViewModel.self) private var model
    var body: some View {
        @Bindable var model = model
        
        NavigationStack {
            VStack {
                Spacer()
                
                VStack {
                    Text(model.finalTitle)
                        .monospaced()
                        .font(.system(size: 50, weight: .bold))
                        .padding(.horizontal, 40)
                        .hidden()
                        .overlay(alignment: .leading) {
                            Text(model.titleText)
                                .monospaced()
                                .font(.system(size: 50, weight: .bold))
                                .padding(.leading, 40)
                        }
                    Text("詳細はフェードイン")
                        .font(.title)
                        .opacity(model.isTitleFinished ? 1 : 0)
                }
                
                Spacer()
            }
            .typeText(text: $model.titleText, finalText: model.finalTitle, isFinished: $model.isTitleFinished, isAnimated: !model.isTitleFinished)
            .animation(.default.speed(0.25), value: model.isTitleFinished)
        }
    }
}

#Preview {
    Day11ContentView()
}

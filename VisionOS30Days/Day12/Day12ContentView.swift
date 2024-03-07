//
//  Day12ContentView.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/07.
//

import SwiftUI
import MapKit

struct Day12ContentView: View {
    
    @ObservedObject var locationHandler = Day12LocationHandler.shared
    @State private var position: MapCameraPosition = .automatic
    
    var body: some View {
        VStack {
            Spacer()
            Text("Location: \(self.locationHandler.lastLocation)")
                .padding(10)
            Text("Count: \(self.locationHandler.count)")
            Spacer()
            
            Map(position: $position)
                .mapStyle(.hybrid(elevation: .realistic))
                .onChange(of: self.locationHandler.cameraPosition) {
                    position = self.locationHandler.cameraPosition
                }
                .padding(40)
            
            Spacer()
            Button(self.locationHandler.updatesStarted ? "Stop Location Updates" : "Start Location") {
                self.locationHandler.updatesStarted ? self.locationHandler.stopLocationUpdates() : self.locationHandler.startLocationUpdates()
            }
            .buttonStyle(.bordered)
            Spacer()
        }
    }
}

#Preview {
    Day12ContentView()
}

//
//  WrapperView.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/16.
//


import SwiftUI

// prerequisites in Info.plist: NSUserActivityTypes contains type, UIApplicationSceneManifest/UIApplicationSupportsMultipleScenes = YES
// accepts NSUserActivity.targetContentIdentifier = type
// see also: https://developer.apple.com/documentation/swiftui/scene/handlesexternalevents(matching:)

struct UserActivityWindowGroup<Content: View, Payload: Codable>: Scene {
    var type: String
    @ViewBuilder var content: (Payload) -> Content

    init(type: String, payloadType: Payload.Type, @ViewBuilder content: @escaping (Payload) -> Content) {
        self.type = type
        self.content = content
    }

    var body: some Scene {
        WindowGroup {
            WrapperView(type: type, content: content)
        }
        .handlesExternalEvents(matching: [type])
    }

    struct WrapperView: View {
        var type: String
        @ViewBuilder var content: (Payload) -> Content
        @State private var payload: Result<Payload, Error>?
        @Environment(\.dismissWindow) private var dismissWindow

        var body: some View {
            switch payload {
            case nil:
                ProgressView().onContinueUserActivity(type) {
                    do {
                        self.payload = .success(try $0.typedPayload(Payload.self))
                    } catch {
                        self.payload = .failure(error)
                    }
                }
            case .success(let payload):
                content(payload)
            case .failure(let error):
                Text(error.localizedDescription)
                Button("Dismiss") {
                    dismissWindow()
                }
            }
        }
    }
}

// MARK: - helper extensions

protocol CustomUserActivityType: Codable {
    static var type: String { get }
}

extension NSUserActivity {
    convenience init(_ activity: CustomUserActivityType) throws {
        self.init(activityType: type(of: activity).type)
        targetContentIdentifier = type(of: activity).type
        try setTypedPayload(activity)
    }
}

extension NSItemProvider {
    convenience init(_ activty: CustomUserActivityType) throws {
        self.init(object: try NSUserActivity(activty))
    }
}

extension View {
    func onDragActivity(_ activity: CustomUserActivityType) -> some View {
        onDrag {
            do {
                return try NSItemProvider(activity)
            } catch {
                NSLog("%@", "error on NSItemProvider(\(activity)), error = \(String(describing: error))")
                return NSItemProvider()
            }
        }
    }
}

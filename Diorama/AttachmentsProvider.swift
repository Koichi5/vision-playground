//
//  AttachmentsProvider.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/02/09.
//

import SwiftUI

final class AttachmentsProvider {
    var attachments: [ObjectIdentifier: AnyView] = [:]
    
    var sortedTagViewPairs: [(tag: ObjectIdentifier, view: AnyView)] {
        attachments.map { key, value in
            (tag: key, view: value)
        }.sorted { $0.tag < $1.tag }
    }
}

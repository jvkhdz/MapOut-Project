//
//  ShareHelper.swift
//  MapOut
//
//  Created by Mate Javakhadze on 24.04.26.
//

import Foundation
import SwiftUI

struct ShareHelper {
    @MainActor
    static func renderCard(plan: PlansModel) -> UIImage {
        let view = ShareCardView(plan: plan)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0
        return renderer.uiImage ?? UIImage()
    }
}

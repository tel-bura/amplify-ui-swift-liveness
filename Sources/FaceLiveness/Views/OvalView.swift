//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

class OvalView: UIView {
    let ovalFrame: CGRect

    init(frame: CGRect, ovalFrame: CGRect) {
        self.ovalFrame = ovalFrame
        super.init(frame: frame)
        backgroundColor = .clear
    }

    override func draw(_ rect: CGRect) {
        print("OvalView draw minX: \(rect.minX) minY: \(rect.minY) midX: \(rect.midX) midY: \(rect.midY) maxX: \(rect.maxX) maxY: \(rect.maxY) width: \(rect.width) height: \(rect.height)")
        let mask = UIBezierPath(rect: bounds)
        let oval = UIBezierPath(ovalIn: ovalFrame)
        mask.append(oval.reversing())

        UIColor.white.withAlphaComponent(0.9).setFill()
        mask.fill()

        UIColor.clear.setFill()
        UIColor.white.setStroke()
        oval.lineWidth = 8
        oval.stroke()
    }

    required init?(coder: NSCoder) { nil }
}

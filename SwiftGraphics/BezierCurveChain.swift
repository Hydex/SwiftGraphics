//
//  BezierCurveChain.swift
//  SwiftGraphics
//
//  Created by Jonathan Wight on 1/16/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import CoreGraphics

public struct BezierCurveChain {

    // TODO: This isn't really an accurate representaiton of what we want.
    // TODO: Control points should be shared (and mirrored) between neighbouring curves.
    public let curves:[BezierCurve]

    public init(curves:[BezierCurve]) {

        var previousCurve:BezierCurve?
        self.curves = curves.map() {
            (curve:BezierCurve) -> BezierCurve in

            var newCurve = curve
            if let previousEndPoint = previousCurve?.end {
                if let start = curve.start {
//                    assert(previousEndPoint == start)
                    newCurve = BezierCurve(controls:curve.controls, end:curve.end)
                }
            }

            previousCurve = curve
            return newCurve
        }
    }
}

extension BezierCurveChain: Printable {
    public var description: String {
        get {
            return ", ".join(curves.map() { $0.description })
        }
    }
}

public extension CGContext {
    func stroke(chain:BezierCurveChain) {
        // Stroke all curves as a single path
        let start = chain.curves[0].start
        CGContextMoveToPoint(self, start!.x, start!.y)
        for curve in chain.curves {
            addToPath(curve)
        }
        CGContextStrokePath(self)
    }
}

//
//  Scaling.swift
//  SwiftGraphics
//
//  Created by Jonathan Wight on 8/24/14.
//  Copyright (c) 2014 schwa.io. All rights reserved.
//

import CoreGraphics

// MARK: Scaling and alignment.

public enum Scaling {
    case none
    case proportionally
    case toFit
}

public enum Alignment {
    case center
    case top
    case topLeft
    case topRight
    case left
    case bottom
    case bottomLeft
    case bottomRight
    case right
}

public func scaleAndAlignRectToRect(inner:CGRect, outer:CGRect, scaling:Scaling, align:Alignment) -> CGRect {
    var resultRect = CGRectZero

    switch scaling {
    case .toFit:
        resultRect = outer
    case .proportionally:
        var theScaleFactor = CGFloat(1.0)
        if (outer.size.width / inner.size.width < outer.size.height / inner.size.height) {
            theScaleFactor = outer.size.width / inner.size.width
        }
        else {
            theScaleFactor = outer.size.height / inner.size.height
        }
        resultRect.size = inner.size * theScaleFactor
    case .none:
        switch align {
            //
        case .center:
            resultRect.origin.x = outer.origin.x + (outer.size.width - inner.size.width) * 0.5
            resultRect.origin.y = outer.origin.y + (outer.size.height - inner.size.height) * 0.5
        case .top:
            resultRect.origin.x = outer.origin.x + (outer.size.width - inner.size.width) * 0.5
            resultRect.origin.y = outer.origin.y + outer.size.height - inner.size.height
        case .topLeft:
            resultRect.origin.x = outer.origin.x
            resultRect.origin.y = outer.origin.y + outer.size.height - inner.size.height
        case .topRight:
            resultRect.origin.x = outer.origin.x + outer.size.width - inner.size.width
            resultRect.origin.y = outer.origin.y + outer.size.height - inner.size.height
        case .left:
            resultRect.origin.x = outer.origin.x
            resultRect.origin.y = outer.origin.y + (outer.size.height - inner.size.height) * 0.5
        case .bottom:
            resultRect.origin.x = outer.origin.x + (outer.size.width - inner.size.width) * 0.5
            resultRect.origin.y = outer.origin.y
        case .bottomLeft:
            resultRect.origin.x = outer.origin.x
            resultRect.origin.y = outer.origin.y
        case .bottomRight:
            resultRect.origin.x = outer.origin.x + outer.size.width - inner.size.width
            resultRect.origin.y = outer.origin.y
        case .right:
            resultRect.origin.x = outer.origin.x + outer.size.width - inner.size.width
            resultRect.origin.y = outer.origin.y + (outer.size.height - inner.size.height) * 0.5
        }
    }

    return resultRect
}

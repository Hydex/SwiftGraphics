//
//  Model.swift
//  ArcTest
//
//  Created by Jonathan Wight on 8/23/14.
//  Copyright (c) 2014 schwa.io. All rights reserved.
//

import Cocoa

import SwiftGraphics

enum CircularDirection {
    case Clockwise
    case CounterClockwise
    }

struct QuartzArc {
    var center:CGPoint
    var radius:CGFloat
    var startAngle:CGFloat
    var endAngle:CGFloat
    var clockwise:CircularDirection
}

struct JavaArc {
    var extent:CGFloat // endAngle
    var size:CGSize
    var start:CGFloat // startAngle
    var topLeft:CGPoint
    var angle:CGFloat // ANGLE - NOT in java arc
}

struct Arc {
    var center:CGPoint = CGPointZero
    var size:CGSize = CGSizeZero
    var startAngle:CGFloat = 0 // Currently degrees
    var endAngle:CGFloat = 360 // Currently degrees
//    var direction:CircularDirection = .Clockwise
    var rotation:CGFloat = 0.0 // Currently degrees
}

extension CGContextRef {
    func stroke(arc:Arc) {
        let radius = arc.size.width * 0.5
        let rotation = DegreesToRadians(arc.rotation)
        let sx:CGFloat = 1.0
        let sy:CGFloat = arc.size.height / arc.size.width

        let transform = CGAffineTransform.identity().rotated(rotation).scaled(sx,sy)
    
        CGContextConcatCTM(self, transform)

        CGContextAddArc(self, arc.center.x, arc.center.y, radius, arc.startAngle, arc.endAngle, 1)
        CGContextStrokePath(self)

        CGContextConcatCTM(self, transform.inverted)
    }
}

// http://svn.apache.org/repos/asf/xmlgraphics/batik/branches/svg11/sources/org/apache/batik/ext/awt/geom/ExtendedGeneralPath.java

// * AffineTransform.getRotateInstance
//     *     (angle, arc.getX()+arc.getWidth()/2, arc.getY()+arc.getHeight()/2);

extension Arc {

    static func arcWithSVGDefinition(#x0:CGFloat, y0:CGFloat, rx:CGFloat, ry:CGFloat, angle:CGFloat, largeArcFlag:Bool, sweepFlag:Bool, x:CGFloat, y:CGFloat) -> Arc {
        return computeArc(x0, y0, rx, ry, angle, largeArcFlag, sweepFlag, x, y)
    }

}

func computeArc(x0:CGFloat, y0:CGFloat, rx:CGFloat, ry:CGFloat, angle:CGFloat, largeArcFlag:Bool, sweepFlag:Bool, x:CGFloat, y:CGFloat) -> Arc
{

    //
    // Elliptical arc implementation based on the SVG specification notes
    //

    // Compute the half distance between the current and the final point
    let dx2 = (x0 - x) * 0.5
    let dy2 = (y0 - y) * 0.5
    // Convert angle from degrees to radians
    let angle = DegreesToRadians(angle % 360)
    let cosAngle = cos(angle)
    let sinAngle = sin(angle)

    //
    // Step 1 : Compute (x1, y1)
    //
    let x1 = cosAngle * dx2 + sinAngle * dy2
    let y1 = -sinAngle * dx2 + cosAngle * dy2
    // Ensure radii are large enough
    var rx = abs(rx)
    var ry = abs(ry)
    var Prx = rx * rx
    var Pry = ry * ry
    var Px1 = x1 * x1
    var Py1 = y1 * y1
    // check that radii are large enough
    let radiiCheck = Px1 / Prx + Py1 / Pry
    if  radiiCheck > 1 {
        rx = sqrt(radiiCheck) * rx
        ry = sqrt(radiiCheck) * ry
        Prx = rx * rx
        Pry = ry * ry
    }

    //
    // Step 2 : Compute (cx1, cy1)
    //
    var sign:CGFloat = (largeArcFlag == sweepFlag) ? -1 : 1
    var sq = ((Prx*Pry)-(Prx*Py1)-(Pry*Px1)) / ((Prx*Py1)+(Pry*Px1))
    sq = (sq < 0) ? 0 : sq
    let coef = sign * sqrt(sq)
    let cx1 = coef * ((rx * y1) / ry)
    let cy1 = coef * -((ry * x1) / rx)

    //
    // Step 3 : Compute (cx, cy) from (cx1, cy1)
    //
    let sx2 = (x0 + x) * 0.5
    let sy2 = (y0 + y) * 0.5
    let cx = sx2 + (cosAngle * cx1 - sinAngle * cy1)
    let cy = sy2 + (sinAngle * cx1 + cosAngle * cy1)

    //
    // Step 4 : Compute the angleStart (angle1) and the angleExtent (dangle)
    //
    let ux = (x1 - cx1) / rx
    let uy = (y1 - cy1) / ry
    let vx = (-x1 - cx1) / rx
    let vy = (-y1 - cy1) / ry
    // Compute the angle start
    var n = sqrt((ux * ux) + (uy * uy))
    var p = ux // (1 * ux) + (0 * uy)
    sign = (uy < 0) ? -1 : 1
    var angleStart = RadiansToDegrees(sign * acos(p / n))

    // Compute the angle extent
    n = sqrt((ux * ux + uy * uy) * (vx * vx + vy * vy))
    p = ux * vx + uy * vy
    sign = (ux * vy - uy * vx < 0) ? -1 : 1
    var angleExtent = RadiansToDegrees(sign * acos(p / n))
    if !sweepFlag && angleExtent > 0 {
        angleExtent -= 360
    }
    else if sweepFlag && angleExtent < 0 {
        angleExtent += 360
    }
    angleExtent %= 360
    angleStart %= 360

    var arc = Arc()
    arc.center = CGPoint(x:cx, y:cy)
    arc.size = CGSize(width:rx * 2, height:ry * 2)
    arc.startAngle = -angleStart
    arc.endAngle = -angleExtent
    arc.rotation = angle
    return arc
}

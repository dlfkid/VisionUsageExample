//
//  CoreGraphicExtensions.swift
//  VisionUsageExample
//
//  Created by ravendeng on 2022/11/10.
//

import CoreGraphics

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x * right, y: left.y * right)
}

extension CGSize {
    var bottomRightPoint: CGPoint {
        return CGPoint(x: width, y: height)
    }
}

extension CGPoint {
    var pointSize: CGSize {
        return CGSize(width: x, height: y)
    }
    
    func absolutePoint(in rect: CGRect) -> CGPoint {
        return CGPoint(x: x * rect.size.width, y: y * rect.size.height) + rect.origin
    }
}

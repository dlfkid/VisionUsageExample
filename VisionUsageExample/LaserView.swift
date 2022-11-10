//
//  LaserView.swift
//  VisionUsageExample
//
//  Created by ravendeng on 2022/11/10.
//

import UIKit

struct Laser {
    var origin: CGPoint
    var focus: CGPoint
}

struct LaserViewLimit {
    let maxX: CGFloat
    let maxY: CGFloat
    let midY: CGFloat
}

class LaserView: UIView {
    
    private var lasers: [Laser] = []
    
    func add(laser: Laser) {
        lasers.append(laser)
    }
    
    func cleanLasers() {
        lasers.removeAll()
        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }
}

extension LaserView {
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        defer {
            context.restoreGState()
        }
        context.saveGState()
        for laser in lasers {
            context.addLines(between: [laser.origin, laser.focus])
            context.setStrokeColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.4)
            context.setLineWidth(4.5)
            context.strokePath()
            
            context.addLines(between: [laser.origin, laser.focus])
            context.setStrokeColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.8)
            context.setLineWidth(3.0)
            context.strokePath()
        }
    }
}

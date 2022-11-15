//
//  RecordButton.swift
//  VisionUsageExample
//
//  Created by ravendeng on 2022/11/15.
//

import UIKit

class RecordButton: UIButton {
    var progress: CGFloat = 0.0 {
        didSet {
            DispatchQueue.main.async {
                self.setNeedsDisplay()
            }
        }
    }
}

extension RecordButton {
    
    static let kRecordButtonRadius: CGFloat = 218
    
    func resetProgress() {
        progress = 0.0
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        context?.translateBy(x: bounds.minX, y: bounds.minY)
        context?.scaleBy(x: bounds.width / RecordButton.kRecordButtonRadius, y: bounds.height / RecordButton.kRecordButtonRadius)
        
        let expression: CGFloat =  -progress * 360
        
        let buttonPath = UIBezierPath(ovalIn: CGRect(x: 26, y: 26, width: 166, height: 166))
        UIColor.red.setFill()
        buttonPath.fill()
        
        let ringBackgroundPath = UIBezierPath(ovalIn: CGRect(x: 8.5, y: 8.5, width: 200, height: 200))
        UIColor.white.setStroke()
        ringBackgroundPath.lineWidth = 19
        ringBackgroundPath.lineCapStyle = .round
        ringBackgroundPath.stroke()
        
        let progressRingRect = CGRect(x: 8.5, y: 8.5, width: 200, height: 200)
        let progressRingPath = UIBezierPath()
        progressRingPath.addArc(withCenter: CGPoint(x: progressRingRect.midX, y: progressRingRect.midY), radius: progressRingRect.width / 2, startAngle: -90 * CGFloat.pi/180, endAngle: -(expression + 90) * CGFloat.pi/180, clockwise: true)
        UIColor.red.setStroke()
        progressRingPath.lineWidth = 19
        progressRingPath.lineCapStyle = .round
        progressRingPath.stroke()
        context?.restoreGState()
    }
}

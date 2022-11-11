//
//  FacePresentView.swift
//  VisionUsageExample
//
//  Created by ravendeng on 2022/11/10.
//

import UIKit

class FacePresentView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        clearsContextBeforeDrawing = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 左眼
    var leftEye: [CGPoint] = []
    
    /// 右眼
    var rightEye: [CGPoint] = []
    
    /// 左眼眉
    var leftEyebrow: [CGPoint] = []
    
    /// 右眼眉
    var rightEyebrow: [CGPoint] = []
    
    /// 鼻子
    var nose: [CGPoint] = []
    
    /// 外嘴唇
    var outerLips: [CGPoint] = []
    
    /// 内嘴唇
    var innerLips: [CGPoint] = []
    
    /// 面部轮廓
    var faceContour: [CGPoint] = []
    
    /// 边框
    var boundingBox = CGRect.zero
    
    func cleanAllFaceScannedData() {
        leftEye.removeAll()
        rightEye.removeAll()
        leftEyebrow.removeAll()
        rightEyebrow.removeAll()
        nose.removeAll()
        outerLips.removeAll()
        innerLips.removeAll()
        faceContour.removeAll()
        boundingBox = .zero
        
        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }
}

extension FacePresentView {
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.saveGState()
        defer {
            // 本函数执行完毕后, 恢复GS状态
            context.restoreGState()
        }
        // 决定边框路经
        context.addRect(boundingBox)
        // 设定绘制颜色为黄色
        UIColor.yellow.setStroke()
        // 绘制边框
        context.strokePath()
        
        // 设定绘制颜色为白色
        UIColor.white.setStroke()
        // 如果有左眼数据
        if !leftEye.isEmpty {
            // 添加眼部的点为绘制路经
            context.addLines(between: leftEye)
            // 封闭添加的绘制路经
            context.closePath()
            // 绘制眼部轮廓
            context.strokePath()
        }
        // 如果有右眼数据
        if !rightEye.isEmpty {
            // 添加眼部的点为绘制路经
            context.addLines(between: rightEye)
            // 封闭添加的绘制路经
            context.closePath()
            // 绘制眼部轮廓
            context.strokePath()
        }
        if !leftEyebrow.isEmpty {
            // 添加眼部的点为绘制路经
            context.addLines(between: leftEyebrow)
            // 绘制眼部轮廓
            context.strokePath()
        }
        if !rightEyebrow.isEmpty {
            // 添加眼部的点为绘制路经
            context.addLines(between: rightEyebrow)
            // 绘制眼部轮廓
            context.strokePath()
        }
        if !nose.isEmpty {
            // 添加眼部的点为绘制路经
            context.addLines(between: nose)
            // 绘制眼部轮廓
            context.strokePath()
        }
        if !innerLips.isEmpty {
            // 添加眼部的点为绘制路经
            context.addLines(between: innerLips)
            // 封闭添加的绘制路经
            context.closePath()
            // 绘制眼部轮廓
            context.strokePath()
        }
        if !outerLips.isEmpty {
            // 添加眼部的点为绘制路经
            context.addLines(between: outerLips)
            // 封闭添加的绘制路经
            context.closePath()
            // 绘制眼部轮廓
            context.strokePath()
        }
        if !faceContour.isEmpty {
            // 添加眼部的点为绘制路经
            context.addLines(between: faceContour)
            // 绘制眼部轮廓
            context.strokePath()
        }
    }
}

//
//  PhotoStackProcessor.swift
//  VisionUsageExample
//
//  Created by ravendeng on 2022/11/16.
//

import CoreImage
import Vision

class PhotoStackProcessor {
    
    /// 缓存的帧数据
    var frameBuffer: [CIImage] = []
    
    /// 已经对齐的帧
    var alignedFrameBuffer: [CIImage] = []
    
    /// 完成回调
    var completion: ((CIImage) -> Void)?
    
    /// 是否正在对帧处理
    var isProcessingFrames = false
    
    /// 总帧数
    var frameCount: Int {
        return frameBuffer.count
    }
    
    /// 拼接新的帧
    /// - Parameter frame: 帧
    func add(frame: CIImage) {
        guard isProcessingFrames else {
            return
        }
        frameBuffer.append(frame)
    }
    
    /// 执行帧对齐
    /// - Parameters:
    ///   - request: Vison的请求
    ///   - frame: 要被对齐的帧
    func alignImages(request: VNRequest, frame: CIImage) {
        guard
            let results = request.results as? [VNImageTranslationAlignmentObservation],
            let firstResult = results.first else {
            return
        }
        let alignedFrame = frame.transformed(by: firstResult.alignmentTransform)
        alignedFrameBuffer.append(alignedFrame)
    }
    
//    func combineFrames() {
//        var finalImage = alignedFrameBuffer.removeFirst()
//        let filter = AverageStackingFilter()
//    }
}

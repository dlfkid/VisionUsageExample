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
    
    func processFrames(completion: ((CIImage) -> Void)?) {
        isProcessingFrames = true
        self.completion = completion
        let firstFrame = frameBuffer.removeFirst()
        alignedFrameBuffer.append(firstFrame)
        for frame in frameBuffer {
            let request = VNTranslationalImageRegistrationRequest(targetedCIImage: frame)
            do {
                let sequenceHandler = VNSequenceRequestHandler()
                try sequenceHandler.perform([request], on: firstFrame)
            } catch {
                print(error.localizedDescription)
            }
            alignImages(request: request, frame: frame)
        }
        combineFrames()
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
    
    func cleanUp(image: CIImage) {
        frameBuffer.removeAll()
        alignedFrameBuffer.removeAll()
        isProcessingFrames = false
        if let completion = completion {
            DispatchQueue.main.async {
                completion(image)
            }
        }
        completion = nil
    }
    
    func combineFrames() {
        var finalImage = alignedFrameBuffer.removeFirst()
        let filter = AverageStackingFilter()
        for (i, image) in alignedFrameBuffer.enumerated() {
            filter.inputCurrentStack = finalImage
            filter.inputNewImage = image
            filter.inputStackCount = Double(i + 1)
            finalImage = filter.outputImage()!
        }
        cleanUp(image: finalImage)
    }
}

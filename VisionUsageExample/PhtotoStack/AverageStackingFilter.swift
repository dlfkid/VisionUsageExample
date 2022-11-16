//
//  AverageStackingFilter.swift
//  VisionUsageExample
//
//  Created by ravendeng on 2022/11/16.
//

import CoreImage

class AverageStackingFilter: CIFilter {
    let kernel: CIBlendKernel
    
    var inputCurrentStack: CIImage?
    
    var inputNewImage: CIImage?
    
    var inputStackCount = 1
    
    override init() {
        guard let url = Bundle.main.url(forResource: "default", withExtension: "metallib") else {
            fatalError("check your build settings")
        }
        do {
            let data = try Data(contentsOf: url)
            kernel = try CIBlendKernel(functionName: "avgStacking", fromMetalLibraryData: data)
        } catch {
            fatalError("函数名错误: \(error.localizedDescription)")
        }
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func outputImage() -> CIImage? {
        guard
            let inputCurrentStack = inputCurrentStack,
            let inputNewImage = inputNewImage
        else {
            return nil
        }
        return kernel.apply(extent: inputCurrentStack.extent, arguments: [inputCurrentStack, inputNewImage, inputStackCount])
    }
}

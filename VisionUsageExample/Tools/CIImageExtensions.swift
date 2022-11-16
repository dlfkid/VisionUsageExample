//
//  CIImageExtensions.swift
//  VisionUsageExample
//
//  Created by ravendeng on 2022/11/16.
//

import CoreImage

extension CIImage {
    func cgImage() -> CGImage? {
        guard let cgImage = cgImage else {
            return CIContext().createCGImage(self, from: extent)
        }
        return cgImage
    }
}

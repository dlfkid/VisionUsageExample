//
//  PhotoStackImageSaver.swift
//  VisionUsageExample
//
//  Created by ravendeng on 2022/11/16.
//

import Foundation
import CoreImage

struct PhotoStackImageSaver {
    let url: URL
    
    init() {
        let uuid = UUID().uuidString
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        url = urls.first!.appendingPathComponent(uuid)
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false)
        } catch {
            print("create imageDir failed: \(error.localizedDescription)")
        }
    }
    
    func write(image: CIImage, as name: String) {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            return
        }
        let context = CIContext()
        let lossyOption = kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption
        guard name.count > 0 else {
            return
        }
        let imgUrl : URL = url.appendingPathComponent("\(name).jpg")
        do {
            try context.writeJPEGRepresentation(of: image, to: imgUrl, colorSpace: colorSpace, options: [lossyOption: 0.9])
        } catch {
            print("create image failed: \(error.localizedDescription)")
        }
    }
}

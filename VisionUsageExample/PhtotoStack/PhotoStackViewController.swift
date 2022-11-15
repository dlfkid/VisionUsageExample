//
//  PhotoStackViewController.swift
//  VisionUsageExample
//
//  Created by ravendeng on 2022/11/15.
//

import UIKit
import PinLayout
import AVFoundation

class PhotoStackViewController: UIViewController {
    
    private let previewView = UIView()
    
    private let containerView = UIView()
    
    private let combinedImageView = UIView()
    
    private let recordButton = RecordButton()
    
    private var session: AVCaptureSession?
    
    private lazy var previewLayer: AVCaptureVideoPreviewLayer? = {
        guard let captureSession = session else {
            return nil
        }
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        return previewLayer
    }()
    
    private var isRecording = false
    
    private let maxFrameCount = 20

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "照片堆叠"
        configreVideoCaptureLayer()
    }
    
    private func configreVideoCaptureLayer() {
        guard let camera = AVCaptureDevice.default(for: .video) else {
            fatalError("不能调用摄像头")
        }
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            let captureSession = AVCaptureSession()
            captureSession.addInput(cameraInput)
            try camera.lockForConfiguration()
            camera.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 5)
            camera.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 5)
            camera.unlockForConfiguration()
            session = captureSession
        } catch {
            fatalError(error.localizedDescription)
        }
        let videoOutput:AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video_data_queue"))
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA ]
        session?.addOutput(videoOutput)
        let videoConnection = videoOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait
        guard let captureLayer = previewLayer else {
            fatalError("创建视频图层失败")
        }
        previewView.layer.addSublayer(captureLayer)
        session?.startRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
}

extension PhotoStackViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    
    }
}

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
    
    private let combinedImageView = UIImageView()
    
    private let recordButton = RecordButton()
    
    private var saver: PhotoStackImageSaver?
    
    private let imageProcessor = PhotoStackProcessor()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("close", for: .normal)
        return button
    }()
    
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
        view.addSubview(previewView)
        view.addSubview(recordButton)
        view.addSubview(containerView)
        containerView.addSubview(combinedImageView)
        closeButton.addTarget(self, action: #selector(closeButtonDidTappedAction), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(recordButtonDidTappedAction), for: .touchUpInside)
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
        previewView.pin.all()
        recordButton.pin.bottom(view.pin.safeArea.bottom).hCenter().size(72)
        containerView.pin.all()
        combinedImageView.pin.all()
    }
}

extension PhotoStackViewController {
    @objc func closeButtonDidTappedAction() {
        containerView.isHidden = true
        recordButton.isEnabled = true
        session?.startRunning()
    }
    
    @objc func recordButtonDidTappedAction() {
        recordButton.isEnabled = false
        isRecording = true
        saver = PhotoStackImageSaver()
    }
    
    func stopRecording() {
        isRecording = false
        recordButton.progress = 0.0
    }
    
    func displayCombinedImage(image: CIImage) {
        session?.stopRunning()
        combinedImageView.image = UIImage(ciImage: image)
        containerView.isHidden = false
    }
}

extension PhotoStackViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if !isRecording {
            return
        }
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
        let cgImage = CIImage(cvImageBuffer: imageBuffer).cgImage() else {
            return
        }
        let image = CIImage(cgImage: cgImage)
        imageProcessor.add(frame: image)
        saver?.write(image: image, as: "stack_image_\(UUID().uuidString)")
        let currentFrame = recordButton.progress * CGFloat(maxFrameCount)
        recordButton.progress = (currentFrame + 1.0) / CGFloat(maxFrameCount)
        if recordButton.progress >= 1.0 {
            stopRecording()
            imageProcessor.processFrames(completion: displayCombinedImage(image:))
        }
    }
}

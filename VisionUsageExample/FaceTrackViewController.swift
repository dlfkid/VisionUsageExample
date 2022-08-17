//
//  FaceTrackViewController.swift
//  VisionUsageExample
//
//  Created by ravendeng on 2022/8/16.
//

import UIKit
import Vision
import AVFoundation

class FaceTrackViewController: UIViewController {
    
    let cameraView = UIView();
    
    let captureButton:UIButton = {
        let captureButton = UIButton(type: .system)
        captureButton.setTitle("开始捕捉", for: .normal)
        captureButton.setTitle("停止捕捉", for: .selected)
        return captureButton
    }()
    
    private let visionSequenceHandler = VNSequenceRequestHandler()
    private lazy var cameraLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo
        guard
            let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: backCamera)
        else { return session }
        session.addInput(input)
        return session
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "人脸追踪"
        view.backgroundColor = .white
        view.addSubview(cameraView)
        view.addSubview(captureButton)
        captureButton.addTarget(self, action: #selector(captureButtonDidTappedAction(sender:)), for: .touchUpInside)
        cameraView.layer.addSublayer(cameraLayer)
        // register to receive buffers from the camera
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
        self.captureSession.addOutput(videoOutput)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cameraView.pin.all(view.pin.safeArea)
        captureButton.pin.bottom(100).width(120).height(44).hCenter(0)
    }
}

extension FaceTrackViewController {
    @objc private func captureButtonDidTappedAction(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        if (sender.isSelected) {
            DispatchQueue.global().async {
                // begin the session
                self.captureSession.startRunning()
            }
        } else {
            DispatchQueue.global().async {
                // end the session
                self.captureSession.stopRunning()
            }
        }
    }
}

extension FaceTrackViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }
}

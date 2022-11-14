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
    
    enum FaceRecognintionMode {
        case FaceLandmark
        case FaceLaser
    }
    
    private var sequenceHandler = VNSequenceRequestHandler()
    
    private let faceDetectView = FacePresentView()
    
    private let laserView = LaserView()
    
    private let captureButton:UIButton = {
        let captureButton = UIButton(type: .system)
        captureButton.setTitle("Start", for: .normal)
        captureButton.setTitle("Stop", for: .selected)
        return captureButton
    }()
    
    private let recognModeToggleButton: UIButton = {
        let captureButton = UIButton(type: .system)
        captureButton.setTitle("FaceLandMark", for: .normal)
        captureButton.setTitle("FaceLaser", for: .selected)
        return captureButton
    }()
    
    let videoDataQueue = DispatchQueue(label: "video data queue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    private var faceRecognMode: FaceRecognintionMode = .FaceLandmark
    
    private lazy var cameraLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private var captureSession: AVCaptureSession = AVCaptureSession()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "人脸追踪"
        view.backgroundColor = .white
        view.addSubview(faceDetectView)
        view.addSubview(laserView)
        view.addSubview(captureButton)
        view.addSubview(recognModeToggleButton)
        captureButton.addTarget(self, action: #selector(captureButtonDidTappedAction(sender:)), for: .touchUpInside)
        recognModeToggleButton.addTarget(self, action: #selector(recognModeToggleButtonDidTappedAction(sender:)), for: .touchUpInside)
        laserView.isHidden = true
        configCaptureSession()
    }
    
    private func configCaptureSession() {
        // Define the capture device we want to use
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .front) else {
          fatalError("No front video camera available")
        }
        
        // Connect the camera to the capture session input
        do {
          let cameraInput = try AVCaptureDeviceInput(device: camera)
          captureSession.addInput(cameraInput)
        } catch {
          fatalError(error.localizedDescription)
        }
        
        // Create the video data output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: videoDataQueue)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        
        // Add the video output to the capture session
        captureSession.addOutput(videoOutput)
        
        let videoConnection = videoOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait
        
        // Configure the preview layer
        cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraLayer.videoGravity = .resizeAspectFill
        cameraLayer.frame = view.bounds
        view.layer.insertSublayer(cameraLayer, at: 0)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        faceDetectView.pin.all()
        laserView.pin.all()
        captureButton.pin.bottom(100).width(120).height(44).hCenter(0)
        recognModeToggleButton.pin.above(of: captureButton, aligned: .center).marginBottom(10).sizeToFit()
    }
}

extension FaceTrackViewController {
    @objc private func captureButtonDidTappedAction(sender: UIButton) {
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
    
    @objc private func recognModeToggleButtonDidTappedAction(sender: UIButton) {
        sender.isSelected.toggle()
        faceRecognMode = sender.isSelected ? .FaceLaser : .FaceLandmark
        switch faceRecognMode {
        case .FaceLandmark:
            faceDetectView.isHidden = false
            laserView.isHidden = true
        case .FaceLaser:
            faceDetectView.isHidden = true
            laserView.isHidden = false
        }
    }
}

extension FaceTrackViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        let detectFaceRequest = VNDetectFaceLandmarksRequest(completionHandler: detectedFace(request:error:))
        do {
            try sequenceHandler.perform([detectFaceRequest], on: imageBuffer, orientation: .leftMirrored)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }
    
    func detectedFace(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNFaceObservation], let result = results.first else {
            faceDetectView.cleanAllFaceScannedData()
            return
        }
        var limit = LaserViewLimit(maxX: 0, maxY: 0, midY: 0)
        DispatchQueue.main.sync {
            limit = LaserViewLimit(maxX: view.bounds.maxX, maxY: view.bounds.maxY, midY: view.bounds.midY)
        }
        switch faceRecognMode {
        case .FaceLandmark:
            faceDetectView.updateFaceView(for: result, previewLayer: cameraLayer)
        case .FaceLaser:
            laserView.updateLaserView(for: result, limit: limit, previewLayer: cameraLayer)
        }
    }
}

func createLandmark(point: CGPoint, to rect: CGRect, previewLayer: AVCaptureVideoPreviewLayer) -> CGPoint {
    let absolute = point.absolutePoint(in: rect)
    let converted = previewLayer.layerPointConverted(fromCaptureDevicePoint: absolute)
    return converted
}

func createLandmarks(points: [CGPoint]?, to rect: CGRect, previewLayer: AVCaptureVideoPreviewLayer) -> [CGPoint]? {
    guard let points = points else {
        return nil
    }
    return points.compactMap { createLandmark(point: $0, to: rect, previewLayer: previewLayer) }
}

extension FacePresentView {
    func convertRect(rect: CGRect, previewLayer: AVCaptureVideoPreviewLayer) -> CGRect {
        let origin = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.origin)
        let size = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.size.bottomRightPoint)
        return CGRect(origin: origin, size: size.pointSize)
    }
    
    func updateFaceView(for result: VNFaceObservation, previewLayer: AVCaptureVideoPreviewLayer) {
        defer {
            DispatchQueue.main.async {
                self.setNeedsDisplay()
            }
        }
        let box = result.boundingBox
        boundingBox = convertRect(rect: box, previewLayer: previewLayer)
        
        guard let landmarks = result.landmarks else {
            return
        }
        
        if let leftEyePoints = createLandmarks(points: landmarks.leftEye?.normalizedPoints, to: box, previewLayer: previewLayer) {
            leftEye = leftEyePoints
        }
        if let rightEyePoints = createLandmarks(points: landmarks.rightEye?.normalizedPoints, to: box, previewLayer: previewLayer) {
            rightEye = rightEyePoints
        }
        if let leftEyebrowPoints = createLandmarks(points: landmarks.leftEyebrow?.normalizedPoints, to: box, previewLayer: previewLayer) {
            leftEyebrow = leftEyebrowPoints
        }
        if let rightEyebrowPoints = createLandmarks(points: landmarks.rightEyebrow?.normalizedPoints, to: box, previewLayer: previewLayer) {
            rightEyebrow = rightEyebrowPoints
        }
        if let nosePoints = createLandmarks(points: landmarks.nose?.normalizedPoints, to: box, previewLayer: previewLayer) {
            nose = nosePoints
        }
        if let innerLipsPoints = createLandmarks(points: landmarks.innerLips?.normalizedPoints, to: box, previewLayer: previewLayer) {
            innerLips = innerLipsPoints
        }
        if let outterLipsPoints = createLandmarks(points: landmarks.outerLips?.normalizedPoints, to: box, previewLayer: previewLayer) {
            outerLips = outterLipsPoints
        }
        if let faceCountourPoints = createLandmarks(points: landmarks.faceContour?.normalizedPoints, to: box, previewLayer: previewLayer) {
            faceContour = faceCountourPoints
        }
    }
}

extension LaserView {
    func updateLaserView(for result: VNFaceObservation, limit: LaserViewLimit, previewLayer: AVCaptureVideoPreviewLayer) {
        cleanLasers()
        let yaw = result.yaw ?? 0.0
        guard yaw != 0.0 else {
            return
        }
        var origins: [CGPoint] = []
        if let point = result.landmarks?.leftPupil?.normalizedPoints.first {
            let origin = createLandmark(point: point, to: result.boundingBox, previewLayer: previewLayer)
            origins.append(origin)
        }
        if let point = result.landmarks?.rightPupil?.normalizedPoints.first {
            let origin = createLandmark(point: point, to: result.boundingBox, previewLayer: previewLayer)
            origins.append(origin)
        }
        let avgY = origins.map { point in
            point.y
        }.reduce(0.0, +) / CGFloat(origins.count)
        let foucusY = (avgY < limit.midY) ? 0.75 * limit.maxY : 0.25 * limit.maxY
        let foucusX = yaw.doubleValue < 0.0 ? -100.0 : limit.maxX + 100.0
        let foucus = CGPoint(x: foucusX, y: foucusY)
        for origin in origins {
            let laser = Laser(origin: origin, focus: foucus)
            add(laser: laser)
        }
        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }
}

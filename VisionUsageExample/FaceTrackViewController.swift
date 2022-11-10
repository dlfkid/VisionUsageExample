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
    
    private var sequenceHandler = VNSequenceRequestHandler()
    
    private let cameraView = UIView()
    
    private let faceDetectView = FacePresentView()
    
    private let laserView = LaserView()
    
    private let captureButton:UIButton = {
        let captureButton = UIButton(type: .system)
        captureButton.setTitle("开始捕捉", for: .normal)
        captureButton.setTitle("停止捕捉", for: .selected)
        return captureButton
    }()
    
    private var faceViewHidden: Bool = false
    
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
        view.addSubview(faceDetectView)
        view.addSubview(laserView)
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
        faceDetectView.pin.all(view.pin.safeArea)
        laserView.pin.all(view.pin.safeArea)
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
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        let detectFaceRequest = VNDetectFaceRectanglesRequest(completionHandler: detectedFace(request:error:))
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
        let limit = LaserViewLimit(maxX: view.bounds.maxX, maxY: view.bounds.maxY, midY: view.bounds.midY)
        faceViewHidden ? laserView.updateLaserView(for: result, limit: limit, previewLayer: self.cameraLayer) : faceDetectView.updateFaceView(for: result, previewLayer: self.cameraLayer)
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
        self.boundingBox = convertRect(rect: box, previewLayer: previewLayer)
        
        guard let landmarks = result.landmarks else {
            return
        }
        
        if let leftEyePoints = createLandmarks(points: landmarks.leftEye?.normalizedPoints, to: box, previewLayer: previewLayer) {
            self.leftEye = leftEyePoints
        }
        if let rightEyePoints = createLandmarks(points: landmarks.rightEye?.normalizedPoints, to: box, previewLayer: previewLayer) {
            self.rightEye = rightEyePoints
        }
        if let leftEyebrowPoints = createLandmarks(points: landmarks.leftEyebrow?.normalizedPoints, to: box, previewLayer: previewLayer) {
            self.leftEyebrow = leftEyebrowPoints
        }
        if let rightEyebrowPoints = createLandmarks(points: landmarks.rightEyebrow?.normalizedPoints, to: box, previewLayer: previewLayer) {
            self.rightEyebrow = rightEyebrowPoints
        }
        if let nosePoints = createLandmarks(points: landmarks.nose?.normalizedPoints, to: box, previewLayer: previewLayer) {
            self.nose = nosePoints
        }
        if let innerLipsPoints = createLandmarks(points: landmarks.innerLips?.normalizedPoints, to: box, previewLayer: previewLayer) {
            self.innerLips = innerLipsPoints
        }
        if let outterLipsPoints = createLandmarks(points: landmarks.outerLips?.normalizedPoints, to: box, previewLayer: previewLayer) {
            self.outerLips = outterLipsPoints
        }
        if let faceCountourPoints = createLandmarks(points: landmarks.faceContour?.normalizedPoints, to: box, previewLayer: previewLayer) {
            self.faceContour = faceCountourPoints
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

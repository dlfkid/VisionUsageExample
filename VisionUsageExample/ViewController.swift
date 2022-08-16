//
//  ViewController.swift
//  VisionUsageExample
//
//  Created by ravendeng on 2022/8/16.
//

import UIKit
import PinLayout
import SwiftUI

class ViewController: UIViewController {
    
    let faceTrackButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Vision使用Example"
        
        faceTrackButton.setTitle("人脸追踪", for: .normal);
        faceTrackButton.addTarget(self, action: #selector(faceTrackButtonDidTappedAction(sender:)), for: .touchUpInside)
        view.addSubview(faceTrackButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        faceTrackButton.pin.top(view.pin.safeArea).margin(10).height(44).width(100).hCenter()
    }
    
    @objc private func faceTrackButtonDidTappedAction(sender: UIButton) {
        let faceTrackViewController = FaceTrackViewController()
        navigationController?.pushViewController(faceTrackViewController, animated: true)
    }
}


//
//  ViewController.swift
//  VisionUsageExample
//
//  Created by ravendeng on 2022/8/16.
//

import UIKit
import PinLayout
import SwiftUI

struct VisionExampleCases {
    let name: String
    let action: Selector
}

class ViewController: UIViewController {
    
    private let visionExamplerCases: [VisionExampleCases] = {
        let faceRecognitionCase = VisionExampleCases(name: "面部识别", action: #selector(faceTrackButtonDidTappedAction))
        let photoStack = VisionExampleCases(name: "照片堆叠", action: #selector(photoStackButtonDidTappedAction))
        
        return [faceRecognitionCase, photoStack]
    }()
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    static let kVisionExampleCases = "kVisionExampleCases"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Vision使用Example"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ViewController.kVisionExampleCases)
        view.addSubview(tableView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.pin.all(view.pin.safeArea)
    }
    
    @objc private func faceTrackButtonDidTappedAction() {
        let faceTrackViewController = FaceTrackViewController()
        navigationController?.pushViewController(faceTrackViewController, animated: true)
    }
    
    @objc private func photoStackButtonDidTappedAction() {
        let photoStackViewController = PhotoStackViewController()
        navigationController?.pushViewController(photoStackViewController, animated: true)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visionExamplerCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: ViewController.kVisionExampleCases, for: indexPath)
        let visionCase = visionExamplerCases[indexPath.row]
        cell.textLabel?.text = visionCase.name
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let visionCase = visionExamplerCases[indexPath.row]
        self.perform(visionCase.action)
    }
}


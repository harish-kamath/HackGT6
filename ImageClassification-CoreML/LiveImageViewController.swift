//
//  ViewController.swift
//  MobileNetApp
//
//  Created by GwakDoyoung on 28/05/2018.
//  Copyright © 2018 GwakDoyoung. All rights reserved.
//

import UIKit
import Vision

func orderCreate(_ orderName:String){
    let url = URL(string: "https://gateway-staging.ncrcloud.com/order/orders")!
    var request = URLRequest(url: url)
    request.setValue("CorrID", forHTTPHeaderField: "nep-correlation-id")
    request.setValue("hack-harishkamath", forHTTPHeaderField: "nep-organization")
    request.setValue("8a008d406ddb112d016e0bd3c63f0045", forHTTPHeaderField: "nep-application-key")
    request.setValue("Basic \("acct:root@hack_harishkamath:0XDe4F!9+>".toBase64())", forHTTPHeaderField: "Authorization")
    request.httpBody = Data(base64Encoded: orderName)
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print("error: \(error)")
        } else {
            if let response = response as? HTTPURLResponse {
                print("statusCode: \(response.statusCode)")
            }
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("data: \(dataString)")
            }
        }
    }
    task.resume()
}

class LiveImageViewController: UIViewController {
    var label = ""
    // MARK: - UI Properties
    @IBOutlet weak var videoPreview: UIView!
    @IBOutlet weak var labelLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    
    @IBOutlet weak var inferenceLabel: UILabel!
    @IBOutlet weak var etimeLabel: UILabel!
    @IBOutlet weak var fpsLabel: UILabel!
    
    // MARK - Performance Measurement Property
    private let 👨‍🔧 = 📏()
    
    // MARK - Core ML model
    // MobileNet(iOS11+), MobileNetV2(iOS11+), MobileNetV2FP16(iOS11.2+), MobileNetV2Int8LUT(iOS12+)
    // Resnet50(iOS11+), Resnet50FP16(iOS11.2+), Resnet50Int8LUT(iOS12+), Resnet50Headless(N/A)
    // SqueezeNet(iOS11+), SqueezeNetFP16(iOS11.2+), SqueezeNetInt8LUT(iOS12+)
    let classificationModel = MobileNetV2()
    
    // MARK: - Vision Properties
    var request: VNCoreMLRequest?
    var visionModel: VNCoreMLModel?
    
    // MARK: - AV Properties
    var videoCapture: VideoCapture!
    
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup ml model
        setUpModel()
        
        // setup camera
        setUpCamera()
        
        // setup delegate for performance measurement
        👨‍🔧.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.videoCapture.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.videoCapture.stop()
    }
    
    // MARK: - Setup Core ML
    func setUpModel() {
        if let visionModel = try? VNCoreMLModel(for: classificationModel.model) {
            self.visionModel = visionModel
            request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
            request?.imageCropAndScaleOption = .scaleFill
        } else {
            fatalError()
        }
    }
    
    
    // MARK: - 초기 세팅
    
    func setUpCamera() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.fps = 50
        videoCapture.setUp(sessionPreset: .high) { success in
            
            if success {
                // UI에 비디오 미리보기 뷰 넣기
                if let previewLayer = self.videoCapture.previewLayer {
                    self.videoPreview.layer.addSublayer(previewLayer)
                    self.resizePreviewLayer()
                }
                
                // 초기설정이 끝나면 라이브 비디오를 시작할 수 있음
                self.videoCapture.start()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resizePreviewLayer()
    }
    
    func resizePreviewLayer() {
        videoCapture.previewLayer?.frame = videoPreview.bounds
    }
}

// MARK: - VideoCaptureDelegate
extension LiveImageViewController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame pixelBuffer: CVPixelBuffer?/*, timestamp: CMTime*/) {
        
        // 카메라에서 캡쳐된 화면은 pixelBuffer에 담김.
        // Vision 프레임워크에서는 이미지 대신 pixelBuffer를 바로 사용 가능
        if let pixelBuffer = pixelBuffer {
            // start of measure
            self.👨‍🔧.🎬👏()
            
            // start predict
            self.predictUsingVision(pixelBuffer: pixelBuffer)
        }
    }
}

// MARK: - Inference
extension LiveImageViewController {
    func predictUsingVision(pixelBuffer: CVPixelBuffer) {
        guard let request = request else { fatalError() }
        // vision framework configures the input size of image following our model's input configuration automatically
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        try? handler.perform([request])
    }
    
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        // middle of measure
        self.👨‍🔧.🏷(with: "endInference")
        
        // 메인큐에서 결과 출력
        if let classificationResults = request.results as? [VNClassificationObservation] {
            showClassificationResult(results: classificationResults)
        } else if let mlFeatureValueResults = request.results as? [VNCoreMLFeatureValueObservation] {
            showCustomResult(results: mlFeatureValueResults)
        }
        
        DispatchQueue.main.sync {
            // end of measure
            self.👨‍🔧.🎬🤚()
        }
    }
    
    func showClassificationResult(results: [VNClassificationObservation]) {
        guard let result = results.first else {
            showFailResult()
            return
        }
        
        showResults(objectLabel: result.identifier, confidence: result.confidence)
    }
    
    func showCustomResult(results: [VNCoreMLFeatureValueObservation]) {
        guard let result = results.first else {
            showFailResult()
            return
        }
        
        showFailResult() // TODO
    }
    
    func showFailResult() {
        DispatchQueue.main.sync {
            self.labelLabel.text = "n/a result"
            self.confidenceLabel.text = "-- %"
        }
    }
    
    func showResults(objectLabel: String, confidence: VNConfidence) {
        DispatchQueue.main.sync {
            //self.labelLabel.text = objectLabel
            //self.confidenceLabel.text = "\(round(confidence * 100)) %"
            if(confidence > 0.3){
                print(objectLabel)
                if objectLabel.contains("computer") {
                    let alert = UIAlertController(title: "Checked Out!", message: "You have checked this item out: \(label)", preferredStyle: UIAlertController.Style.alert)

                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

// MARK: - 📏(Performance Measurement) Delegate
extension LiveImageViewController: 📏Delegate {
    func updateMeasure(inferenceTime: Double, executionTime: Double, fps: Int) {
        //print(executionTime, fps)
        //self.inferenceLabel.text = "inference: \(Int(inferenceTime*1000.0)) mm"
        //self.etimeLabel.text = "execution: \(Int(executionTime*1000.0)) mm"
        //self.fpsLabel.text = "fps: \(fps)"
    }
}

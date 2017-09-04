//
//  ViewController.swift
//  SeeYumYum
//
//  Created by Yi Wang on 9/3/17.
//  Copyright © 2017 Vento. All rights reserved.
//

import UIKit
import Vision
import CoreML
import AVFoundation


class ViewController: UIViewController, FrameExtractorDelegate {
    

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var seeLabel: UILabel!
    
    
    var settingImage = false
    var frameExtractor: FrameExtractor!
    
    var currentImage: CIImage? {
        didSet {
            if let image = currentImage{
                self.detectScene(image: image)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        frameExtractor = FrameExtractor()
        frameExtractor.delegate = self
    }
    
    func captured(image: UIImage) {
        self.imageView.image = image
        if let cgImage = image.cgImage, !settingImage {
            settingImage = true
            DispatchQueue.global(qos: .userInteractive).async {[unowned self] in
                self.currentImage = CIImage(cgImage: cgImage)
            }
        }
    }
    
    func addEmoji(id: String) -> String {
        switch id {
        case "pizza":
            return "🍕"
        case "hot dog":
            return "🌭"
        case "chicken wings":
            return "🍗"
        case "french fries":
            return "🍟"
        case "sushi":
            return "🍣"
        case "chocolate cake":
            return "🍫🍰"
        case "donut":
            return "🍩"
        case "spaghetti bolognese":
            return "🍝"
        case "caesar salad":
            return "🥗"
        case "macaroni and cheese":
            return "🧀"
        default:
            return ""
        }
    }
    func detectScene(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: food().model) else {
            fatalError()
        }
        // Create a Vision request with completion handler
        let request = VNCoreMLRequest(model: model) { [unowned self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let _ = results.first else {
                    self.settingImage = false
                    return
            }
            
            DispatchQueue.main.async { [unowned self] in
                if let first = results.first {
                    if Int(first.confidence * 100) > 1 {
                        self.seeLabel.text = "I see \(first.identifier) \(self.addEmoji(id: first.identifier))"
                        self.settingImage = false
                    }
                }
                //        results.forEach({ (result) in
                //          if Int(result.confidence * 100) > 1 {
                //            self.settingImage = false
                //            print("\(Int(result.confidence * 100))% it's \(result.identifier) ")
                //          }
                //        })
                // print("********************************")
                
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }


}


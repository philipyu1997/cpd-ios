//
//  ViewController.swift
//  CDP
//
//  Created by Philip Yu on 4/28/20.
//  Copyright © 2020 Philip Yu. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageLabel: UILabel!
    
    // Properties
    let imgPicker = UIImagePickerController()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        imgPicker.delegate = self
        imgPicker.sourceType = .photoLibrary
        imgPicker.allowsEditing = false
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert UIImage to CIImage.")
            }
            
            detect(image: ciImage)
        }
        
        imgPicker.dismiss(animated: true, completion: nil)
        
    }
    
    func detect(image: CIImage) {
        
        // Create model using PetImageClassifier
        guard let model = try? VNCoreMLModel(for: PetImageClassifier().model) else {
            fatalError("Failed to load CoreML model.")
        }
        
        // Process image using ML model
        let request = VNCoreMLRequest(model: model) { (request, _) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image.")
            }
            
            print(results)
            
            if let animal = results.first?.identifier, let confidence = results.first?.confidence {
                self.navigationItem.title = confidence != 1 ? "Not CDP" : "\(animal)"
            }
            
        }
        
        // Handle user request
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imgPicker, animated: true, completion: nil)
        
    }
    
}

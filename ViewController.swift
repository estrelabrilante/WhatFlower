//
//  ViewController.swift
//  WhatFlower
//
//  Created by user215496 on 11/29/22.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON


class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var flowerLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    let wikipediaURL = "https://en.wikipedia.org/w/api.php"
    let imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
       // imagePicker.sourceType = .camera
        imagePicker.sourceType = .photoLibrary
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[.editedImage] as? UIImage{
            //set imageView background
            imageView.image = userPickedImage
            //convert into CIImage
            guard let convertedciimage = CIImage(image: userPickedImage) else{
                fatalError("Can't convert UIImage into CIImage")
            }
            detect(image: convertedciimage)
            
        }
        imagePicker.dismiss(animated: true)
        
    }
    func detect(image: CIImage ){
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else{
            fatalError("cannot import model")
        }
        let request = VNCoreMLRequest(model: model){(request,error) in
            guard let classification = request.results?.first as? VNClassificationObservation else{
                fatalError("Could not classify")
            }
            self.navigationItem.title = classification.identifier.capitalized
            self.requestInfo(flowerName: classification.identifier)
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do{
            try handler.perform([request])}
        catch{
            print(error)
        }
    }
    //Almofire http request
    func requestInfo(flowerName: String){
        let parameters:[String:String] = [
            "format": "json",
            "action":"query",
            "prop":"extracts",
            "exintro":"",
            "explaintext":"",
            "titles":flowerName,
            "indexpageids":"",
            "redirects":"1"]
        AF.request(wikipediaURL, method: .get,parameters:parameters).responseJSON { response in
            
            debugPrint(response)
            switch response.result{
                
            case .success(let value):
                print("response status",response.result)
                
                    let flowerJSON = JSON(value)
                let pageid = flowerJSON["query"]["pageids"][0].stringValue
                let flowerdescription = flowerJSON["query"]["pages"][pageid]["extract"].stringValue
                self.flowerLabel.text = flowerdescription
                  debugPrint(flowerJSON)
            
            case .failure(let error):
                print("error",error)
            }
            
                
          
            
        }
        
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true)
    }
    
}


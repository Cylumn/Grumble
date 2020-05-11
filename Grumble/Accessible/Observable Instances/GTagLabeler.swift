//
//  GTagLabeler.swift
//  Grumble
//
//  Created by Allen Chang on 5/10/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import Foundation
import UIKit
import Vision
import CoreML

public class GTagLabeler {
    private static var instance: GTagLabeler? = nil
    private var model: VNCoreMLModel?
    
    private init() {
        do {
            self.model = try VNCoreMLModel(for: GTagClassifier().model)
        } catch {
            print("error\(error)")
        }
    }
    
    public static func gtl() -> GTagLabeler {
        if GTagLabeler.instance == nil {
            GTagLabeler.instance = GTagLabeler()
        }
        return GTagLabeler.instance!
    }
    
    public func predict(image: CGImage, onComplete: @escaping ([Int]) -> Void) {
        let request = VNCoreMLRequest(model: self.model!) { request, error in
            guard error == nil else {
                print("error:\(error!)")
                return
            }
            //Perform on main thread
            DispatchQueue.main.async {
                let results: [VNClassificationObservation] = request.results as! [VNClassificationObservation]
                print("\n\n---------[BEGIN RESULTS]-----------")
                for result in results {
                    print(result.identifier.lowercased() + ": " + result.confidence.description)
                }
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: image)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("error:\(error)")
            }
        }
    }
    
    
}

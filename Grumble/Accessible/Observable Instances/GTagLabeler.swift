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

public let minConfidence: Double = 0.5

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
    
    public func predict(image: CGImage, onComplete: @escaping ([GrubTag: Double]) -> Void) {
        let request = VNCoreMLRequest(model: self.model!) { request, error in
            guard error == nil else {
                print("error:\(error!)")
                return
            }

            let results: [VNClassificationObservation] = request.results as! [VNClassificationObservation]
            var returnTags: [GrubTag: Double] = [:]
            for result in results {
                if Double(result.confidence) >= minConfidence {
                    returnTags[result.identifier.lowercased()] = Double(result.confidence)
                }
            }
            
            //Perform on main thread
            DispatchQueue.main.async {
                onComplete(returnTags)
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: image)
        DispatchQueue.global(qos: .utility).async {
            do {
                try handler.perform([request])
            } catch {
                print("error:\(error)")
            }
        }
    }
    
    
}

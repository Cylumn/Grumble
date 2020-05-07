//
//  ImagePicker.swift
//  Grumble
//
//  Created by Allen Chang on 5/6/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import Foundation
import SwiftUI
import AVFoundation

extension UIButton {
    private func image(withColor color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()

        context?.setFillColor(color.cgColor)
        context?.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        self.setBackgroundImage(image(withColor: color), for: state)
    }
}

public class ImageViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    public static var buttonOffset: CGFloat = -100
    public static var buttonSize: CGFloat = 70
    
    private var captureSession: AVCaptureSession
    
    private var frontCamera: AVCaptureDevice?
    private var backCamera: AVCaptureDevice?
    private var currentCamera: AVCaptureDevice?
    
    private var output: AVCapturePhotoOutput?
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    fileprivate init() {
        self.captureSession = AVCaptureSession()
        
        self.frontCamera = nil
        self.backCamera = nil
        self.currentCamera = nil
        
        self.output = nil
        
        self.previewLayer = nil
        
        super.init(nibName: nil, bundle: nil)
        
        AddImageCookie.aic().capture = self.capture
        AddImageCookie.aic().run = self.run
    }
    
    public required init?(coder decoder: NSCoder) {
        self.captureSession = AVCaptureSession()
        
        super.init(coder: decoder)
    }
    
    //Function Methods
    private func capture() {
        self.output?.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
    private func run(_ shouldRun: Bool) {
        if shouldRun && !self.captureSession.isRunning {
            self.captureSession.startRunning()
        } else if !shouldRun && self.captureSession.isRunning {
            self.captureSession.stopRunning()
        }
    }
    
    //Implemented UIViewController Methods
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup Capture Session
        self.captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        //Setup Device
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes:
            [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video,
                                                                 position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        for device in devices {
            switch device.position {
            case AVCaptureDevice.Position.front:
                self.frontCamera = device
            case AVCaptureDevice.Position.back:
                self.backCamera = device
            default:
                break
            }
        }
        
        self.currentCamera = self.backCamera
        
        //Setup Input Output
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: self.currentCamera!)
            self.captureSession.addInput(captureDeviceInput)
            self.output = AVCapturePhotoOutput()
            self.output?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format:
                [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            self.captureSession.addOutput(self.output!)
        } catch {
            print("error:\(error)")
        }
        
        //Setup Preview Layer
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        self.previewLayer!.frame = CGRect(x: 0, y: navBarHeight, width: sWidth(), height: sHeight() - navBarHeight - abs(ImageViewController.buttonOffset * 2))
        self.view.layer.insertSublayer(self.previewLayer!, at: 0)
    }
    
    //Implemented AVCapturePhotoCaptureDelegate Methods
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            let image = UIImage(data: imageData)!
            
            AddImageCookie.aic().aspectRatio = image.size.height / image.size.width
            AddImageCookie.aic().image = Image(uiImage: image)
            
            //UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData)!, nil, nil, nil)
        }
    }
}

public struct ImagePicker: UIViewControllerRepresentable {

    public init() {
    }
    
    //Implemented UIViewControllerRepresentable Methods
    public func updateUIViewController(_ uiViewController: ImageViewController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> ImageViewController {
        return ImageViewController()
    }
    
}

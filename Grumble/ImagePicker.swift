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

public class ImageViewController: UIViewController {
    private var captureSession: AVCaptureSession = AVCaptureSession()
    
    private var frontCamera: AVCaptureDevice? = nil
    private var backCamera: AVCaptureDevice? = nil
    private var currentCamera: AVCaptureDevice? = nil
    
    private var output: AVCapturePhotoOutput? = nil
    
    private var previewLayer: AVCaptureVideoPreviewLayer? = nil
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup Capture Session
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
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
        
        currentCamera = backCamera
        
        //Setup Input Output
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            output?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format:
                [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
        } catch {
            print("error:\(error)")
        }
        
        //Setup Preview Layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        previewLayer!.frame = self.view.frame
        self.view.layer.insertSublayer(previewLayer!, at: 0)
        
        //Setup Running Capture Session
        captureSession.startRunning()
    }
}

public class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    private var isPresented: Binding<Bool>
    private var image: Binding<Image?>
    
    public init(isPresented: Binding<Bool>, image: Binding<Image?>) {
        self.isPresented = isPresented
        self.image = image
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.image.wrappedValue = Image(uiImage: uiImage)
        self.isPresented.wrappedValue = false
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.isPresented.wrappedValue = false
    }
    
}

public struct ImagePicker: UIViewControllerRepresentable {
    private var isPresented: Binding<Bool>
    private var image: Binding<Image?>
    
    public init(isPresented: Binding<Bool>, image: Binding<Image?>) {
        self.isPresented = isPresented
        self.image = image
    }
    
    public func updateUIViewController(_ uiViewController: ImageViewController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    public func makeCoordinator() -> ImagePickerCoordinator {
        return ImagePickerCoordinator(isPresented: isPresented, image: image)
    }
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> ImageViewController {
        let picker = ImageViewController()
        return picker
    }
    
}

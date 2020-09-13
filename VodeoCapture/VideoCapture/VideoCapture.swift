//
//  VideoCaptureSession.swift
//  VideoCapture
//
//  Created by niekang on 2020/9/12.
//  Copyright © 2020 niekang. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class VideoCapture: NSObject {
        
    var session = AVCaptureSession()
    
    var cameraPosition: AVCaptureDevice.Position = .back
            
    private var previewLayer = AVCaptureVideoPreviewLayer()
    private var videoInput: AVCaptureDeviceInput!
    private var audioInput: AVCaptureDeviceInput!
    private var videoOutput = AVCaptureVideoDataOutput()
    private var audioOutput = AVCaptureAudioDataOutput()
    
    private var filter: CIFilter!
    private lazy var context: CIContext = CIContext()

    private override init() {
        super.init()
    }

    init(_ preView: UIView) {
        super.init()
        previewLayer.frame = CGRect(x: 0, y: 0, width: preView.frame.height, height: preView.frame.width)
        previewLayer.position = CGPoint(x: preView.frame.size.width / 2.0, y: preView.frame.size.height / 2.0);
        previewLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(Double.pi/2)));
        preView.layer.insertSublayer(previewLayer, at: 0)
        
        setUp()
    }
    
    // MARK: Public Method
    func switchCamera()  {
        session.stopRunning()
        let position: AVCaptureDevice.Position = videoInput.device.position == .back ? .front : .back
        guard let device = getCamera(position),
            let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        session.beginConfiguration()
        session.removeInput(videoInput)
        session.addInput(input)
        session.commitConfiguration()
        videoInput = input
        session.startRunning()
    }
    
    func setFilter(name: String) {
        let filter = CIFilter(name: name)
        self.filter = filter
    }
}

extension VideoCapture {
    
    private func setUp() {
        // 获取输入
        guard let videoDevice = getCamera(self.cameraPosition),
            let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
            session.canAddInput(videoInput) else {
            return
        }
        self.videoInput = videoInput
        session.addInput(videoInput)

        guard let audioDevice = AVCaptureDevice.default(for: .audio),
            let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
            session.canAddInput(audioInput) else{
            return
        }
        self.audioInput = audioInput
        session.addInput(audioInput)

        // 设置输出
        guard session.canAddOutput(videoOutput),
            session.canAddOutput(audioOutput) else{
            return
        }
        session.addOutput(videoOutput)
        session.addOutput(audioOutput)

        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange];
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.init(label: "com.nk.capture.video"))

        audioOutput.setSampleBufferDelegate(self, queue: DispatchQueue.init(label: "com.nk.capture.audio"))
        
//        guard session.canSetSessionPreset(.medium) else{
//            return
//        }
//        session.sessionPreset = .medium
        session.startRunning()

    }
    
    private func addNotification() {
        
    }
    
    private func getCamera(_ position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
}

extension VideoCapture: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if output is AVCaptureVideoDataOutput {
            guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                return
            }
            
//            CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
//            let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
//
//            let width = CVPixelBufferGetWidthOfPlane(imageBuffer, 0)
//            let height = CVPixelBufferGetHeightOfPlane(imageBuffer, 0)
//            let pointer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)
//            let grayColorSpace = CGColorSpaceCreateDeviceGray()
//            let context = CGContext(data: pointer, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: grayColorSpace, bitmapInfo: 0)
//            let cgImage = context?.makeImage()
//            CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
            
          
            var outputImage = CIImage(cvImageBuffer: imageBuffer)
            if filter != nil {
                filter.setValue(outputImage, forKey: kCIInputImageKey)
                outputImage = filter.outputImage!
            }
            let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
            DispatchQueue.main.async {
                self.previewLayer.contents = cgImage
            }
        }else {
            
        }
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }
}

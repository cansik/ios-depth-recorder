//
//  ViewController.swift
//  DepthRecorder
//
//  Created by Florian on 08.08.18.
//  Copyright © 2018 bildspur. All rights reserved.
//

import UIKit
import Lumina
import AVKit

class ViewController: UIViewController {
    
    var depthView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let camera = LuminaViewController()
        camera.delegate = self
        
        camera.position = .back
        camera.resolution = .vga640x480
        camera.setCancelButton(visible: false)
        camera.captureDepthData = true
        camera.streamDepthData = true
        camera.captureLivePhotos = false
        
        present(camera, animated: true, completion:nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController : LuminaDelegate {
    func streamed(videoFrame: UIImage, with predictions: [LuminaRecognitionResult]?, from controller: LuminaViewController) {
        
    }
    
    func captured(stillImage: UIImage, livePhotoAt: URL?, depthData: Any?, from controller: LuminaViewController) {
        // save color image
        CustomPhotoAlbum.shared.save(image: stillImage)
        
        // save depth image if possible
        print("trying to save depth image")
        if #available(iOS 11.0, *) {
            if var data = depthData as? AVDepthData {
                // be sure its DisparityFloat32
                if data.depthDataType != kCVPixelFormatType_DisparityFloat32 {
                    data = data.converting(toDepthDataType: kCVPixelFormatType_DisparityFloat32)
                }
                
        
                guard let depthImage = data.depthDataMap.normalizedImage(with: controller.position) else {
                    print("could not convert depth data")
                    return
                }
              
                print("depthDataType: \(data.depthDataType)")
                print("depthDataAccuracy: \(data.depthDataAccuracy.rawValue)")
                print("depthDataQuality: \(data.depthDataQuality.rawValue)")
                print("availableDepthDataTypes: \(data.availableDepthDataTypes)")
                

                print("saving depth image")
                CustomPhotoAlbum.shared.save(image: depthImage)
                //UIImageWriteToSavedPhotosAlbum(depthImage, nil, nil, nil)
            }
            else
            {
                print("data is not depth data")
            }
        }
        else
        {
            print("not on ios 11.0")
        }
    }
    
    func streamed(depthData: Any, from controller: LuminaViewController) {
        if #available(iOS 11.0, *) {
            if var data = depthData as? AVDepthData {
                
                // be sure its DisparityFloat32
                if data.depthDataType != kCVPixelFormatType_DisparityFloat32 {
                    data = data.converting(toDepthDataType: kCVPixelFormatType_DisparityFloat32)
                }

                guard let image = data.depthDataMap.normalizedImage(with: controller.position) else {
                    print("could not convert depth data")
                    return
                }
                
                if let imageView = self.depthView {
                    imageView.removeFromSuperview()
                }
                let newView = UIImageView(frame: CGRect(x: controller.view.frame.minX, y: controller.view.frame.maxY - 300, width: 200, height: 200))
                newView.image = image
                newView.contentMode = .scaleAspectFit
                newView.backgroundColor = UIColor.clear
                controller.view.addSubview(newView)
                controller.view.bringSubview(toFront: newView)
            }
        }
    }
}

extension CVPixelBuffer {
    func normalizedImage(with position: CameraPosition) -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: self)
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(self), height: CVPixelBufferGetHeight(self))) {
            return UIImage(cgImage: cgImage , scale: 1.0, orientation: getImageOrientation(with: position))
        } else {
            return nil
        }
    }
    
    private func getImageOrientation(with position: CameraPosition) -> UIImageOrientation {
        switch UIApplication.shared.statusBarOrientation {
        case .landscapeLeft:
            return position == .back ? .down : .upMirrored
        case .landscapeRight:
            return position == .back ? .up : .downMirrored
        case .portraitUpsideDown:
            return position == .back ? .left : .rightMirrored
        case .portrait:
            return position == .back ? .right : .leftMirrored
        case .unknown:
            return position == .back ? .right : .leftMirrored
        }
    }
}

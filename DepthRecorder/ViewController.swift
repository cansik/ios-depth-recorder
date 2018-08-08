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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let camera = LuminaViewController()
        camera.delegate = self
        
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
    func captured(stillImage: UIImage, livePhotoAt: URL?, depthData: Any?, from controller: LuminaViewController) {
        controller.dismiss(animated: true) {
            // still images always come back through this function, but live photos and depth data are returned here as well for a given still image
            // depth data must be manually cast to AVDepthData, as AVDepthData is only available in iOS 11.0 or higher.
            
            //UIImageWriteToSavedPhotosAlbum(stillImage, nil, nil, nil)
            
            // save depth image if possible
            print("trying to save depth image")
            if #available(iOS 11.0, *) {
                if let data = depthData as? AVDepthData {
                    guard let depthImage = data.depthDataMap.normalizedImage(with: controller.position) else {
                        print("could not convert depth data")
                        return
                    }
                    
                    print("saving depth image")
                    CustomPhotoAlbum.shared.save(image: depthImage)
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
            
            // save color image
            CustomPhotoAlbum.shared.save(image: stillImage)
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

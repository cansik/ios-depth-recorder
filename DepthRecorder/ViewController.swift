//
//  ViewController.swift
//  DepthRecorder
//
//  Created by Florian on 08.08.18.
//  Copyright © 2018 bildspur. All rights reserved.
//

import UIKit
import Lumina

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
            CustomPhotoAlbum.shared.save(image: stillImage)
        }
    }
}

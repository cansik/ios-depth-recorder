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
        present(camera, animated: true, completion:nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


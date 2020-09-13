//
//  ViewController.swift
//  VodeoCapture
//
//  Created by niekang on 2020/9/12.
//  Copyright © 2020 niekang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(VideoCaptureView(frame: view.bounds))
    }


}


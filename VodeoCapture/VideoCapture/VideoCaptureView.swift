//
//  VideoCaptureViewController.swift
//  VideoCapture
//
//  Created by niekang on 2020/9/12.
//  Copyright © 2020 niekang. All rights reserved.
//

import UIKit
import AVFoundation


class VideoCaptureView: UIView {
    
    var capture: VideoCapture?
    
    private var tools = ["camera", "filter"]
    
    private var filterNames = ["CIColorInvert","CIPhotoEffectMono","CIPhotoEffectInstant","CIPhotoEffectTransfer", "CISepiaTone"]

    private var bottomView = UIView()
    private var toolView = UIView()
    
    private var filterView = UIScrollView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        capture = VideoCapture(self)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func toolViewTap(ges: UITapGestureRecognizer) {
        switch ges.view?.tag {
        case 0:
            capture?.switchCamera()
        case 1:
            showBottom()
        default:
            break
        }
    }
    
    @objc private func changeFilterBtnClick(btn: UIButton)  {
        self.capture?.setFilter(name: filterNames[btn.tag])
    }
    
    private func showBottom() {
        if bottomView.frame.origin.y == frame.height {
            UIView.animate(withDuration: 0.3) {
                self.bottomView.frame.origin.y = self.frame.height - self.bottomView.frame.height
            }
        }else if bottomView.frame.origin.y == frame.height - bottomView.frame.height {
            UIView.animate(withDuration: 0.3) {
                self.bottomView.frame.origin.y = self.frame.height
            }
        }
    }
    
}

extension VideoCaptureView {
    
    private func setUp() {
        
        let tooView = UIView(frame: CGRect(x: frame.width - 60, y: 30, width: 60, height: 60 * CGFloat(tools.count)))
        addSubview(tooView)
        
        tools.enumerated().forEach { (el) in
            let imageView = UIImageView(frame: CGRect(x: 10, y: 60 * el.offset + 10, width: 40, height: 40))
            imageView.image = UIImage.bundleImage(name: el.element)
            imageView.tag = el.offset
            imageView.isUserInteractionEnabled = true
            addSubview(imageView)
            
            let ges = UITapGestureRecognizer(target: self, action: #selector(VideoCaptureView.toolViewTap(ges:)))
            imageView.addGestureRecognizer(ges)
            
            tooView.addSubview(imageView)
        }
        
        bottomView.frame = CGRect(x: 0, y: frame.height, width: frame.width, height: 50)
        addSubview(bottomView)
        
        filterView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 50)
        filterView.showsHorizontalScrollIndicator = false
        filterView.backgroundColor = UIColor.white
        bottomView.addSubview(filterView)
        
        let width = frame.width/4
        let height: CGFloat = 50
        var index = 0
        filterNames.forEach({ (filter) in
            let btn = UIButton(type: .custom)
            btn.frame = CGRect(x: CGFloat(index) * width, y: 0, width: width, height: height)
            btn.setTitle(filter, for: .normal)
            btn.setTitleColor(UIColor.blue, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 10)
            btn.titleLabel?.numberOfLines = 0
            btn.tag = index
            btn.addTarget(self, action: #selector(VideoCaptureView.changeFilterBtnClick(btn:)), for: .touchUpInside)
            filterView.addSubview(btn)
            index += 1
        })
        filterView.contentSize = CGSize(width: width * CGFloat(filterNames.count), height: height)
        
    }
}


extension UIImage {
    class func bundleImage(name: String) -> UIImage?{
        guard let path = Bundle.main.path(forResource: name, ofType: ".png") else {
            return nil
        }
        return UIImage.init(contentsOfFile: path)
    }
}

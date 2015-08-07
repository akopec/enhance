//
//  EnhanceViewController.swift
//  enhance
//
//  Created by Jeff Hodsdon on 8/7/15.
//  Copyright (c) 2015 Jeff Hodsdon. All rights reserved.
//

import UIKit

class EnhanceViewController: UIViewController, UIScrollViewDelegate {
    
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    var image: UIImage!
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = kEnhanceDarkTealColor
    
        imageView = UIImageView(image: image)

        scrollView = UIScrollView(frame: CGRectMake(0, 0, kScreenWidth, kScreenHeight))
        scrollView.contentSize = imageView.frame.size
        scrollView.minimumZoomScale = kScreenWidth/imageView.frame.width
        scrollView.maximumZoomScale = 50.0
        scrollView.delegate = self
        scrollView.setZoomScale(kScreenWidth/imageView.frame.width, animated: false)
        view.addSubview(scrollView)
        
        scrollView.addSubview(imageView)
        
    }
    
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView!, atScale scale: CGFloat) {
        
        
        println("HERE")
    }
}

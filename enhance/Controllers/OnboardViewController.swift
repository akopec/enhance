//
//  OnboardViewController.swift
//  enhance
//
//  Created by Jeff Hodsdon on 8/5/15.
//  Copyright (c) 2015 Jeff Hodsdon. All rights reserved.
//

import UIKit
import Photos

class OnboardViewController: UIViewController, UIScrollViewDelegate {
    
    var scrollView: UIScrollView!
    
    var landingView: UIView!
    var permissionsView: UIView!
    
    override func loadView() {
        super.loadView()
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        scrollView.contentSize = CGSize(width: kScreenWidth * 2, height: kScreenHeight)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.bounces = false
        view.addSubview(scrollView)
        
        landingView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        landingView.backgroundColor = kEnhanceTealColor
        
        let landingTitle = UILabel(frame: CGRect(x: 25.5, y: 133.0, width: 270.0, height: 115.0))
        landingTitle.textColor = UIColor.white
        landingTitle.font = UIFont(name: "GTWalsheimPro-BoldOblique", size: 56.5)
        landingTitle.numberOfLines = 0
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0
        let attrString = NSMutableAttributedString(string: "Zoom,\nEnhance!")
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))

        landingTitle.attributedText = attrString
        landingView.addSubview(landingTitle)
        
        let landingDesc = UILabel(frame: CGRect(x: 25.5, y: 275.0, width: 270.0, height: 110.0))
        let descParagraphStyle = NSMutableParagraphStyle()
        descParagraphStyle.lineSpacing = 13
        let descAttrString = NSMutableAttributedString(string: "Zoom in on stuff.\nMake a GIF of it.\nBurn your friends.")
        descAttrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: descParagraphStyle, range: NSMakeRange(0, descAttrString.length))
        landingDesc.attributedText = descAttrString
        landingDesc.font = UIFont(name: "GTWalsheimPro-BoldOblique", size: 23.5)
        landingDesc.textColor = UIColor.white
        landingDesc.numberOfLines = 0
        landingView.addSubview(landingDesc)
        
        
        let swipe = UILabel(frame: CGRect(x: 0, y: kScreenHeight - 60, width: kScreenWidth, height: 30))
        swipe.text = "Swipe to go deeper"
        swipe.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        swipe.font = UIFont(name: "GTWalsheimPro", size: 20.0)
        swipe.textAlignment = .center
        landingView.addSubview(swipe)
        
        
        
        scrollView.addSubview(landingView)

        permissionsView = UIView(frame: CGRect(x: kScreenWidth, y: 0, width: kScreenWidth, height: kScreenHeight))
        permissionsView.backgroundColor = kEnhanceDarkTealColor
        
        let film = UIImageView(image: UIImage(named: "Film"))
        film.frame = CGRect(x: (kScreenWidth - film.frame.width) / 2.0, y: 145.0, width: film.frame.width, height: film.frame.height)
        permissionsView.addSubview(film)
        
        let permissionsText = UILabel(frame: CGRect(x: 32.0, y: 570.0/2.0, width: kScreenWidth - 64.0, height: 130.0))
        let permAttrString = NSMutableAttributedString(string: "Zoom, Enhance!")
        permAttrString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "GTWalsheimPro-BoldOblique", size: 22.0)!, range: NSMakeRange(0, permAttrString.length))
        permAttrString.append(NSAttributedString(string: " needs access to your camera roll otherwise it’s literally completely useless.", attributes: [NSAttributedString.Key.font: UIFont(name: "GTWalsheimPro", size: 22.0)!]))

        let permParagraphStyle = NSMutableParagraphStyle()
        permParagraphStyle.lineSpacing = 5
        permAttrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:permParagraphStyle, range:NSMakeRange(0, permAttrString.length))

        
        permissionsText.attributedText = permAttrString
        permissionsText.textAlignment = .center
        permissionsText.textColor = kEnhanceTealColor
        permissionsText.numberOfLines = 0
        permissionsView.addSubview(permissionsText)
        
        let tapText = UILabel(frame: CGRect(x: 0, y: kScreenHeight - 145.0, width: kScreenWidth, height: 39.0))
        tapText.text = "Tap “OK” on the popup screen, cool?"
        tapText.textColor = UIColor(red: 65.0/255.0, green: 169.0/255.0, blue: 148.0/255.0, alpha: 0.7)
        tapText.textAlignment = .center
        tapText.font = UIFont(name: "GTWalsheimPro", size: 17.0)
        permissionsView.addSubview(tapText)
        
        let permButton = UIButton(frame: CGRect(x: 55.0, y: tapText.frame.origin.y + 40.0 + 5.0, width: kScreenWidth - 110.0, height: 42.0))
        permButton.backgroundColor = kEnhanceTealColor
        permButton.setTitle("Will do", for: .normal)
        permButton.setTitleColor(UIColor.white, for: .normal)
        permButton.titleLabel!.font = UIFont(name: "GTWalsheimPro", size: 18.0)
        permButton.layer.cornerRadius = 4.0
        permButton.layer.masksToBounds = true
        permButton.addTarget(self, action: #selector(askPermissions), for: .touchUpInside)
        permissionsView.addSubview(permButton)
        
        scrollView.addSubview(permissionsView)
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(getter: next)))
    }
    
    @objc func askPermissions() {
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            DispatchQueue.main.async {
                UIView.animate(withDuration: 1.0, animations: { () -> Void in
                    self.view.alpha = 0.0
                    self.view.transform = CGAffineTransform(scaleX: 0.33, y: 0.33)

                    }) { (success) -> Void in
                        let nav = UINavigationController(rootViewController: PickerViewController())
                        self.view.window!.rootViewController = nav
                        self.view.removeFromSuperview()

                        nav.viewControllers[0].view.alpha = 0.0
                        nav.viewControllers[0].view.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)

                        UIView.animate(withDuration: 0.3) { () -> Void in
                            nav.viewControllers[0].view.alpha = 1.0
                            nav.viewControllers[0].view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        }
                }
            }
        }
    }
    
    func next() {
        if scrollView.contentOffset.x == 0 {
            scrollView.setContentOffset(CGPoint(x: kScreenWidth, y: 0), animated: true)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

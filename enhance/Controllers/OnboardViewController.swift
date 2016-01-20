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
        
        scrollView = UIScrollView(frame: CGRectMake(0, 0, kScreenWidth, kScreenHeight))
        scrollView.contentSize = CGSizeMake(kScreenWidth * 2, kScreenHeight)
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.bounces = false
        view.addSubview(scrollView)
        
        landingView = UIView(frame: CGRectMake(0, 0, kScreenWidth, kScreenHeight))
        landingView.backgroundColor = kEnhanceTealColor
        
        let landingTitle = UILabel(frame: CGRectMake(25.5, 133.0, 270.0, 115.0))
        landingTitle.textColor = UIColor.whiteColor()
        landingTitle.font = UIFont(name: "GTWalsheimPro-BoldOblique", size: 56.5)
        landingTitle.numberOfLines = 0
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0
        let attrString = NSMutableAttributedString(string: "Zoom,\nEnhance!")
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))

        landingTitle.attributedText = attrString
        landingView.addSubview(landingTitle)
        
        let landingDesc = UILabel(frame: CGRectMake(25.5, 275.0, 270.0, 110.0))
        let descParagraphStyle = NSMutableParagraphStyle()
        descParagraphStyle.lineSpacing = 13
        let descAttrString = NSMutableAttributedString(string: "Zoom in on stuff.\nMake a GIF of it.\nBurn your friends.")
        descAttrString.addAttribute(NSParagraphStyleAttributeName, value:descParagraphStyle, range:NSMakeRange(0, descAttrString.length))
        landingDesc.attributedText = descAttrString
        landingDesc.font = UIFont(name: "GTWalsheimPro-BoldOblique", size: 23.5)
        landingDesc.textColor = UIColor.whiteColor()
        landingDesc.numberOfLines = 0
        landingView.addSubview(landingDesc)
        
        
        let swipe = UILabel(frame: CGRectMake(0, kScreenHeight - 60, kScreenWidth, 30))
        swipe.text = "Swipe to go deeper"
        swipe.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        swipe.font = UIFont(name: "GTWalsheimPro", size: 20.0)
        swipe.textAlignment = .Center
        landingView.addSubview(swipe)
        
        
        
        scrollView.addSubview(landingView)

        permissionsView = UIView(frame: CGRectMake(kScreenWidth, 0, kScreenWidth, kScreenHeight))
        permissionsView.backgroundColor = kEnhanceDarkTealColor
        
        let film = UIImageView(image: UIImage(named: "Film"))
        film.frame = CGRectMake((kScreenWidth - film.frame.width) / 2.0, 145.0, film.frame.width, film.frame.height)
        permissionsView.addSubview(film)
        
        let permissionsText = UILabel(frame: CGRectMake(32.0, 570.0/2.0, kScreenWidth - 64.0, 130.0))
        let permAttrString = NSMutableAttributedString(string: "Zoom, Enhance!")
        permAttrString.addAttribute(NSFontAttributeName, value: UIFont(name: "GTWalsheimPro-BoldOblique", size: 22.0)!, range: NSMakeRange(0, permAttrString.length))
        permAttrString.appendAttributedString(NSAttributedString(string: " needs access to your camera roll otherwise it’s literally completely useless.", attributes: [NSFontAttributeName: UIFont(name: "GTWalsheimPro", size: 22.0)!]))

        let permParagraphStyle = NSMutableParagraphStyle()
        permParagraphStyle.lineSpacing = 5
        permAttrString.addAttribute(NSParagraphStyleAttributeName, value:permParagraphStyle, range:NSMakeRange(0, permAttrString.length))

        
        permissionsText.attributedText = permAttrString
        permissionsText.textAlignment = .Center
        permissionsText.textColor = kEnhanceTealColor
        permissionsText.numberOfLines = 0
        permissionsView.addSubview(permissionsText)
        
        let tapText = UILabel(frame: CGRectMake(0, kScreenHeight - 145.0, kScreenWidth, 39.0))
        tapText.text = "Tap “OK” on the popup screen, cool?"
        tapText.textColor = UIColor(red: 65.0/255.0, green: 169.0/255.0, blue: 148.0/255.0, alpha: 0.7)
        tapText.textAlignment = .Center
        tapText.font = UIFont(name: "GTWalsheimPro", size: 17.0)
        permissionsView.addSubview(tapText)
        
        let permButton = UIButton(frame: CGRectMake(55.0, tapText.frame.origin.y + 40.0 + 5.0, kScreenWidth - 110.0, 42.0))
        permButton.backgroundColor = kEnhanceTealColor
        permButton.setTitle("Will do", forState: .Normal)
        permButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        permButton.titleLabel!.font = UIFont(name: "GTWalsheimPro", size: 18.0)
        permButton.layer.cornerRadius = 4.0
        permButton.layer.masksToBounds = true
        permButton.addTarget(self, action: "askPermissions", forControlEvents: .TouchUpInside)
        permissionsView.addSubview(permButton)
        
        scrollView.addSubview(permissionsView)
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "next"))
    }
    
    func askPermissions() {
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                UIView.animateWithDuration(1.0, animations: { () -> Void in
                    self.view.alpha = 0.0
                    self.view.transform = CGAffineTransformMakeScale(0.33, 0.33)
                    
                    }) { (success) -> Void in
                        let nav = UINavigationController(rootViewController: PickerViewController())
                        self.view.window!.rootViewController = nav
                        self.view.removeFromSuperview()
                        
                        nav.viewControllers[0].view.alpha = 0.0
                        nav.viewControllers[0].view.transform = CGAffineTransformMakeScale(0.4, 0.4)

                        UIView.animateWithDuration(0.3) { () -> Void in
                            nav.viewControllers[0].view.alpha = 1.0
                            nav.viewControllers[0].view.transform = CGAffineTransformMakeScale(1.0, 1.0)

                        }

                }

            })

        }
    }
    
    func next() {
        if scrollView.contentOffset.x == 0 {
            scrollView.setContentOffset(CGPointMake(kScreenWidth, 0), animated: true)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
 
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}

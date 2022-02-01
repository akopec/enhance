//
//  EnhanceViewController.swift
//  enhance
//
//  Created by Jeff Hodsdon on 8/7/15.
//  Copyright (c) 2015 Jeff Hodsdon. All rights reserved.
//

import UIKit

class EnhanceViewController: UIViewController, UIScrollViewDelegate {
    
    var nav: UINavigationController!

    var scrollView: UIScrollView!
    var imageView: UIView!
    var image: UIImage!
    
    var nextButton: UIButton!
    var backButton: UIButton!
    
    var tutorialView: UIView!
    var previewView: UIImageView?
    var shareView: UIView!
    
    var currentResult: EnhanceResult?
    
    override func loadView() {
        super.loadView()
  
        view.backgroundColor = kEnhanceDarkTealColor

        imageView = UIImageView(image: image)
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        scrollView.bounds = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
        scrollView.contentSize = imageView.frame.size
        scrollView.minimumZoomScale = kScreenWidth/imageView.frame.width
        scrollView.maximumZoomScale = 50.0
        scrollView.delegate = self
        scrollView.layer.masksToBounds = false
        scrollView.setZoomScale((kScreenWidth - 50)/imageView.frame.width, animated: false)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)

        let size = scrollView.contentSize
        let imageFrame = scrollView.frame
        var scrollFrame = scrollView.frame
        
        if imageFrame.width > size.width {
            scrollFrame.origin.x = (imageFrame.width - size.width) / 2.0
        } else {
            scrollFrame.origin.x = 0
        }
        
        if imageFrame.height > size.height {
            scrollFrame.origin.y = (imageFrame.height - size.height) / 2.0
        } else {
            scrollFrame.origin.y = 0

        }
        
        scrollFrame.size.width = size.width
        scrollFrame.size.height = size.height

        let topBG = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: scrollFrame.origin.y))
        topBG.backgroundColor = UIColor(red: 39.0/255.0, green: 50.0/255.0, blue: 48.0/255.0, alpha: 0.7)
        self.view.addSubview(topBG)
        
        let bottomBG = UIView(frame: CGRect(x: 0, y: scrollFrame.origin.y + scrollFrame.size.height, width: size.width, height: scrollFrame.origin.y))
        bottomBG.backgroundColor = UIColor(red: 39.0/255.0, green: 50.0/255.0, blue: 48.0/255.0, alpha: 0.7)
        self.view.addSubview(bottomBG)
        
        scrollView.frame = scrollFrame
        scrollView.addSubview(imageView)
        
        backButton = UIButton(frame: CGRect(x: (kScreenWidth - 55) / 2, y: kScreenHeight - 55 - 15, width: 55, height: 55))
        backButton.setImage(UIImage(named: "WhiteClose")!, for: .normal)
        backButton.backgroundColor = UIColor.white
        backButton.layer.cornerRadius = backButton.frame.width / 2
        backButton.layer.masksToBounds = true
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        view.addSubview(backButton)
        
        nextButton = UIButton(frame: backButton.frame)
        nextButton.setImage(UIImage(named: "WhiteRightArrow")!, for: .normal)
        nextButton.addTarget(self, action: #selector(getter: next), for: .touchUpInside)
        nextButton.backgroundColor = UIColor.white
        nextButton.layer.cornerRadius = nextButton.frame.width / 2
        nextButton.layer.masksToBounds = true
        nextButton.isHidden = true
        nextButton.alpha = 0.0
        view.addSubview(nextButton)
        
        tutorialView = UIView(frame: self.view.frame)
        tutorialView.backgroundColor = UIColor(red: 39.0/255.0, green: 50.0/255.0, blue: 48.0/255.0, alpha: 0.96)
        let pinch = UIImageView(image: UIImage(named: "PinchToZoom"))
        Utils.changeFrameY(view: pinch, value: (kScreenHeight - 250) / 2)
        Utils.changeFrameX(view: pinch, value: (kScreenWidth - pinch.frame.width) / 2)
        tutorialView.addSubview(pinch)
        tutorialView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(okTutorial)))
        
        let width = kScreenWidth - 40
        let tutText = UILabel(frame: CGRect(x: 20, y: pinch.frame.origin.y + 20 + pinch.frame.height, width: width, height: 50))
        tutText.text = "Pinch and position this photo to enhance it."
        tutText.font = UIFont(name: "GTWalsheimPro", size: 22)
        tutText.adjustsFontSizeToFitWidth = true
        tutText.numberOfLines = 0
        tutText.textAlignment = .center
        tutText.textColor = kEnhanceTealColor
        tutorialView.addSubview(tutText)

        shareView = UIView(frame: self.view.frame)
        shareView.backgroundColor = UIColor(red: 36.0/255.0, green: 43.0/255.0, blue: 41.0/255.0, alpha: 0.96)
        shareView.isHidden = true

        let successCheck = UIView(frame: CGRect(x: 0, y: 0, width: 84, height: 84))
        successCheck.backgroundColor = kEnhanceTealColor
        successCheck.layer.cornerRadius = 43
        successCheck.clipsToBounds = true
        shareView.addSubview(successCheck)
        
        let successImg = UIImageView(image: UIImage(named: "SuccessCheck"))
        successImg.tag = 1
        shareView.addSubview(successImg)
        
        Utils.centerView(view: successImg)
        Utils.centerView(view: successCheck)
        Utils.changeFrameY(view: successCheck, value: successCheck.frame.origin.y - 82)
        Utils.changeFrameY(view: successImg, value: successImg.frame.origin.y - 82)
        
        let successText = UILabel(frame: CGRect(x: 30, y: successCheck.frame.origin.y + 84 + 20, width: kScreenWidth - 60, height: 30))
        successText.textAlignment = .center
        successText.text = "Saved!"
        successText.textColor = kEnhanceTealColor
        successText.numberOfLines = 0
        successText.font = UIFont(name: "GTWalsheimPro", size: 25)
        shareView.addSubview(successText)
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.alignment = .center
        let desc = NSMutableAttributedString(string: "GIF", attributes: [NSAttributedString.Key.font: UIFont(name: "GTWalsheimPro-BoldOblique", size: 17)!, NSAttributedString.Key.foregroundColor: kEnhanceTealColor])
        desc.append(NSAttributedString(string: " copied to clipboard.\n", attributes: [NSAttributedString.Key.font: UIFont(name: "GTWalsheimPro", size: 17)!, NSAttributedString.Key.foregroundColor: kEnhanceOpacTealColor]))
        desc.append(NSAttributedString(string: "Video", attributes: [NSAttributedString.Key.font: UIFont(name: "GTWalsheimPro-BoldOblique", size: 17)!, NSAttributedString.Key.foregroundColor: kEnhanceTealColor]))
        desc.append(NSAttributedString(string: " saved to camera roll.", attributes: [NSAttributedString.Key.font: UIFont(name: "GTWalsheimPro", size: 17)!, NSAttributedString.Key.foregroundColor: kEnhanceOpacTealColor]))
        
        desc.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, desc.length))
        
        let successDesc = UILabel(frame: CGRect(x: 30, y: successText.frame.origin.y + 30 + 20, width: kScreenWidth - 60, height: 50))
        successDesc.textAlignment = .center
        successDesc.attributedText = desc
        successDesc.numberOfLines = 0
        shareView.addSubview(successDesc)

        
        
        
        let newButton = UIButton(frame: CGRect(x: 0, y: 0, width: 55, height: 55))
        newButton.layer.cornerRadius = 27.5
        newButton.clipsToBounds = true
        newButton.backgroundColor = UIColor.clear
        newButton.layer.borderColor = kEnhanceTealColor.cgColor
        newButton.layer.borderWidth = 1.0
        newButton.setImage(UIImage(named: "NewPlus"), for: .normal)
        shareView.addSubview(newButton)
        
        Utils.changeFrameX(view: newButton, value: ((kScreenWidth - 180) / 2) + (180 - 55))
        Utils.changeFrameY(view: newButton, value: kScreenHeight - 104 - 55)
        
        let newText = UILabel(frame: CGRect(x: 0, y: 0, width: 55, height: 18))
        newText.font = UIFont(name: "GTWalsheimPro", size: 15)
        newText.textColor = kEnhanceTealColor
        newText.textAlignment = .center
        newText.text = "New"
        shareView.addSubview(newText)
        
        Utils.changeFrameX(view: newText, value: ((kScreenWidth - 180) / 2) + (180 - 55))
        Utils.changeFrameY(view: newText, value: newButton.frame.origin.y + 55 + 9)
        
        newButton.addTarget(self, action: #selector(close), for: .touchUpInside)

        let igButton = UIButton(frame: CGRect(x: 0, y: 0, width: 55, height: 55))
        igButton.layer.cornerRadius = 27.5
        igButton.clipsToBounds = true
        igButton.backgroundColor = UIColor.clear
        igButton.layer.borderColor = kEnhanceTealColor.cgColor
        igButton.layer.borderWidth = 1.0
        igButton.setImage(UIImage(named: "Instagram"), for: .normal)
        shareView.addSubview(igButton)
        
        Utils.changeFrameX(view: igButton, value: (kScreenWidth - 180) / 2)
        Utils.changeFrameY(view: igButton, value: kScreenHeight - 104 - 55)
        
        let igText = UILabel(frame: CGRect(x: 0, y: 0, width: 69, height: 18))
        igText.font = UIFont(name: "GTWalsheimPro", size: 15)
        igText.textColor = kEnhanceTealColor
        igText.textAlignment = .center
        igText.text = "Instagram"
        shareView.addSubview(igText)
        
        Utils.changeFrameX(view: igText, value: ((kScreenWidth - 180) / 2) - 7)
        Utils.changeFrameY(view: igText, value: newButton.frame.origin.y + 55 + 9)
        
        igButton.addTarget(self, action: #selector(instagram), for: .touchUpInside)

        self.view.addSubview(shareView)
        
        if UserDefaults.standard.integer(forKey: "tutorial") < 3 {
            self.view.addSubview(tutorialView)
        }
    }
    
    @objc func instagram() {
        
        if let url = self.igURL {
            UIApplication.shared.openURL(url)
        }
    }

    @objc func okTutorial() {
        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "tutorial")+1, forKey: "tutorial")
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.tutorialView.alpha = 0.0
            }) { (_) -> Void in
                self.tutorialView.isHidden = true
        }
    }
    
    func adjustedScale() -> CGFloat {
        return scrollView.contentSize.width / image.size.width
    }
    
    func enableNextButton() {
        nextButton.isHidden = false
        UIView.animate(withDuration: 0.1) { () -> Void in
            self.nextButton.alpha = 1.0
            Utils.changeFrameX(view: self.backButton, value: (kScreenWidth - 75 - 110) / 2)
            Utils.changeFrameX(view: self.nextButton, value: self.backButton.frame.origin.x + 55 + 75)
        }
    }
    
    func disableNextButton() {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.nextButton.alpha = 0.0
            self.nextButton.frame = CGRect(x: (kScreenWidth - 55) / 2, y: kScreenHeight - 55 - 15, width: 55, height: 55)
            self.backButton.frame = self.nextButton.frame
            }) { (success) -> Void in
                self.nextButton.isHidden = true
        }
    }
    
    func showResult() {
        let v = UIImage.gifWithData(data: NSData(contentsOf: self.currentResult!.gifLocation!)!)
        
        previewView = UIImageView(image: v)
        
        Utils.centerView(view: previewView!)
        Utils.changeFrameY(view: previewView!, value: previewView!.frame.origin.y - 30)
        self.view.insertSubview(previewView!, belowSubview: backButton)

        previewView!.alpha = 0.0
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.scrollView.alpha = 0.0
            self.previewView!.alpha = 1.0
            }) { (success) -> Void in
                self.scrollView.alpha = 1.0
                self.scrollView.isHidden = true

        }

    }
    
    
    var igURL: URL?
    
    func next() {
        
        if previewView != nil {
            
            Utils.sendAnalyticEvent(name: "Enhancement-Complete")
            self.currentResult!.copyToPasteboard()
            self.currentResult!.saveVideo(callback: { (url) -> Void in

                guard let url = url else { return }
 
                let strURL = String(format: "instagram://library?AssetPath=%@&InstagramCaption=%@", url.absoluteString.escapeStr(), "#zoomenhance")
                let newUrl = URL(string: strURL)!
                
                self.igURL = newUrl
            })
                
            shareView.alpha = 0.0
            shareView.isHidden = false
            self.shareView.viewWithTag(1)!.alpha = 1.0
            self.shareView.viewWithTag(1)!.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)

            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.shareView.alpha = 1.0
                self.shareView.viewWithTag(1)!.alpha = 1.0
                self.shareView.viewWithTag(1)!.transform = CGAffineTransform(scaleX: 1.55, y: 1.55)

                }) { (success) -> Void in
                    
                    UIView.animate(withDuration: 0.22) { () -> Void in
                        self.shareView.viewWithTag(1)!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    }
            }
            return

            /*


NSString *strURL = [NSString stringWithFormat:@"instagram://library?AssetPath=%@&InstagramCaption=%
                @",yourfilepath,yourCaption];
NSString* webStringURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
NSURL* instagramURL = [NSURL URLWithString:webStringURL];
if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
{
[[UIApplication sharedApplication] openURL:instagramURL];
}

*/
        }
        
        nextButton.alpha = 0.5
        nextButton.isEnabled = false
        backButton.alpha = 0.5
        backButton.isEnabled = false
        let e = Enhancer(image: image, finalRect: self.getFinalRect())

        e.process { (result) -> Void in
            self.currentResult = result
            self.nextButton.alpha = 1.0
            self.nextButton.isEnabled = true
            self.backButton.alpha = 1.0
            self.backButton.isEnabled = true
            self.nextButton.setImage(UIImage(named: "WhiteCheck"), for: .normal)
            self.showResult()
        }

    }
    
    func show() {
        UIApplication.shared.setStatusBarHidden(true, with: .slide)
        self.view.alpha = 0.0
        self.view.transform = CGAffineTransform(scaleX: 0.33, y: 0.33)
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }
    
    @objc func close() {
        UIApplication.shared.setStatusBarHidden(false, with: .slide)
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.alpha = 0.0
            self.view.transform = CGAffineTransform(scaleX: 0.33, y: 0.33)
            
            }) { (success) -> Void in
                self.view.removeFromSuperview()
        }
    }

    @objc func back() {
        
        if self.scrollView.isHidden {
            previewView?.removeFromSuperview()
            previewView = nil
            self.scrollView.isHidden = false
            self.scrollView.setZoomScale((kScreenWidth - 50)/imageView.frame.width, animated: true)
            self.nextButton.setImage(UIImage(named: "WhiteRightArrow"), for: .normal)
        } else {
            self.close()
        }
    }

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scrollView.contentOffset.x > 0 || scrollView.contentOffset.y > 0 {
            self.enableNextButton()
        } else {
            self.disableNextButton()
        }
    }
    
    func getFinalRect() -> CGRect {
        let scale = self.adjustedScale()
        let f = CGRect(x: scrollView.contentOffset.x / scale, y: scrollView.contentOffset.y / scale, width: scrollView.frame.width / scale, height: scrollView.frame.height / scale)
        
        return f
    }

}

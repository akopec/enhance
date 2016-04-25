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
        scrollView = UIScrollView(frame: CGRectMake(0, 0, kScreenWidth, kScreenHeight))
        scrollView.bounds = CGRectMake(0, 0, kScreenWidth, kScreenHeight)
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

        let topBG = UIView(frame: CGRectMake(0, 0, size.width, scrollFrame.origin.y))
        topBG.backgroundColor = UIColor(red: 39.0/255.0, green: 50.0/255.0, blue: 48.0/255.0, alpha: 0.7)
        self.view.addSubview(topBG)
        
        let bottomBG = UIView(frame: CGRectMake(0, scrollFrame.origin.y + scrollFrame.size.height, size.width, scrollFrame.origin.y))
        bottomBG.backgroundColor = UIColor(red: 39.0/255.0, green: 50.0/255.0, blue: 48.0/255.0, alpha: 0.7)
        self.view.addSubview(bottomBG)
        
        scrollView.frame = scrollFrame
        scrollView.addSubview(imageView)
        
        backButton = UIButton(frame: CGRectMake((kScreenWidth - 55) / 2, kScreenHeight - 55 - 15, 55, 55))
        backButton.setImage(UIImage(named: "WhiteClose")!, forState: .Normal)
        backButton.backgroundColor = UIColor.whiteColor()
        backButton.layer.cornerRadius = backButton.frame.width / 2
        backButton.layer.masksToBounds = true
        backButton.addTarget(self, action: "back", forControlEvents: .TouchUpInside)
        
        view.addSubview(backButton)
        
        nextButton = UIButton(frame: backButton.frame)
        nextButton.setImage(UIImage(named: "WhiteRightArrow")!, forState: .Normal)
        nextButton.addTarget(self, action: "next", forControlEvents: .TouchUpInside)
        nextButton.backgroundColor = UIColor.whiteColor()
        nextButton.layer.cornerRadius = nextButton.frame.width / 2
        nextButton.layer.masksToBounds = true
        nextButton.hidden = true
        nextButton.alpha = 0.0
        view.addSubview(nextButton)
        
        tutorialView = UIView(frame: self.view.frame)
        tutorialView.backgroundColor = UIColor(red: 39.0/255.0, green: 50.0/255.0, blue: 48.0/255.0, alpha: 0.96)
        let pinch = UIImageView(image: UIImage(named: "PinchToZoom"))
        Utils.changeFrameY(pinch, value: (kScreenHeight - 250) / 2)
        Utils.changeFrameX(pinch, value: (kScreenWidth - pinch.frame.width) / 2)
        tutorialView.addSubview(pinch)
        tutorialView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "okTutorial"))
        
        let width = kScreenWidth - 40
        let tutText = UILabel(frame: CGRectMake(20, pinch.frame.origin.y + 20 + pinch.frame.height, width, 50))
        tutText.text = "Pinch and position this photo to enhance it."
        tutText.font = UIFont(name: "GTWalsheimPro", size: 22)
        tutText.adjustsFontSizeToFitWidth = true
        tutText.numberOfLines = 0
        tutText.textAlignment = .Center
        tutText.textColor = kEnhanceTealColor
        tutorialView.addSubview(tutText)

        shareView = UIView(frame: self.view.frame)
        shareView.backgroundColor = UIColor(red: 36.0/255.0, green: 43.0/255.0, blue: 41.0/255.0, alpha: 0.96)
        shareView.hidden = true

        let successCheck = UIView(frame: CGRectMake(0, 0, 84, 84))
        successCheck.backgroundColor = kEnhanceTealColor
        successCheck.layer.cornerRadius = 43
        successCheck.clipsToBounds = true
        shareView.addSubview(successCheck)
        
        let successImg = UIImageView(image: UIImage(named: "SuccessCheck"))
        successImg.tag = 1
        shareView.addSubview(successImg)
        
        Utils.centerView(successImg)
        Utils.centerView(successCheck)
        Utils.changeFrameY(successCheck, value: successCheck.frame.origin.y - 82)
        Utils.changeFrameY(successImg, value: successImg.frame.origin.y - 82)
        
        let successText = UILabel(frame: CGRectMake(30, successCheck.frame.origin.y + 84 + 20, kScreenWidth - 60, 30))
        successText.textAlignment = .Center
        successText.text = "Saved!"
        successText.textColor = kEnhanceTealColor
        successText.numberOfLines = 0
        successText.font = UIFont(name: "GTWalsheimPro", size: 25)
        shareView.addSubview(successText)
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.alignment = .Center
        let desc = NSMutableAttributedString(string: "GIF", attributes: [NSFontAttributeName: UIFont(name: "GTWalsheimPro-BoldOblique", size: 17)!, NSForegroundColorAttributeName: kEnhanceTealColor])
        desc.appendAttributedString(NSAttributedString(string: " copied to clipboard.\n", attributes: [NSFontAttributeName: UIFont(name: "GTWalsheimPro", size: 17)!, NSForegroundColorAttributeName: kEnhanceOpacTealColor]))
        desc.appendAttributedString(NSAttributedString(string: "Video", attributes: [NSFontAttributeName: UIFont(name: "GTWalsheimPro-BoldOblique", size: 17)!, NSForegroundColorAttributeName: kEnhanceTealColor]))
        desc.appendAttributedString(NSAttributedString(string: " saved to camera roll.", attributes: [NSFontAttributeName: UIFont(name: "GTWalsheimPro", size: 17)!, NSForegroundColorAttributeName: kEnhanceOpacTealColor]))
        
        desc.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, desc.length))
        
        let successDesc = UILabel(frame: CGRectMake(30, successText.frame.origin.y + 30 + 20, kScreenWidth - 60, 50))
        successDesc.textAlignment = .Center
        successDesc.attributedText = desc
        successDesc.numberOfLines = 0
        shareView.addSubview(successDesc)

        
        
        
        let newButton = UIButton(frame: CGRectMake(0, 0, 55, 55))
        newButton.layer.cornerRadius = 27.5
        newButton.clipsToBounds = true
        newButton.backgroundColor = UIColor.clearColor()
        newButton.layer.borderColor = kEnhanceTealColor.CGColor
        newButton.layer.borderWidth = 1.0
        newButton.setImage(UIImage(named: "NewPlus"), forState: .Normal)
        shareView.addSubview(newButton)
        
        Utils.changeFrameX(newButton, value: ((kScreenWidth - 180) / 2) + (180 - 55))
        Utils.changeFrameY(newButton, value: kScreenHeight - 104 - 55)
        
        let newText = UILabel(frame: CGRectMake(0, 0, 55, 18))
        newText.font = UIFont(name: "GTWalsheimPro", size: 15)
        newText.textColor = kEnhanceTealColor
        newText.textAlignment = .Center
        newText.text = "New"
        shareView.addSubview(newText)
        
        Utils.changeFrameX(newText, value: ((kScreenWidth - 180) / 2) + (180 - 55))
        Utils.changeFrameY(newText, value: newButton.frame.origin.y + 55 + 9)

        
        newButton.addTarget(self, action: "close", forControlEvents: .TouchUpInside)
        
        
        let igButton = UIButton(frame: CGRectMake(0, 0, 55, 55))
        igButton.layer.cornerRadius = 27.5
        igButton.clipsToBounds = true
        igButton.backgroundColor = UIColor.clearColor()
        igButton.layer.borderColor = kEnhanceTealColor.CGColor
        igButton.layer.borderWidth = 1.0
        igButton.setImage(UIImage(named: "Instagram"), forState: .Normal)
        shareView.addSubview(igButton)
        
        Utils.changeFrameX(igButton, value: (kScreenWidth - 180) / 2)
        Utils.changeFrameY(igButton, value: kScreenHeight - 104 - 55)
        
        let igText = UILabel(frame: CGRectMake(0, 0, 69, 18))
        igText.font = UIFont(name: "GTWalsheimPro", size: 15)
        igText.textColor = kEnhanceTealColor
        igText.textAlignment = .Center
        igText.text = "Instagram"
        shareView.addSubview(igText)
        
        Utils.changeFrameX(igText, value: ((kScreenWidth - 180) / 2) - 7)
        Utils.changeFrameY(igText, value: newButton.frame.origin.y + 55 + 9)
        
        
        igButton.addTarget(self, action: "instagram", forControlEvents: .TouchUpInside)
        
        
        
        
        self.view.addSubview(shareView)
        
        if NSUserDefaults.standardUserDefaults().integerForKey("tutorial") < 3 {
            self.view.addSubview(tutorialView)
        }
    }
    
    func instagram() {
        
        if let url = self.igURL {
            UIApplication.sharedApplication().openURL(url)
        }
    }

    func okTutorial() {
        NSUserDefaults.standardUserDefaults().setInteger(NSUserDefaults.standardUserDefaults().integerForKey("tutorial")+1, forKey: "tutorial")
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.tutorialView.alpha = 0.0
            }) { (_) -> Void in
                self.tutorialView.hidden = true
        }
    }
    
    func adjustedScale() -> CGFloat {
        return scrollView.contentSize.width / image.size.width
    }
    
    func enableNextButton() {
        nextButton.hidden = false
        UIView.animateWithDuration(0.1) { () -> Void in
            self.nextButton.alpha = 1.0
            Utils.changeFrameX(self.backButton, value: (kScreenWidth - 75 - 110) / 2)
            Utils.changeFrameX(self.nextButton, value: self.backButton.frame.origin.x + 55 + 75)
        }
    }
    
    func disableNextButton() {
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.nextButton.alpha = 0.0
            self.nextButton.frame = CGRectMake((kScreenWidth - 55) / 2, kScreenHeight - 55 - 15, 55, 55)
            self.backButton.frame = self.nextButton.frame
            }) { (success) -> Void in
                self.nextButton.hidden = true
        }
    }
    
    func showResult() {
        let v = UIImage.gifWithData(NSData(contentsOfURL: self.currentResult!.gifLocation!)!)
        
        previewView = UIImageView(image: v)
        
        Utils.centerView(previewView!)
        Utils.changeFrameY(previewView!, value: previewView!.frame.origin.y - 30)
        self.view.insertSubview(previewView!, belowSubview: backButton)

        previewView!.alpha = 0.0
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.scrollView.alpha = 0.0
            self.previewView!.alpha = 1.0
            }) { (success) -> Void in
                self.scrollView.alpha = 1.0
                self.scrollView.hidden = true

        }

    }
    
    
    var igURL: NSURL?
    
    func next() {
        
        if previewView != nil {
            
            Utils.sendAnalyticEvent("Enhancement-Complete")
            self.currentResult!.copyToPasteboard()
            self.currentResult!.saveVideo({ (url) -> Void in
 
                let strURL = String(format: "instagram://library?AssetPath=%@&InstagramCaption=%@", url.absoluteString.escapeStr(), "#zoomenhance")
                let url = NSURL(string: strURL)
                
                print(url)
                print(strURL)
                
                self.igURL = url
                
                
                
            })
                
            shareView.alpha = 0.0
            shareView.hidden = false
            self.shareView.viewWithTag(1)!.alpha = 1.0
            self.shareView.viewWithTag(1)!.transform = CGAffineTransformMakeScale(0.2, 0.2)

            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.shareView.alpha = 1.0
                self.shareView.viewWithTag(1)!.alpha = 1.0
                self.shareView.viewWithTag(1)!.transform = CGAffineTransformMakeScale(1.55, 1.55)

                }) { (success) -> Void in
                    
                    UIView.animateWithDuration(0.22) { () -> Void in
                        self.shareView.viewWithTag(1)!.transform = CGAffineTransformMakeScale(1.0, 1.0)
                    }
            }

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
            
            
            return
        }
        
        nextButton.alpha = 0.5
        nextButton.enabled = false
        backButton.alpha = 0.5
        backButton.enabled = false
        let e = Enhancer(image: image, finalRect: self.getFinalRect())

        e.process { (result) -> Void in
            self.currentResult = result
            self.nextButton.alpha = 1.0
            self.nextButton.enabled = true
            self.backButton.alpha = 1.0
            self.backButton.enabled = true
            self.nextButton.setImage(UIImage(named: "WhiteCheck"), forState: .Normal)
            self.showResult()
        }

    }
    
    func show() {
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Slide)
        self.view.alpha = 0.0
        self.view.transform = CGAffineTransformMakeScale(0.33, 0.33)
        UIView.animateWithDuration(0.2) { () -> Void in
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
        }
    }
    
    func close() {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.view.alpha = 0.0
            self.view.transform = CGAffineTransformMakeScale(0.33, 0.33)
            
            }) { (success) -> Void in
                self.view.removeFromSuperview()
        }
    }

    func back() {
        
        if self.scrollView.hidden {
            previewView?.removeFromSuperview()
            previewView = nil
            self.scrollView.hidden = false
            self.scrollView.setZoomScale((kScreenWidth - 50)/imageView.frame.width, animated: true)
            self.nextButton.setImage(UIImage(named: "WhiteRightArrow"), forState: .Normal)
        } else {
            self.close()
        }
    }
    
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        if scrollView.contentOffset.x > 0 || scrollView.contentOffset.y > 0 {
            self.enableNextButton()
        } else {
            self.disableNextButton()
        }
    }
    
    func getFinalRect() -> CGRect {
        let scale = self.adjustedScale()
        let f = CGRectMake(scrollView.contentOffset.x / scale, scrollView.contentOffset.y / scale, scrollView.frame.width / scale, scrollView.frame.height / scale)
        
        return f
    }

}

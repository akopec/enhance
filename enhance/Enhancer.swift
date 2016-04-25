//
//  Enhancer.swift
//  enhance
//
//  Created by Jeff Hodsdon on 12/24/15.
//  Copyright © 2015 Jeff Hodsdon. All rights reserved.
//

import Foundation
import UIKit
import ImageIO
import MobileCoreServices
import AssetsLibrary
import AVFoundation
import Photos
import CoreImage

class EnhanceResult {
    var gifLocation: NSURL?
    var videoLocation: NSURL?
    var videoLibraryLocation: NSURL?
    
    init() {
        
    }

    func copyToPasteboard() {
        UIPasteboard.generalPasteboard().setData(NSData(contentsOfURL: gifLocation!)!, forPasteboardType: kUTTypeGIF as String)
    }
    
    var assetCollectionPlaceholder: PHObjectPlaceholder!
    var albumFound : Bool = false
    var assetCollection: PHAssetCollection!
    
    func _createVideoAlbum() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", "ZoomEnhance")
        let collection : PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
        
        if let _ = collection.firstObject {
            self.albumFound = true
            assetCollection = collection.firstObject as! PHAssetCollection
        } else {
            let _ = try? PHPhotoLibrary.sharedPhotoLibrary().performChangesAndWait({
                let createAlbumRequest : PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle("ZoomEnhance")
                self.assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
                

            })
            
            let collectionFetchResult = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers([self.assetCollectionPlaceholder.localIdentifier], options: nil)
            self.assetCollection = collectionFetchResult.firstObject as! PHAssetCollection
        }
    }
    
    func saveVideo(callback: ((NSURL) -> Void)?) {
        /*
        self._createVideoAlbum()

        PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
            //foo
            
            let req = PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(self.videoLocation!)
            
            let albumReq = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection)
            albumReq!.addAssets([req!.placeholderForCreatedAsset!])
            
            }) { (success, error) -> Void in
                let result = PHAsset.fetchAssetsInAssetCollection(self.assetCollection, options: nil)
                let asset = result.firstObject as! PHAsset
                PHImageManager.defaultManager().requestAVAssetForVideo(asset, options: nil, resultHandler: { (ava, _, _) -> Void in
                    print("AV \(ava)")
                    callback?((ava as! AVURLAsset).URL)
                })
                print(asset)
        }
        
        */
        
        
        ALAssetsLibrary().writeVideoAtPathToSavedPhotosAlbum(videoLocation!) { (url, error) -> Void in
            self.videoLibraryLocation = url
            callback?(url)
        }
    }
    
}


class Enhancer {
    
    var original: UIImage
    var rect: CGRect
    
    var frameCount: Int = 10
    var width = kResultWidth
    
    var callback: ((EnhanceResult) -> Void)?
    var result: EnhanceResult
    
    init(image: UIImage, finalRect: CGRect) {
        original = image
        rect = finalRect
        result = EnhanceResult()
    }
    
    func process(finished: ((EnhanceResult) -> Void)) {
        
        callback = finished
        
        var images = [self.imageToWidth(original, width: CGFloat(width))]
        var last: UIImage?
        for i in 1..<frameCount+1 {
            last = self.imageForFrame(i)
            images.append(last!)
        }
        
        images.append(self.sharpen(last!, amount: 0.6))
        images.append(self.sharpen(last!, amount: 1.5))
        images.append(self.sharpen(last!, amount: 2.5))
        
        self.gif(images)
        self.video(images)
    }
    
    func sharpen(image: UIImage, amount: Double) -> UIImage {
        
        /*
        let filter = CIFilter(name: "CISharpenLuminance")!
        filter.setValue(amount, forKey: kCIInputSharpnessKey)
        */
        let filter = CIFilter(name: "CIUnsharpMask")!
        filter.setValue(amount, forKey: kCIInputIntensityKey)
        filter.setValue(4.0, forKey: kCIInputRadiusKey)
        
        filter.setValue(CIImage(image: image)!, forKey: kCIInputImageKey)
        
        
        
        let out = filter.outputImage!
        let context = CIContext(options: nil)
        let cg = context.createCGImage(out, fromRect: out.extent)
  
        return UIImage(CGImage: cg)


    }

    func gif(images: [UIImage]) {
        
        let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]
        var frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: 0.15]]
        
        let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("enhance.gif")
        let _ = try? NSFileManager.defaultManager().removeItemAtPath(url.path!)

        let destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, images.count, nil)!
        CGImageDestinationSetProperties(destination, fileProperties)
        for i in 0..<images.count {
            if i == images.count-1 {
                frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: 1.7]]
            } else if i == 0 {
                frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: 0.6]]
            } else {
                frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: 0.15]]
            }
            let cgi = images[i].CGImage
            print(cgi)
            CGImageDestinationAddImage(destination, cgi!, frameProperties)
        }
        
        if CGImageDestinationFinalize(destination) {
            result.gifLocation = url

        }
    }
    
    func video(images: [UIImage]) {
        let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("enhance.mov")
        let _ = try? NSFileManager.defaultManager().removeItemAtPath(url.path!)
        
        let writter = try? AVAssetWriter(URL: url, fileType: AVFileTypeQuickTimeMovie)
        let inputSettings: [String: AnyObject] = [AVVideoCodecKey: AVVideoCodecH264, AVVideoWidthKey: Int(images[0].size.width), AVVideoHeightKey: Int(images[0].size.height)]
        let input = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: inputSettings)
        
        writter!.addInput(input)
        
        let bufferSettings: [String: AnyObject]  = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB)]
        let bufferAdapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: bufferSettings)
        
        let frameTime = CMTimeMake(1, 6)
        
        
        writter!.startWriting()
        writter!.startSessionAtSourceTime(kCMTimeZero)
        
        let inputQueue = dispatch_queue_create("inputQueue", nil)
        
        var i = 0
        var iterImages = images
        iterImages.append(images.last!)
        input.requestMediaDataWhenReadyOnQueue(inputQueue) { () -> Void in
            while true {
                if i >= iterImages.count {
                    break
                }
                
                if input.readyForMoreMediaData {
                    let img = iterImages[i]
                    if let imgBuffer = self._pixelBufferFromImage(img) {
                        var cTime = kCMTimeZero
                        if (i == iterImages.count-1) {
                            cTime = CMTimeAdd(CMTimeMake(Int64(i-1), frameTime.timescale), CMTimeMake(1, 1))
                        } else {
                            cTime = CMTimeAdd(CMTimeMake(Int64(i-1), frameTime.timescale), frameTime)
                        }

                        bufferAdapter.appendPixelBuffer(imgBuffer, withPresentationTime: cTime)
                        i++
                    }
                }
            }
            
            input.markAsFinished()
            writter!.finishWritingWithCompletionHandler({ () -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.result.videoLocation = url
                    self.callback!(self.result)
                })
            })
        }
    }
    
    func _pixelBufferFromImage(img: UIImage) -> CVPixelBufferRef? {
        let opt: [String: AnyObject] = [
            kCVPixelBufferCGImageCompatibilityKey as String: NSNumber(bool: true),
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: NSNumber(bool: true)
        ]
       
        var buffer: CVPixelBufferRef? = nil
        if CVPixelBufferCreate(kCFAllocatorDefault, Int(img.size.width), Int(globalHeight!), kCVPixelFormatType_32ARGB, opt, &buffer) != kCVReturnSuccess {
            //failure
        }
        
        CVPixelBufferLockBaseAddress(buffer!, 0)
        let data = CVPixelBufferGetBaseAddress(buffer!)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGBitmapContextCreate(data, Int(img.size.width), Int(img.size.height), 8, 4 * Int(img.size.width), colorSpace, CGImageAlphaInfo.NoneSkipFirst.rawValue)
        
        CGContextConcatCTM(context, CGAffineTransformIdentity)
        CGContextDrawImage(context, CGRectMake(0, 0, img.size.width, img.size.height), img.CGImage!)

        CVPixelBufferUnlockBaseAddress(buffer!, 0)
        
        return buffer
    }

    func imageForFrame(num: Int) -> UIImage {
        let widthDistance = original.size.width - rect.width
        let heightDistance = original.size.height - rect.height

        let step = CGFloat(num)/CGFloat(frameCount)
        let crop = CGRectMake(rect.origin.x * step, rect.origin.y * step, original.size.width - (widthDistance * step), original.size.height - (heightDistance * step))
        
        UIGraphicsBeginImageContext(crop.size)

        original.drawAtPoint(CGPointMake(-crop.origin.x, -crop.origin.y))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return self.imageToWidth(scaledImage, width: CGFloat(width))
    }
    
    var globalHeight: CGFloat?
    
    func imageToWidth(image: UIImage, width: CGFloat) -> UIImage {
        let oldWidth = image.size.width
        let scaleFactor = width / oldWidth
        
        if globalHeight == nil {
            globalHeight = image.size.height * scaleFactor
            globalHeight = globalHeight! - (globalHeight! % 16)
        }

        //var newWidth = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContext(CGSizeMake(width, globalHeight!))
        image.drawInRect(CGRectMake(0, 0, width, globalHeight!))
        
        
        let waterMarkText = NSString(string: "Zoom, Enhance!")
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .Right
        
        let shadow = NSShadow()
        shadow.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.45)
        shadow.shadowBlurRadius = 0.3
        shadow.shadowOffset = CGSizeMake(0, 0.5)
        
        let waterMarkAttr = [
            NSFontAttributeName: UIFont(name: "GTWalsheimPro-BoldOblique", size: 13)!,
            NSForegroundColorAttributeName: UIColor(red: 1, green: 1, blue: 1, alpha: 0.42),
            NSParagraphStyleAttributeName: paragraph,
            NSShadowAttributeName: shadow
        ]
        
        waterMarkText.drawInRect(CGRectMake(0, globalHeight! - 20, width - 6, 20), withAttributes: waterMarkAttr)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage

    }
    
    

}
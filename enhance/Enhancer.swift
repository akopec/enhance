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
import CoreServices
import AssetsLibrary
import AVFoundation
import Photos
import CoreImage

class EnhanceResult {
    var gifLocation: URL?
    var videoLocation: URL?
    var videoLibraryLocation: URL?
    
    init() {
        
    }

    func copyToPasteboard() {
        do {
            try UIPasteboard.general.setData(Data(contentsOf: gifLocation!), forPasteboardType: kUTTypeGIF as String)
        } catch {
            print("Unable to copy gif to pasteboard: \(error)")
        }
    }
    
    var assetCollectionPlaceholder: PHObjectPlaceholder!
    var albumFound : Bool = false
    var assetCollection: PHAssetCollection!
    
    func _createVideoAlbum() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", "ZoomEnhance")
        let collection : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _ = collection.firstObject {
            self.albumFound = true
            assetCollection = collection.firstObject!
        } else {
            let _ = try? PHPhotoLibrary.shared().performChangesAndWait({
                let createAlbumRequest : PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "ZoomEnhance")
                self.assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
                

            })
            
            let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [self.assetCollectionPlaceholder.localIdentifier], options: nil)
            self.assetCollection = collectionFetchResult.firstObject as! PHAssetCollection
        }
    }
    
    func saveVideo(callback: ((URL?) -> Void)?) {
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
        
        
        ALAssetsLibrary().writeVideoAtPath(toSavedPhotosAlbum: videoLocation!) { (url, error) -> Void in
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
    
    func process(finished: @escaping ((EnhanceResult) -> Void)) {
        
        callback = finished
        
        var images = [self.imageToWidth(image: original, width: CGFloat(width))]
        var last: UIImage?
        for i in 1..<frameCount+1 {
            last = self.imageForFrame(num: i)
            images.append(last!)
        }
        
        images.append(self.sharpen(image: last!, amount: 0.6))
        images.append(self.sharpen(image: last!, amount: 1.5))
        images.append(self.sharpen(image: last!, amount: 2.5))
        
        self.gif(images: images)
        self.video(images: images)
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
        let cg = context.createCGImage(out, from: out.extent)!
        return UIImage(cgImage: cg)
    }

    func gif(images: [UIImage]) {
        
        let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]
        var frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: 0.15]]

        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("enhance.gif")
        let _ = try? FileManager.default.removeItem(atPath: url.path)

        let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypeGIF, images.count, nil)!
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)
        for i in 0..<images.count {
            if i == images.count-1 {
                frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: 1.7]]
            } else if i == 0 {
                frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: 0.6]]
            } else {
                frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: 0.15]]
            }
            let cgi = images[i].cgImage
            CGImageDestinationAddImage(destination, cgi!, frameProperties as CFDictionary)
        }
        
        if CGImageDestinationFinalize(destination) {
            result.gifLocation = url

        }
    }
    
    func video(images: [UIImage]) {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("enhance.mov")
        let _ = try? FileManager.default.removeItem(atPath: url.path)
        
        let writter = try? AVAssetWriter(outputURL: url, fileType: AVFileType.mov)
        let inputSettings: [String: Any] = [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: Int(images[0].size.width), AVVideoHeightKey: Int(images[0].size.height)]
        let input = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: inputSettings)
        
        writter!.add(input)
        
        let bufferSettings: [String: Any]  = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB)]
        let bufferAdapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: bufferSettings)
        
        let frameTime = CMTimeMake(value: 1, timescale: 6)

        writter!.startWriting()
        writter!.startSession(atSourceTime: CMTime.zero)
        
        let inputQueue = DispatchQueue(__label: "inputQueue", attr: nil)
        
        var i = 0
        var iterImages = images
        iterImages.append(images.last!)
        input.requestMediaDataWhenReady(on: inputQueue) { () -> Void in
            while true {
                if i >= iterImages.count {
                    break
                }
                
                if input.isReadyForMoreMediaData {
                    let img = iterImages[i]
                    if let imgBuffer = self._pixelBufferFromImage(img: img) {
                        var cTime = CMTime.zero
                        if (i == iterImages.count-1) {
                            cTime = CMTimeAdd(CMTimeMake(value: Int64(i-1), timescale: frameTime.timescale), CMTimeMake(value: 1, timescale: 1))
                        } else {
                            cTime = CMTimeAdd(CMTimeMake(value: Int64(i-1), timescale: frameTime.timescale), frameTime)
                        }

                        bufferAdapter.append(imgBuffer, withPresentationTime: cTime)
                        i += 1
                    }
                }
            }
            
            input.markAsFinished()
            writter!.finishWriting(completionHandler: { () -> Void in
                DispatchQueue.main.async {
                    self.result.videoLocation = url
                    self.callback!(self.result)
                }
            })
        }
    }
    
    func _pixelBufferFromImage(img: UIImage) -> CVPixelBuffer? {
        let opt: [String: AnyObject] = [
            kCVPixelBufferCGImageCompatibilityKey as String: NSNumber(value: true),
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: NSNumber(value: true)
        ]
       
        var buffer: CVPixelBuffer? = nil
        if CVPixelBufferCreate(kCFAllocatorDefault, Int(img.size.width), Int(globalHeight!), kCVPixelFormatType_32ARGB, opt as CFDictionary, &buffer) != kCVReturnSuccess {
            //failure
        }

        CVPixelBufferLockBaseAddress(buffer!, CVPixelBufferLockFlags.init(rawValue: 0))
        let data = CVPixelBufferGetBaseAddress(buffer!)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGContext(data: data, width: Int(img.size.width), height: Int(img.size.height), bitsPerComponent: 8, bytesPerRow: 4 * Int(img.size.width), space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)!

        context.concatenate(.identity)
        context.draw(img.cgImage!, in: .init(x: 0, y: 0, width: img.size.width, height: img.size.height))

        CVPixelBufferUnlockBaseAddress(buffer!, CVPixelBufferLockFlags.init(rawValue: 0))
        
        return buffer
    }

    func imageForFrame(num: Int) -> UIImage {
        let widthDistance = original.size.width - rect.width
        let heightDistance = original.size.height - rect.height

        let step = CGFloat(num)/CGFloat(frameCount)
        let crop = CGRect(x: rect.origin.x * step, y: rect.origin.y * step, width: original.size.width - (widthDistance * step), height: original.size.height - (heightDistance * step))
        
        UIGraphicsBeginImageContext(crop.size)

        original.draw(at: CGPoint(x: -crop.origin.x, y: -crop.origin.y))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return self.imageToWidth(image: scaledImage, width: CGFloat(width))
    }
    
    var globalHeight: CGFloat?
    
    func imageToWidth(image: UIImage, width: CGFloat) -> UIImage {
        let oldWidth = image.size.width
        let scaleFactor = width / oldWidth
        
        if globalHeight == nil {
            globalHeight = image.size.height * scaleFactor
            globalHeight = globalHeight! - globalHeight!.truncatingRemainder(dividingBy: 16)
        }

        //var newWidth = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width: width, height: globalHeight!))
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: globalHeight!))
        
        
        let waterMarkText = NSString(string: "Zoom, Enhance!")
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .right
        
        let shadow = NSShadow()
        shadow.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.45)
        shadow.shadowBlurRadius = 0.3
        shadow.shadowOffset = CGSize(width: 0, height: 0.5)
        
        let waterMarkAttr = [
            NSAttributedString.Key.font: UIFont(name: "GTWalsheimPro-BoldOblique", size: 13)!,
            NSAttributedString.Key.foregroundColor: UIColor(red: 1, green: 1, blue: 1, alpha: 0.42),
            NSAttributedString.Key.paragraphStyle: paragraph,
            NSAttributedString.Key.shadow: shadow
        ]
        
        waterMarkText.draw(in: CGRect(x: 0, y: globalHeight! - 20, width: width - 6, height: 20), withAttributes: waterMarkAttr)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    

}

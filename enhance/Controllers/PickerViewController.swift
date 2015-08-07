//
//  PickerViewController.swift
//  enhance
//
//  Created by Jeff Hodsdon on 8/6/15.
//  Copyright (c) 2015 Jeff Hodsdon. All rights reserved.
//

import UIKit
import Photos

let kImagePadding: CGFloat = 3

let kImageSize = CGSizeMake((kScreenWidth / 3) - (kImagePadding-1), (kScreenWidth / 3) - (kImagePadding-1))
let kImageDubSize = CGSizeMake(kImageSize.width * 2, kImageSize.height * 2)

class PhotoCollectionViewCell: UICollectionViewCell {
    
    var asset: PHAsset!
    
    var imageView: UIImageView?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        

        
    }
    
    func clearImage() {
        for v in self.contentView.subviews as! [UIView] {
            v.removeFromSuperview()
        }
    }
    
    func updateCell() {
        
        if tag > 0 {
            PHCachingImageManager.defaultManager().cancelImageRequest(Int32(tag))
        }

        println(kImageSize)
        let opt = PHImageRequestOptions()
        opt.resizeMode = .Exact
        opt.version = .Original
        tag = Int(PHCachingImageManager.defaultManager().requestImageForAsset(asset, targetSize: kImageDubSize, contentMode: .AspectFill, options: opt) { (image, stuff) -> Void in
            self.tag = 0
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.clearImage()
                var iv = UIImageView(image: image)
                iv.frame = CGRectMake(0, 0, kImageSize.width, kImageSize.height)
                self.contentView.addSubview(iv)
                println(image)
                println(stuff)
            })

            
        })
    }
}

class PickerViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var collectionView: UICollectionView!
    var results: PHFetchResult!
    var currentEnhance: EnhanceViewController?

    override func loadView() {
        super.loadView()
        
        var opt = PHFetchOptions()
        opt.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        opt.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.Image.rawValue)
        results = PHAsset.fetchAssetsWithOptions(opt)
        
        self.title = "Zoom, Enhance!"
        if let nav = self.navigationController {
            nav.navigationBar.barStyle = .BlackTranslucent
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = kImageSize
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = kImagePadding
        layout.sectionInset = UIEdgeInsetsMake(CGFloat(kImagePadding), CGFloat(0), CGFloat(kImagePadding), CGFloat(0))

        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "PhotoCollectionViewCell")
        self.view.addSubview(collectionView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.collectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return kImageSize
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionViewCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        cell.asset = results[indexPath.row] as! PHAsset
        cell.updateCell()

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
        var cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCollectionViewCell
        
        let opt = PHImageRequestOptions()
        opt.resizeMode = .Exact
        opt.version = .Original
        opt.synchronous = true
        
        let size = CGSizeMake(CGFloat(cell.asset.pixelWidth), CGFloat(cell.asset.pixelHeight))
        PHImageManager.defaultManager().requestImageForAsset(cell.asset, targetSize: size, contentMode: .AspectFill, options: opt) { (image, stuff) -> Void in
            
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
            self.currentEnhance = EnhanceViewController()
            self.currentEnhance!.image = image
            self.view.window!.addSubview(self.currentEnhance!.view)
            println(image)
            println(stuff)
        }
        
        
    }
    
}

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
        for v in self.contentView.subviews {
            v.removeFromSuperview()
        }
    }
    
    func updateCell() {
        
        if tag > 0 {
            PHCachingImageManager.defaultManager().cancelImageRequest(Int32(tag))
        }

        let opt = PHImageRequestOptions()
        opt.resizeMode = .Exact
        opt.version = .Unadjusted
        tag = Int(PHCachingImageManager.defaultManager().requestImageForAsset(asset, targetSize: kImageDubSize, contentMode: .AspectFill, options: opt) { (image, stuff) -> Void in
            self.tag = 0
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.clearImage()
                let iv = UIImageView(image: image)
                iv.frame = CGRectMake(0, 0, kImageSize.width, kImageSize.height)
                self.contentView.addSubview(iv)
            })

            
        })
    }
}

class PickerViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var collectionView: UICollectionView!
    var results: PHFetchResult?
    var currentEnhance: EnhanceViewController?

    override func loadView() {
        super.loadView()
  
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload", name: "DidBecomeActive", object: nil)

        self.reload()
    }
    
    func reload() {
        let opt = PHFetchOptions()
        opt.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        opt.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.Image.rawValue)
        results = PHAsset.fetchAssetsWithOptions(opt)
        self.collectionView.reloadData()
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
        if results == nil {
            return 0
        }
        
        return results!.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionViewCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        cell.asset = results![indexPath.row] as! PHAsset
        cell.updateCell()

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
        let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCollectionViewCell
        
        let opt = PHImageRequestOptions()
        opt.resizeMode = .Exact
        opt.version = .Unadjusted
        opt.synchronous = true
        
        PHImageManager.defaultManager().requestImageDataForAsset(cell.asset, options: opt) { (data, title, orientation, meta) -> Void in
            
            let img = UIImage(data: data!)
            self.currentEnhance = EnhanceViewController()
            self.currentEnhance!.image = img
            self.view.window!.addSubview(self.currentEnhance!.view)
            self.currentEnhance!.nav = self.navigationController
            self.currentEnhance!.show()


        }
    }
    
}

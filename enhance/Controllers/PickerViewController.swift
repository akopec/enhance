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

let kImageSize = CGSize(width: (kScreenWidth / 3) - (kImagePadding-1), height: (kScreenWidth / 3) - (kImagePadding-1))
let kImageDubSize = CGSize(width: kImageSize.width * 2, height: kImageSize.height * 2)

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
            PHCachingImageManager.default().cancelImageRequest(Int32(tag))
        }

        let opt = PHImageRequestOptions()
        opt.resizeMode = .exact
        opt.version = .unadjusted
        tag = Int(PHCachingImageManager.default().requestImage(for: asset, targetSize: kImageDubSize, contentMode: .aspectFill, options: opt) { (image, stuff) -> Void in
            self.tag = 0
            DispatchQueue.main.async {
                self.clearImage()
                let iv = UIImageView(image: image)
                iv.frame = CGRect(x: 0, y: 0, width: kImageSize.width, height: kImageSize.height)
                self.contentView.addSubview(iv)
            }
        })
    }
}

class PickerViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    var collectionView: UICollectionView!
    var results: PHFetchResult<PHAsset>?
    var currentEnhance: EnhanceViewController?

    override func loadView() {
        super.loadView()
  
        self.title = "Zoom, Enhance!"
        if let nav = self.navigationController {
            nav.navigationBar.barStyle = .black
            nav.navigationBar.isTranslucent = true
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = kImageSize
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = kImagePadding
        layout.sectionInset = UIEdgeInsets(top: CGFloat(kImagePadding), left: CGFloat(0), bottom: CGFloat(kImagePadding), right: CGFloat(0))

        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "PhotoCollectionViewCell")
        self.view.addSubview(collectionView)

        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: UIApplication.didBecomeActiveNotification, object: nil)

        self.reload()
    }
    
    @objc func reload() {
        let opt = PHFetchOptions()
        opt.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        opt.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        results = PHAsset.fetchAssets(with: opt)
        self.collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return kImageSize
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if results == nil {
            return 0
        }
        
        return results!.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath as IndexPath) as! PhotoCollectionViewCell
        
        cell.asset = results![indexPath.row]
        cell.updateCell()

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = self.collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        
        let opt = PHImageRequestOptions()
        opt.resizeMode = .exact
        opt.version = .unadjusted
        opt.isSynchronous = true
        
        PHImageManager.default().requestImageData(for: cell.asset, options: opt) { (data, title, orientation, meta) -> Void in
            
            let img = UIImage(data: data!)
            self.currentEnhance = EnhanceViewController()
            self.currentEnhance!.image = img
            self.view.window!.addSubview(self.currentEnhance!.view)
            self.currentEnhance!.nav = self.navigationController
            self.currentEnhance!.show()
        }
    }
    
}

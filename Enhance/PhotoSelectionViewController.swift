//
//  PhotoSelectionViewController.swift
//  Enhance
//
//  Created by Jonathan Baker on 4/23/17.
//
//

import UIKit
import Photos

final class PhotoSelectionViewController: UICollectionViewController {

    // MARK: - Properties

    private var fetchResult: PHFetchResult<PHAsset>? {
        didSet {
            collectionView?.reloadData()
        }
    }


    // MARK: - Initializers

    init() {
        super.init(collectionViewLayout: CollectionViewLayout())

        title = "Zoom, Enhance!"
    }

    required init?(coder: NSCoder) {
        unimplemented()
    }


    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.backgroundColor = UIColor(hex: 0x222222)
        collectionView?.register(ThumbnailCollectionViewCell.self, forCellWithReuseIdentifier: "thumbnail")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        fetchResult = PHAsset.fetchAssets(with: options)
    }


    // MARK: - UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumbnail", for: indexPath) as! ThumbnailCollectionViewCell
        
        return cell
    }
}

extension PhotoSelectionViewController {
    final class CollectionViewLayout: UICollectionViewFlowLayout {
        override init() {
            super.init()
        }

        required init?(coder: NSCoder) {
            unimplemented()
        }
    }
}

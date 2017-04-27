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

        title = NSLocalizedString("application.name", comment: "")
    }

    required init?(coder: NSCoder) {
        unimplemented()
    }


    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.backgroundColor = UIColor(hex: 0x222222)
        collectionView?.register(ThumbnailCollectionViewCell.self, forCellWithReuseIdentifier: "thumbnail")

        if !Settings.hasShownApplicationOnboarding {
            let onboarding = OnboardingViewController()
            present(onboarding, animated: true, completion: {
                Settings.hasShownApplicationOnboarding = true
            })
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let photosAuthorized = PHPhotoLibrary.authorizationStatus() == .authorized
        collectionView?.backgroundView = photosAuthorized ? nil : PermissionDeniedEmptyView()

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
        cell.asset.value = fetchResult?.object(at: indexPath.item)
        return cell
    }


    // MARK: - UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let asset = fetchResult?.object(at: indexPath.item) else { return }
        let viewController = EnhancementViewController(asset: asset)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension PhotoSelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = 3
        let padding: CGFloat = 2
        let columnWidth = (collectionView.bounds.width - (padding * columns)) / columns
        return CGSize(width: columnWidth, height: columnWidth)
    }
}

extension PhotoSelectionViewController {
    final class CollectionViewLayout: UICollectionViewFlowLayout {
        override init() {
            super.init()

            minimumLineSpacing = 2
            minimumInteritemSpacing = 2
            sectionInset = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
        }

        required init?(coder: NSCoder) {
            unimplemented()
        }
    }
}

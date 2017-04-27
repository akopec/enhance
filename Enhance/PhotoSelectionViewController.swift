//
//  PhotoSelectionViewController.swift
//  Enhance
//
//  Created by Jonathan Baker on 4/23/17.
//
//

import UIKit
import Photos
import ReactiveSwift

final class PhotoSelectionViewController: UICollectionViewController {

    // MARK: - Properties

    private let fetchResult = MutableProperty<PHFetchResult<PHAsset>?>(nil)


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

        fetchResult.producer
            .map({ _ in () })
            .observe(on: UIScheduler())
            .startWithValues({ [weak collectionView] in
                collectionView?.reloadData()
            })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let photosAuthorized = PHPhotoLibrary.authorizationStatus() == .authorized
        collectionView?.backgroundView = photosAuthorized ? nil : PermissionDeniedEmptyView()

        if photosAuthorized {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchResult <~ PHAsset.reactive
                .fetchAssets(with: .image, options: fetchOptions)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !Settings.hasShownApplicationOnboarding {
            let onboarding = OnboardingViewController()
            present(onboarding, animated: true, completion: {
                Settings.hasShownApplicationOnboarding = true
            })
        }
    }


    // MARK: - UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.value?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumbnail", for: indexPath) as! ThumbnailCollectionViewCell
        cell.asset.value = fetchResult.value?.object(at: indexPath.item)
        return cell
    }


    // MARK: - UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let asset = fetchResult.value?.object(at: indexPath.item) else { return }
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

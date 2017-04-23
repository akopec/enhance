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
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
    }


    // MARK: - UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = .red
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

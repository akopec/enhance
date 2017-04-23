//
//  ThumbnailCollectionViewCell.swift
//  Enhance
//
//  Created by Jonathan Baker on 4/23/17.
//
//

import UIKit
import Photos
import Result
import ReactiveSwift
import ReactiveCocoa

final class ThumbnailCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties

    private let imageView: UIImageView

    let asset = MutableProperty<PHAsset?>(nil)


    // MARK: - Initializers

    override init(frame: CGRect) {
        imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false

        super.init(frame: frame)

        addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        imageView.reactive.image <~ asset.producer
            .flatMap(.latest, transform: { asset -> SignalProducer<UIImage, AnyError> in
                guard let asset = asset else { return .empty }

                let targetSize = CGSize(width: 256, height: 256)

                return PHImageManager.default().reactive
                    .requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill)
            })
            .flatMapError({ _ in .empty })
            .observe(on: UIScheduler())
    }

    required init?(coder: NSCoder) {
        unimplemented()
    }


    // MARK: - UICollectionReusableView

    override func prepareForReuse() {
        super.prepareForReuse()
        asset.value = nil
    }
}

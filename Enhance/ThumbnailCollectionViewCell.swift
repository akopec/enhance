//
//  ThumbnailCollectionViewCell.swift
//  Enhance
//
//  Created by Jonathan Baker on 4/23/17.
//
//

import UIKit
import Photos

final class ThumbnailCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties

    let imageView: UIImageView


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
    }

    required init?(coder: NSCoder) {
        unimplemented()
    }


    // MARK: - UICollectionReusableView

    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

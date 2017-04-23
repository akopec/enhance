//
//  EnhancementImageView.swift
//  Enhance
//
//  Created by Jonathan Baker on 4/23/17.
//
//

import UIKit
import ReactiveSwift

final class EnhancementImageView: UIView, UIScrollViewDelegate {

    // MARK: - Properties

    private let imageView = UIImageView()

    private let scrollView = UIScrollView()

    var image: UIImage? {
        didSet {
            updateImage()
        }
    }


    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }


    // MARK: - UIScrollViewDelegate

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }


    // MARK: - Private

    private func setup() {
        scrollView.frame = bounds
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.addSubview(imageView)

        addSubview(scrollView)
    }

    private func updateImage() {
        imageView.image = image
        imageView.transform = .identity

        if let image = image {
            scrollView.contentSize = image.size
            imageView.frame = CGRect(origin: .zero, size: image.size)

            let horizontalScale = scrollView.bounds.width / image.size.width
            let verticalScale = scrollView.bounds.height / image.size.height
            let minimumScale = min(horizontalScale, verticalScale)

            scrollView.minimumZoomScale = minimumScale
            scrollView.maximumZoomScale = 1.0
            scrollView.zoomScale = minimumScale
        }
        else {
            imageView.frame = .zero
            scrollView.contentSize = .zero
            scrollView.minimumZoomScale = 1.0
            scrollView.maximumZoomScale = 1.0
            scrollView.zoomScale = 1.0
            scrollView.contentInset = .zero
        }

        var horizontalInset: CGFloat = 0
        var verticalInset: CGFloat = 0

        if (scrollView.contentSize.height < scrollView.bounds.height) {
            verticalInset = (scrollView.bounds.height - scrollView.contentSize.height) * 0.5;
        }

        if (scrollView.contentSize.width < scrollView.bounds.width) {
            horizontalInset = (scrollView.bounds.width - scrollView.contentSize.width) * 0.5;
        }

        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset)
    }
}

extension Reactive where Base: EnhancementImageView {
    var image: BindingTarget<UIImage?> {
        return makeBindingTarget(on: UIScheduler(), {
            $0.image = $1
        })
    }
}

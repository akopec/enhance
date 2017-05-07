//
//  EnhancementViewController.swift
//  Enhance
//
//  Created by Jonathan Baker on 4/23/17.
//
//

import UIKit
import Photos
import ReactiveSwift
import ReactiveCocoa

final class EnhancementViewController: UIViewController, UIScrollViewDelegate {

    // MARK: - Properties

    private let asset: PHAsset

    @IBOutlet private var scrollView: UIScrollView!

    @IBOutlet private var imageView: UIImageView!

    @IBOutlet private var cancelButton: UIControl!

    @IBOutlet private var continueButton: UIControl!

    @IBOutlet private var scrollViewHeight: NSLayoutConstraint!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }


    // MARK: - Initializers

    init(asset: PHAsset) {
        self.asset = asset
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        unimplemented()
    }


    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false

        view.backgroundColor = UIColor(hex: 0x222222)

        PHImageManager.default().reactive
            .requestImageData(for: asset)
            .map({ data, _ in UIImage(data: data) })
            .flatMapError({ _ in .empty })
            .observe(on: UIScheduler())
            .startWithValues({ [weak self] image in
                self?.updateImage(image)
            })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }


    // MARK: - UIScrollViewDelegate

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        continueButton?.isHidden = scrollView.zoomScale <= scrollView.minimumZoomScale
    }


    // MARK: - Actions

    @IBAction private func cancel(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction private func save(sender: UIButton) {
        Enhancer.render(asset: asset, cropRect: cropRect())
            .startWithResult({ result in
                switch result {
                case .success(let images):
                    print(images)
                case .failure(let error):
                    print(error)
                }
            })
    }


    // MARK: - Private

    private func updateImage(_ image: UIImage?) {
        imageView.image = image
        imageView.transform = .identity

        if let image = image {
            let aspectRatio = image.size.width / image.size.height
            scrollViewHeight.constant = scrollView.bounds.width / aspectRatio

            let minimumScale = scrollView.bounds.width / image.size.width

            scrollView.minimumZoomScale = minimumScale
            scrollView.maximumZoomScale = 1.0
            scrollView.zoomScale = minimumScale
        }
    }

    private func cropRect() -> CGRect {
        var cropRect = CGRect(origin: scrollView.contentOffset, size: .zero)
        cropRect.size.width = scrollView.bounds.width / scrollView.zoomScale
        cropRect.size.height = scrollView.bounds.height / scrollView.zoomScale
        return cropRect
    }
}

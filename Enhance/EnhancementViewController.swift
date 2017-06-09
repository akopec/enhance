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


    // MARK: - UIScrollViewDelegate

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        continueButton?.isHidden = scrollView.zoomScale <= scrollView.minimumZoomScale
    }


    // MARK: - Actions

    @IBAction private func cancel(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func save(sender: UIButton) {
        Enhancer.render(asset: asset, cropRect: cropRect())
            .observe(on: UIScheduler())
            .startWithResult({ [weak self] result in
                switch result {
                case .success(let result):
                    print(result)
                    guard let navigationController = self?.navigationController else {
                        return
                    }
                    let viewController = ResultViewController(result: result)
                    navigationController.pushViewController(viewController, animated: true)
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
        var cropRect = scrollView.bounds
        cropRect.origin.x /= scrollView.zoomScale
        cropRect.origin.y /= scrollView.zoomScale
        cropRect.size.width /= scrollView.zoomScale
        cropRect.size.height /= scrollView.zoomScale
        return cropRect
    }
}

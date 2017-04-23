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

final class EnhancementViewController: UIViewController {

    // MARK: - Properties

    private let asset: PHAsset

    @IBOutlet private var cancelButton: UIButton!

    @IBOutlet private var continueButton: UIButton!

    @IBOutlet private var imageView: EnhancementImageView!


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

        view.backgroundColor = UIColor(hex: 0x222222)

        imageView.reactive.image <~ PHImageManager.default().reactive
            .requestImageData(for: asset)
            .map({ data, _ in UIImage(data: data) })
            .flatMapError({ _ in .empty })
            .observe(on: UIScheduler())
    }


    // MARK: - Actions

    @IBAction private func cancel(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction private func save(sender: UIButton) {
        print(#function)
    }
}

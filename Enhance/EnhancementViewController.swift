//
//  EnhancementViewController.swift
//  Enhance
//
//  Created by Jonathan Baker on 4/23/17.
//
//

import UIKit
import Photos

final class EnhancementViewController: UIViewController {

    // MARK: - Properties

    private let asset: PHAsset

    @IBOutlet private var cancelButton: UIButton!

    @IBOutlet private var continueButton: UIButton!


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
    }


    // MARK: - Actions

    @IBAction private func cancel(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction private func save(sender: UIButton) {
        print(#function)
    }
}

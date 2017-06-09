//
//  ResultViewController.swift
//  Enhance
//
//  Created by Jonathan Baker on 6/9/17.
//
//

import UIKit

final class ResultViewController: UIViewController {

    // MARK: - Properties

    fileprivate let result: EnhancerResult

    @IBOutlet fileprivate var previewView: PreviewView!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }


    // MARK: - Initializers

    init(result: EnhancerResult) {
        self.result = result
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        unimplemented()
    }


    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        NSLayoutConstraint.activate([
            previewView.widthAnchor.constraint(equalTo: previewView.heightAnchor, multiplier: result.aspectRatio)
        ])

        previewView.videoURL = result.mov
    }
}

//
//  OnboardingViewController.swift
//  Enhance
//
//  Created by Jonathan Baker on 4/22/17.
//
//

import UIKit
import Photos

final class OnboardingViewController: UIViewController {

    // MARK: - Properties

    @IBOutlet private var stackView: UIStackView!

    @IBOutlet private var welcomeView: UIView!

    @IBOutlet private var permissionsView: UIView!

    @IBOutlet private var permissionsInfo: UILabel!


    // MARK: - Initializers

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        unimplemented()
    }


    // MARK: - UIViewController

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        stackView.addArrangedSubview(welcomeView)
        stackView.addArrangedSubview(permissionsView)

        NSLayoutConstraint.activate([
            welcomeView.widthAnchor.constraint(equalTo: view.widthAnchor),
            welcomeView.heightAnchor.constraint(equalTo: view.heightAnchor),
            permissionsView.widthAnchor.constraint(equalTo: view.widthAnchor),
            permissionsView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])

        let permissionsInfoCopy = NSMutableAttributedString()

        let permissionsInfoCopyParagraphStyle = NSMutableParagraphStyle()
        permissionsInfoCopyParagraphStyle.lineHeightMultiple = 1.2
        permissionsInfoCopyParagraphStyle.alignment = .center

        permissionsInfoCopy.append(NSAttributedString(string: "Zoom, Enhance! needs access to your camera roll otherwise it's literally completely useless.", attributes: [
            NSFontAttributeName: Font.GTWalsheimPro(size: 22),
            NSParagraphStyleAttributeName: permissionsInfoCopyParagraphStyle
        ]))

        permissionsInfoCopy.addAttributes([
            NSFontAttributeName: Font.GTWalsheimProBoldOblique(size: 22)
        ], range: NSRange(location: 0, length: 15))

        permissionsInfo.attributedText = permissionsInfoCopy
    }


    // MARK: - Actions

    @IBAction private func permissionsButtonTouchUpInside(sender: UIButton) {
        PHPhotoLibrary.requestAuthorization({ status in
            print(status)
        })
    }
}

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

    @IBOutlet private var scrollView: UIScrollView!

    @IBOutlet private var stackView: UIStackView!

    @IBOutlet private var welcomeView: UIView!

    @IBOutlet private var permissionsView: UIView!

    @IBOutlet private var permissionsInfo: UILabel!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }


    // MARK: - Initializers

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        unimplemented()
    }


    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(advancePage))
        welcomeView.addGestureRecognizer(tapGestureRecognizer)

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

        let explanation = NSLocalizedString("onboarding.permissionsExplanation", comment: "")
        permissionsInfoCopy.append(NSAttributedString(string: explanation, attributes: [
            NSFontAttributeName: Font.GTWalsheimPro(size: 22),
            NSParagraphStyleAttributeName: permissionsInfoCopyParagraphStyle
        ]))

        permissionsInfoCopy.addAttributes([
            NSFontAttributeName: Font.GTWalsheimProBoldOblique(size: 22)
        ], range: (explanation as NSString).range(of: "Zoom, Enhance!"))

        permissionsInfo.attributedText = permissionsInfoCopy
    }


    // MARK: - Actions

    @IBAction private func advancePage(sender: UIGestureRecognizer) {
        if sender.state == .ended {
            scrollView.scrollRectToVisible(permissionsView.frame, animated: true)
        }
    }

    @IBAction private func permissionsButtonTouchUpInside(sender: UIButton) {
        PHPhotoLibrary.requestAuthorization({ [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        })
    }
}

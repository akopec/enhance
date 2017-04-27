//
//  PermissionDeniedEmptyView.swift
//  Enhance
//
//  Created by Jonathan Baker on 4/27/17.
//
//

import UIKit

final class PermissionDeniedEmptyView: UIView {

    // MARK: - Properties

    private let imageView = UIImageView(image: UIImage(named: "icon-film"))

    private let textLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        paragraphStyle.alignment = .center
        let attributedInfo = NSAttributedString(string: NSLocalizedString("photos.permissionDenied.info", comment: ""), attributes: [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: Font.GTWalsheimPro(size: 18),
            NSParagraphStyleAttributeName: paragraphStyle
            ])
        view.attributedText = attributedInfo
        return view
    }()

    private let fixItButton: UIButton = {
        let view = UIButton(type: .system)
        view.backgroundColor = Color.teal()
        let attributedTitle = NSAttributedString(string: NSLocalizedString("photos.permissionDenied.fixIt", comment: ""), attributes: [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: Font.GTWalsheimPro(size: 18)
        ])
        view.setAttributedTitle(attributedTitle, for: .normal)
        view.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()


    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }


    // MARK: - Private

    private func setup() {
        let stackView = UIStackView(arrangedSubviews: [imageView, textLabel, fixItButton])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 48),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -48),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, constant: -48),
            fixItButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        fixItButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
    }

    @objc private func openSettings(sender: UIButton) {
        if let url = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

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

    private let imageView = UIImageView()

    private let textLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.font = Font.GTWalsheimPro(size: 18)
        view.textAlignment = .center
        view.numberOfLines = 0
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
        view.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        view.layer.cornerRadius = 8
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
        imageView.image = UIImage(named: "icon-film")

        textLabel.text = NSLocalizedString("photos.permissionDenied.info", comment: "")

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
            stackView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, constant: -48)
        ])

        fixItButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
    }

    @objc private func openSettings(sender: UIButton) {
        if let url = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

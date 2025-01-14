//
//  WelcomeViewController.swift
//  Enhance
//
//  Created by Jonathan Baker on 1/10/25.
//

import UIKit
import PhotosUI

class WelcomeViewController: UIViewController, PHPickerViewControllerDelegate {

    // MARK: Properties

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Zoom,\nEnhance!"
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 56, weight: .black)
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 24, weight: .heavy)

        let style = NSMutableParagraphStyle()
        style.lineSpacing = 12

        let text = NSMutableAttributedString(string: "Zoom in on stuff.\nMake a GIF of it.\nBurn your friends.")
        text.addAttribute(.paragraphStyle, value: style, range: NSMakeRange(0, text.length))

        label.attributedText = text

        return label
    }()

    private lazy var actionButton: UIButton = {
        var text = AttributedString("Choose Photo")
        text.font = UIFont.systemFont(ofSize: 20, weight: .black)

        var config = UIButton.Configuration.filled()

        config.attributedTitle = text
        config.imagePadding = 8
        config.imagePlacement = .trailing
        config.image = UIImage(systemName: "photo")

        let button = UIButton(configuration: config)
        button.addTarget(self,action: #selector(next(sender:)),for: .touchUpInside)

        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "ZoomEnhanceTeal")

        let stackView = UIStackView(arrangedSubviews: [
            titleLabel, subtitleLabel, actionButton
        ])
        stackView.spacing = 32
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setToolbarHidden(true, animated: animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    @objc private func next(sender: UIButton) {
        var pickerConfig = PHPickerConfiguration()
        pickerConfig.filter = .images
        pickerConfig.selectionLimit = 1

        let picker = PHPickerViewController(configuration: pickerConfig)
        picker.delegate = self

        present(picker, animated: true)
    }

    private func presentImageEnhancement(image: UIImage) {
        let controller = EnhanceViewController(image: image)
        navigationController?.pushViewController(controller, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let imageProvider = results.first?.itemProvider else { return }

        if imageProvider.canLoadObject(ofClass: UIImage.self) {
            imageProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                guard let image = image as? UIImage else { return }
                DispatchQueue.main.async {
                    self?.presentImageEnhancement(image: image)
                }
            }
        }
    }
}

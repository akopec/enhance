//
//  EnhanceViewController.swift
//  Enhance
//
//  Created by Jonathan Baker on 1/10/25.
//

import UIKit
import CoreImage

class EnhanceViewController: UIViewController, UIScrollViewDelegate {

    private let imageSize: CGSize

    private var aspectRatio: CGFloat {
        imageSize.height / imageSize.width
    }

    private let imageView: UIImageView

    private lazy var overlayView: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.isUserInteractionEnabled = false
        return overlay
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.bouncesZoom = true
        scrollView.bouncesVertically = true
        scrollView.bouncesHorizontally = true
        scrollView.maximumZoomScale = 1
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var saveButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
    }()

    init(image: UIImage) {
        imageSize = image.size
        imageView = UIImageView(image: image)

        super.init(nibName: nil, bundle: nil)

        title = "Enhance"
        toolbarItems = [
            UIBarButtonItem.flexibleSpace(),
            saveButton,
            UIBarButtonItem.flexibleSpace(),
        ]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "ZoomEnhanceTeal")

        scrollView.contentSize = imageSize

        view.addSubview(scrollView)
        view.addSubview(overlayView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        scrollView.addSubview(imageView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        recalculateOverlay()
        recalcuateScrollView()
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let isZoomed = scrollView.zoomScale > scrollView.minimumZoomScale
        saveButton.isEnabled = isZoomed
        scrollView.contentAlignmentPoint = isZoomed ? .zero : CGPoint(x: 0.5, y: 0.5)
    }

    private func recalcuateScrollView() {
        let minimumZoom = scrollView.frame.width / imageSize.width

        scrollView.minimumZoomScale = minimumZoom
        scrollView.zoomScale = minimumZoom
    }

    private func recalculateOverlay() {
        let mask = CAShapeLayer()
        mask.fillRule = .evenOdd
        mask.frame = overlayView.bounds


        let path = UIBezierPath(rect: overlayView.bounds)
        path.append(UIBezierPath(rect: cropRect()))
        mask.path = path.cgPath

        overlayView.layer.mask = mask
    }

    private func cropRect() -> CGRect {
        let height = overlayView.bounds.width * aspectRatio

        return CGRect(
            x: 0,
            y: overlayView.bounds.midY - (height / 2.0),
            width: overlayView.bounds.width,
            height: height
        )
    }

    @objc private func save(sender: UIBarButtonItem) {
        let scale = 1 / scrollView.zoomScale

        let center = CGPoint(
            x: scrollView.bounds.midX * scale,
            y: scrollView.bounds.midY * scale
        )

        print(scale, center)

//        let rect = CGRect(
//            x: scrollView.contentOffset.x * scale,
//            y: scrollView.contentOffset.y * scale,
//            width: scrollView.frame.width * scale,
//            height: scrollView.frame.height * scale
//        )
//
//        let crop = cropRect()
//
//        guard let cropped = imageView.image?.cgImage?.cropping(to: rect) else {
//            fatalError("ugh")
//        }
//
//        let url = FileManager.default.temporaryDirectory.appendingPathComponent("cropped.jpg")
//
//        let context = CIContext()
//        let image = CIImage(cgImage: cropped)
//        try! context.writeJPEGRepresentation(of: image, to: url, colorSpace: image.colorSpace!)
//
//        print(url)
////        navigationController?.pushViewController(ResultViewController(), animated: true)
    }
}

//
//  GIFRenderer.swift
//  Enhance
//
//  Created by Jonathan Baker on 5/11/17.
//
//

import Result
import ImageIO
import ReactiveSwift
import MobileCoreServices

final class GIFRenderer {

    static func render(source: UIImage, frames: [CGRect]) -> SignalProducer<URL, AnyError> {
        return SignalProducer({ observer, _ in
            guard let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                observer.send(error: AnyError(URLError(.unknown)))
                return
            }

            let url = directory.appendingPathComponent("\(UUID().uuidString).gif")

            guard let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypeGIF, frames.count, nil) else {
                observer.send(error: AnyError(URLError(.unknown)))
                return
            }

            let gifFileProperties = [
                kCGImagePropertyGIFDictionary as String: [
                    kCGImagePropertyGIFLoopCount as String: 0
                ]
            ]

            let gifFrameProperties = [
                kCGImagePropertyGIFDictionary as String: [
                    kCGImagePropertyGIFDelayTime as String: 0.5
                ]
            ]

            CGImageDestinationSetProperties(destination, gifFileProperties as CFDictionary)

            guard let cgImage = source.cgImage else {
                observer.send(error: AnyError(URLError(.unknown)))
                return
            }

            let aspectRatio = source.size.height / source.size.width

            let gifRect = CGRect(x: 0, y: 0, width: 320, height: 320.0 * aspectRatio).integral

            let format = UIGraphicsImageRendererFormat()
            format.scale = 1

            let imageRenderer = UIGraphicsImageRenderer(bounds: gifRect, format: format)

            for frame in frames {
                guard let cropped = cgImage.cropping(to: frame).map(UIImage.init) else {
                    observer.send(error: AnyError(URLError(.unknown)))
                    return
                }

                guard
                    let rendered = imageRenderer.image(actions: { context in
                        cropped.draw(in: gifRect)
                        drawWatermark(in: gifRect)
                    }).cgImage
                else {
                    observer.send(error: AnyError(URLError(.unknown)))
                    return
                }

                CGImageDestinationAddImage(destination, rendered, gifFrameProperties as CFDictionary)
            }

            guard CGImageDestinationFinalize(destination) else {
                observer.send(error: AnyError(URLError(.unknown)))
                return
            }

            observer.send(value: url)
            observer.sendCompleted()
        })
    }

    private static func drawWatermark(in rect: CGRect) {
        let watermark: NSString = "Zoom, Enhance!"

        let shadow = NSShadow()
        shadow.shadowBlurRadius = 0.3
        shadow.shadowColor = UIColor.black.withAlphaComponent(0.45)
        shadow.shadowOffset = CGSize(width: 0, height: 0.5)

        let attributes = [
            NSFontAttributeName: Font.GTWalsheimProBoldOblique(size: 13),
            NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.42),
            NSShadowAttributeName: shadow
        ]

        let size = watermark.size(attributes: attributes)

        let origin = CGPoint(x: rect.width - size.width - 8, y: rect.height - size.height - 8)

        watermark.draw(in: CGRect(origin: origin, size: size), withAttributes: attributes)
    }
}

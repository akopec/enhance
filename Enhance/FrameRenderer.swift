//
//  FrameRenderer.swift
//  Enhance
//
//  Created by Jonathan Baker on 6/8/17.
//
//

import Result
import ImageIO
import ReactiveSwift

final class FrameRenderer {

    static func render(source: UIImage, frames: [CGRect]) -> SignalProducer<[CGImage], AnyError> {
        return SignalProducer<CGImage, AnyError>({ observer, _ in
            guard let cgImage = source.cgImage else {
                observer.send(error: AnyError(URLError(.unknown)))
                return
            }

            let aspectRatio = source.size.height / source.size.width

            let renderFrame = CGRect(x: 0, y: 0, width: 320, height: 320.0 * aspectRatio).integral

            let format = UIGraphicsImageRendererFormat()
            format.scale = 1

            let imageRenderer = UIGraphicsImageRenderer(bounds: renderFrame, format: format)

            for frame in frames {
                guard let cropped = cgImage.cropping(to: frame).map(UIImage.init) else {
                    observer.send(error: AnyError(URLError(.unknown)))
                    return
                }

                guard
                    let rendered = imageRenderer.image(actions: { context in
                        cropped.draw(in: renderFrame)
                        drawWatermark(in: renderFrame)
                    }).cgImage
                else {
                    observer.send(error: AnyError(URLError(.unknown)))
                    return
                }

                observer.send(value: rendered)
            }

            observer.sendCompleted()
        }).collect()
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

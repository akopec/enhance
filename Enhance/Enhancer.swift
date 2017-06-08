//
//  Enhancer.swift
//  Enhance
//
//  Created by Jonathan Baker on 4/27/17.
//
//

import Photos
import Result
import ReactiveSwift

final class Enhancer {

    private init() {}

    static func render(asset: PHAsset, cropRect: CGRect, options: Options = Options()) -> SignalProducer<URL, AnyError> {
        return PHImageManager.default().reactive
            .requestImageData(for: asset)
            .attemptMap({ data, _ in
                return Result(UIImage(data: data), failWith: AnyError(URLError(.unknown)))
            })
            .map({ (image: UIImage) -> (UIImage, [CGRect]) in
                let startRect = CGRect(origin: .zero, size: image.size)
                let frames = extrapolate(startRect: startRect, finalRect: cropRect, frameCount: options.frameCount)
                return (image, frames)
            })
            .flatMap(.latest, transform: FrameRenderer.render)
            .flatMap(.latest, transform: GIFEncoder.encode)
    }

    private static func extrapolate(startRect: CGRect, finalRect: CGRect, frameCount: Int) -> [CGRect] {
        var frames = [CGRect]()

        let dX = finalRect.origin.x - startRect.origin.x
        let dY = finalRect.origin.y - startRect.origin.y
        let dW = startRect.size.width - finalRect.size.width
        let dH = startRect.size.height - finalRect.size.height

        for frame in 0..<frameCount {
            let progress = (1.0 / CGFloat(frameCount - 1)) * CGFloat(frame)

            let xPrime = startRect.origin.x + (dX * progress)
            let yPrime = startRect.origin.y + (dY * progress)
            let wPrime = startRect.size.width - (dW * progress)
            let hPrime = startRect.size.height - (dH * progress)

            frames.append(CGRect(x: xPrime, y: yPrime, width: wPrime, height: hPrime))
        }
        
        return frames
    }
}

extension Enhancer {
    struct Options {
        var frameCount: Int = 10

        var frameDuration: TimeInterval = 0.5
    }
}

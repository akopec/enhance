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

    static func render(asset: PHAsset, cropRect: CGRect, options: Options = Options()) {
        let foo: SignalProducer<[UIImage], AnyError> = PHImageManager.default().reactive
            .requestImageData(for: asset)
            .attemptMap({ data, _ in
                return Result(UIImage(data: data), failWith: AnyError(URLError(.unknown)))
            })
            .map({ image in
                slice(image: image, finalRect: cropRect, options: options)
            })
    }

    private static func slice(image: UIImage, finalRect: CGRect, options: Options) -> [UIImage] {
        var slices = [UIImage]()

        let dX = finalRect.origin.x
        let dY = finalRect.origin.y
        let dW = image.size.width - finalRect.width
        let dH = image.size.height - finalRect.height

        for i in 2..<options.frameCount {
            
        }

        return []
    }
}

extension Enhancer {
    struct Options {
        var frameCount: Int = 10

        var frameDuration: TimeInterval = 0.5
    }
}

//
//  GIFEncoder.swift
//  Enhance
//
//  Created by Jonathan Baker on 6/8/17.
//
//

import Result
import ImageIO
import ReactiveSwift
import MobileCoreServices

final class GIFEncoder {

    static func encode(frames: [CGImage]) -> SignalProducer<URL, AnyError> {
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

            for frame in frames {
                CGImageDestinationAddImage(destination, frame, gifFrameProperties as CFDictionary)
            }

            guard CGImageDestinationFinalize(destination) else {
                observer.send(error: AnyError(URLError(.unknown)))
                return
            }

            observer.send(value: url)
            observer.sendCompleted()
        })
    }
}


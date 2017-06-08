//
//  MOVEncoder.swift
//  Enhance
//
//  Created by Jonathan Baker on 6/8/17.
//
//

import ImageIO
import AVFoundation
import ReactiveSwift
import Result

final class MOVEncoder {

    static func encode(frames: [CGImage]) -> SignalProducer<URL, AnyError> {
        return SignalProducer({ observer, _ in
            guard let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                observer.send(error: AnyError(URLError(.unknown)))
                return
            }

            let url = directory.appendingPathComponent("\(UUID().uuidString).mov")

            do {
                let assetWriter = try AVAssetWriter(url: url, fileType: AVFileTypeQuickTimeMovie)

                let width = Int(frames[0].width)
                let height = Int(frames[0].height)

                let input = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: [
                    AVVideoCodecKey: AVVideoCodecH264,
                    AVVideoWidthKey: width,
                    AVVideoHeightKey: height
                ])

                assetWriter.add(input)

                let bufferAdapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: [
                    kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB)
                ])

                if assetWriter.startWriting() {
                    var frames = ArraySlice(frames)

                    var frameTime = kCMTimeZero

                    assetWriter.startSession(atSourceTime: frameTime)

                    input.requestMediaDataWhenReady(on: DispatchQueue(label: "com.hodsdon.Enhance.MOVEncoder"), using: {
                        while input.isReadyForMoreMediaData {
                            if let frame = frames.popFirst(), let pixelBuffer = frame.pixelBuffer {
                                bufferAdapter.append(pixelBuffer, withPresentationTime: frameTime)
                                frameTime = CMTimeAdd(frameTime, CMTime(value: 1, timescale: 6))
                            }
                            else {
                                input.markAsFinished()
                                assetWriter.finishWriting(completionHandler: { 
                                    observer.send(value: url)
                                    observer.sendCompleted()
                                })
                                break
                            }
                        }
                    })
                }
            }
            catch {
                observer.send(error: AnyError(error))
            }
        })
    }
}

extension CGImage {
    fileprivate var pixelBuffer: CVPixelBuffer? {
        let options = [
            kCVPixelBufferCGImageCompatibilityKey as String: NSNumber(value: true),
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: NSNumber(value: true)
        ]

        var bufferRef: CVPixelBuffer?
        CVPixelBufferCreate(nil, width, height, kCVPixelFormatType_32ARGB, options as CFDictionary, &bufferRef)

        guard let buffer = bufferRef else { return nil }

        CVPixelBufferLockBaseAddress(buffer, [])

        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 4 * width,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        else {
            return nil
        }

        context.concatenate(.identity)
        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))

        CVPixelBufferUnlockBaseAddress(buffer, [])

        return buffer
    }
}

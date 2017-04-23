//
//  Reactive+PHImageManager.swift
//  Enhance
//
//  Created by Jonathan Baker on 4/23/17.
//
//

import Photos
import Result
import ReactiveSwift

extension Reactive where Base: PHImageManager {
    func requestImage(for asset: PHAsset, targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions? = nil) -> SignalProducer<UIImage, AnyError> {
        return SignalProducer({ observer, disposable in
            let id = self.base.requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options, resultHandler: { image, info in
                if let image = image {
                    observer.send(value: image)
                    if !(info?[PHImageResultIsDegradedKey] as? Bool ?? false) {
                        observer.sendCompleted()
                    }
                }
                else if let error = info?[PHImageErrorKey] as? NSError {
                    observer.send(error: AnyError(error))
                }
            })

            disposable.add({
                self.base.cancelImageRequest(id)
            })
        })
    }

    func requestImageData(for asset: PHAsset, options: PHImageRequestOptions? = nil) -> SignalProducer<(Data, UIImageOrientation), AnyError> {
        return SignalProducer({ observer, disposable in
            let id = self.base.requestImageData(for: asset, options: options, resultHandler: { data, uti, orientation, info in
                if let data = data {
                    observer.send(value: (data, orientation))
                    observer.sendCompleted()
                }
                else if let error = info?[PHImageErrorKey] as? NSError {
                    observer.send(error: AnyError(error))
                }
            })

            disposable.add({
                self.base.cancelImageRequest(id)
            })
        })
    }
}

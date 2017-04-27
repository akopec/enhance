//
//  Reactive+PHAsset.swift
//  Enhance
//
//  Created by Jonathan Baker on 4/27/17.
//
//

import Photos
import Result
import ReactiveSwift

extension Reactive where Base: PHAsset {
    static func fetchAssets(with mediaType: PHAssetMediaType, options: PHFetchOptions? = nil) -> SignalProducer<PHFetchResult<PHAsset>, NoError> {
        return SignalProducer({ observer, _ in
            observer.send(value: Base.fetchAssets(with: mediaType, options: options))
            observer.sendCompleted()
        })
    }
}

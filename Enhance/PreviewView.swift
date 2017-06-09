//
//  PreviewView.swift
//  Enhance
//
//  Created by Jonathan Baker on 6/9/17.
//
//

import UIKit
import AVFoundation

final class PreviewView: UIView {

    // MARK: - Properties

    var videoURL: URL? {
        didSet {
            videoURLDidChange()
        }
    }

    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    fileprivate var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    fileprivate let player = AVQueuePlayer(items: [])

    fileprivate var looper: AVPlayerLooper?


    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }


    // MARK: - Private

    private func setup() {
        playerLayer.player = player
    }

    private func videoURLDidChange() {
        player.pause()
        looper?.disableLooping()
        looper = videoURL.map(AVPlayerItem.init).map({
            AVPlayerLooper(player: player, templateItem: $0)
        })
        player.play()
    }
}

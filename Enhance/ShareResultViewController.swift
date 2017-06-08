//
//  ShareResultViewController.swift
//  Enhance
//
//  Created by Jonathan Baker on 6/8/17.
//
//

import UIKit
import QuickLook

final class ShareResultViewController: QLPreviewController, QLPreviewControllerDataSource {

    let subjectURL: URL

    init(subjectURL: URL) {
        self.subjectURL = subjectURL
        super.init(nibName: nil, bundle: nil)
        self.dataSource = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return PreviewItem(url: subjectURL)
    }

    private class PreviewItem: NSObject, QLPreviewItem {
        var previewItemURL: URL?

        var previewItemTitle: String? {
            return "Share"
        }

        init(url: URL) {
            previewItemURL = url
        }
    }
}

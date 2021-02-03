//
//  BackgroundModel+BeautySelectionModelProtocol.swift
//  Glip
//
//  Created by Jamie Yao on 2020/9/1.
//  Copyright © 2020 RingCentral. All rights reserved.
//

import Foundation

import Foundation
import SDWebImage

extension RcvXVbgModel {
    static var currentImageCount: Int = 0
    static var maximumCustomImageCount: Int = 7

    static var isLessThanMaximumCustomImageCount: Bool {
        return currentImageCount < maximumCustomImageCount
    }
}

extension RcvXVbgModel: SelfPreviewBeautySelectionModelProtocol {
    var backgroundImage: UIImage? {
        switch type {
        case .EFFECT:
            return UIImage(named: "bg_rcv_beauty_background_blur_normal")
        case .DEFAULT, .CUSTOM:
            let cacheKey = thumbnailCacheKey()
            if let thumbnail = SDImageCache.shared().imageFromMemoryCache(forKey: cacheKey) {
                return thumbnail
            }

            let thumbnailURL = URL(fileURLWithPath: thumbnailPath)
            if let imageData = try? Data(contentsOf: thumbnailURL) {
                let thumbnail = UIImage(data: imageData)
                SDImageCache.shared().store(thumbnail, forKey: cacheKey, toDisk: false, completion: nil)
                return thumbnail
            } else {
                return nil
            }
        case .NONE:
            return UIImage(named: "bg_rcv_beauty_background_none")
        case .MORE:
            if RcvXVbgModel.isLessThanMaximumCustomImageCount {
                return UIImage(named: "bg_rcv_beauty_background_more")
            } else {
                return UIImage(named: "bg_rcv_beauty_background_more_disabled")
            }
        @unknown default:
            return nil
        }
    }

    var textColor: UIColor? {
        return UIColor.white
    }

    var titleFont: UIFont? {
        return UIFont.systemFont(ofSize: 16.0, weight: .medium)
    }

    var title: String? {
        switch type {
        case .EFFECT:
            return self.effectName
        case .NONE:
            return "OFF"
        case .DEFAULT, .CUSTOM, .MORE:
            return nil
        @unknown default:
            return nil
        }
    }

    var selectable: Bool {
        return type != .MORE
    }

    var removable: Bool {
        return type == .CUSTOM
    }

    var isMore: Bool {
        return type == .MORE
    }

    var identifier: String {
        return "Type\(type.rawValue)-Index\(index)"
    }

    var accesibilityString: String {
        switch type {
        case .NONE:
            return "Turn off"
        case .EFFECT:
            return self.effectName
        case .MORE:
            return "Add customized image"
        default:
            return "Apply"
        }
    }

    var analysisTypeString: String? {
        switch type {
        case .NONE:
            return "OFF"
        case .EFFECT:
            return self.effectName
        case .DEFAULT:
            return "Preload image \(index)"
        case .CUSTOM:
            return "Myimage"
        default:
            return nil
        }
    }
}

extension RcvXVbgModel {
    func thumbnailCacheKey() -> String {
        let thumbnailURL = URL(fileURLWithPath: thumbnailPath)
        return "rcv-beauty-background-thumbnial-\(thumbnailURL.lastPathComponent)"
    }

    func clearThumbnailCache() {
        let cacheKey = thumbnailCacheKey()
        SDImageCache.shared().removeImage(forKey: cacheKey, fromDisk: false, withCompletion: nil)
    }
}

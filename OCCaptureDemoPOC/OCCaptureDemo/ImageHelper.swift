//
//  ImageHelper.swift
//  OCCaptureDemo
//
//  Created by rcadmin on 2020/12/29.
//

import Foundation
import VideoToolbox
import UIKit

class ImageHelper: NSObject {
    @objc public static func imageWith(pixelBuffer: CVPixelBuffer) -> UIImage? {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        guard let cgImageSafe = cgImage else {
            return nil
        }

        let image = UIImage(cgImage: cgImageSafe, scale: 1.0, orientation: .up)
        return image
    }
    
    @objc public static func buffer(from image: UIImage) -> CVPixelBuffer? {
      let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
      var pixelBuffer : CVPixelBuffer?
      let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
      guard (status == kCVReturnSuccess) else {
        return nil
      }

      CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
      let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

      let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
      let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

      context?.translateBy(x: 0, y: image.size.height)
      context?.scaleBy(x: 1.0, y: -1.0)

      UIGraphicsPushContext(context!)
      image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
      UIGraphicsPopContext()
      CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

      return pixelBuffer
    }
    
    @objc public static func getCVPixelBuffer(_ image: CGImage) -> CVPixelBuffer? {
            let imageWidth = Int(image.width)
            let imageHeight = Int(image.height)

            let attributes : [NSObject:AnyObject] = [
                kCVPixelBufferCGImageCompatibilityKey : true as AnyObject,
                kCVPixelBufferCGBitmapContextCompatibilityKey : true as AnyObject
            ]

            var pxbuffer: CVPixelBuffer? = nil
            CVPixelBufferCreate(kCFAllocatorDefault,
                                imageWidth,
                                imageHeight,
                                kCVPixelFormatType_32ARGB,
                                attributes as CFDictionary?,
                                &pxbuffer)

            if let _pxbuffer = pxbuffer {
                let flags = CVPixelBufferLockFlags(rawValue: 0)
                CVPixelBufferLockBaseAddress(_pxbuffer, flags)
                let pxdata = CVPixelBufferGetBaseAddress(_pxbuffer)

                let rgbColorSpace = CGColorSpaceCreateDeviceRGB();
                let context = CGContext(data: pxdata,
                                        width: imageWidth,
                                        height: imageHeight,
                                        bitsPerComponent: 8,
                                        bytesPerRow: CVPixelBufferGetBytesPerRow(_pxbuffer),
                                        space: rgbColorSpace,
                                        bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)

                if let _context = context {
                    _context.draw(image, in: CGRect.init(x: 0, y: 0, width: imageWidth, height: imageHeight))
                }
                else {
                    CVPixelBufferUnlockBaseAddress(_pxbuffer, flags);
                    return nil
                }

                CVPixelBufferUnlockBaseAddress(_pxbuffer, flags);
                return _pxbuffer;
            }

            return nil
        }
}

#if canImport(UIKit)

import UIKit
import VideoToolbox

extension UIImage {
  /**
    Resizes the image to width x height and converts it to an RGB CVPixelBuffer.
  */
    @objc public func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
    return pixelBuffer(width: width, height: height,
                       pixelFormatType: kCVPixelFormatType_32ARGB,
                       colorSpace: CGColorSpaceCreateDeviceRGB(),
                       alphaInfo: .noneSkipFirst)
  }

  /**
    Resizes the image to width x height and converts it to a grayscale CVPixelBuffer.
  */
    @objc public func pixelBufferGray(width: Int, height: Int) -> CVPixelBuffer? {
    return pixelBuffer(width: width, height: height,
                       pixelFormatType: kCVPixelFormatType_OneComponent8,
                       colorSpace: CGColorSpaceCreateDeviceGray(),
                       alphaInfo: .none)
  }

    @objc func pixelBuffer(width: Int, height: Int, pixelFormatType: OSType,
                   colorSpace: CGColorSpace, alphaInfo: CGImageAlphaInfo) -> CVPixelBuffer? {
    var maybePixelBuffer: CVPixelBuffer?
    let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                 kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue]
    let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                     width,
                                     height,
                                     pixelFormatType,
                                     attrs as CFDictionary,
                                     &maybePixelBuffer)

    guard status == kCVReturnSuccess, let pixelBuffer = maybePixelBuffer else {
      return nil
    }

    let flags = CVPixelBufferLockFlags(rawValue: 0)
    guard kCVReturnSuccess == CVPixelBufferLockBaseAddress(pixelBuffer, flags) else {
      return nil
    }
    defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, flags) }

    guard let context = CGContext(data: CVPixelBufferGetBaseAddress(pixelBuffer),
                                  width: width,
                                  height: height,
                                  bitsPerComponent: 8,
                                  bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                                  space: colorSpace,
                                  bitmapInfo: alphaInfo.rawValue)
    else {
      return nil
    }
        
    UIGraphicsPushContext(context)
    context.translateBy(x: 0, y: CGFloat(height))
    context.scaleBy(x: 1, y: -1)
    self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
    UIGraphicsPopContext()

    return pixelBuffer
  }
    
    // will crash
    @objc func pixelBuffer2(width: Int, height: Int, pixelFormatType: OSType,
                   colorSpace: CGColorSpace, alphaInfo: CGImageAlphaInfo) -> CVPixelBuffer? {
    var maybePixelBuffer: CVPixelBuffer?
    let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                 kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue]
    let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                     width,
                                     height,
                                     pixelFormatType,
                                     attrs as CFDictionary,
                                     &maybePixelBuffer)

    guard status == kCVReturnSuccess, let pixelBuffer = maybePixelBuffer else {
      return nil
    }

    let flags = CVPixelBufferLockFlags(rawValue: 0)
    guard kCVReturnSuccess == CVPixelBufferLockBaseAddress(pixelBuffer, flags) else {
      return nil
    }
    defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, flags) }

    guard let context = CGContext(data: CVPixelBufferGetBaseAddress(pixelBuffer),
                                  width: width,
                                  height: height,
                                  bitsPerComponent: 8,
                                  bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                                  space: colorSpace,
                                  bitmapInfo: alphaInfo.rawValue)
    else {
      return nil
    }
        
    guard let cgImage = self.cgImage else {
        return nil
    }
    
    let ciContext = CIContext(cgContext: context, options: nil)
    ciContext.render(CIImage(cgImage: cgImage), to: pixelBuffer)

    return pixelBuffer
  }
}

#endif

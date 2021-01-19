//
//  ReSizeImageHelper.swift
//  OCCaptureDemo
//
//  Created by rcadmin on 2021/1/11.
//

import UIKit
import CoreImage
import ImageIO
import Accelerate.vImage

class ReSizeImageHelper: NSObject {

    @objc public static let sharedContext = CIContext(options: [.useSoftwareRenderer : false])

    // Technique #1
    @objc public static func resizedImage1(image: UIImage, for size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    // Technique #2
    @objc public static func resizedImage2(image: CGImage, for size: CGSize) -> UIImage? {
        let context = CGContext(data: nil,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: image.bitsPerComponent,
                                bytesPerRow: image.bytesPerRow,
                                space: image.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
                                bitmapInfo: image.bitmapInfo.rawValue)
        context?.interpolationQuality = .high
        context?.draw(image, in: CGRect(origin: .zero, size: size))

        guard let scaledImage = context?.makeImage() else { return nil }

        return UIImage(cgImage: scaledImage)
    }
    
    // Technique #3
    @objc public static func resizedImage3(image: UIImage, for size: CGSize) -> UIImage? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height)
        ]
        
        guard let imageData = image.pngData(), let imageSource = CGImageSourceCreateWithData(imageData as CFData, options as CFDictionary),
            let image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary)
        else {
            return nil
        }

        return UIImage(cgImage: image)
    }
    
    // Technique #4
    @objc public static func resizedImage4(image: CIImage, scale: CGFloat, aspectRatio: CGFloat) -> UIImage? {
        let filter = CIFilter(name: "CILanczosScaleTransform")
        filter?.setValue(image, forKey: kCIInputImageKey)
        filter?.setValue(scale, forKey: kCIInputScaleKey)
        filter?.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)

        guard let outputCIImage = filter?.outputImage,
            let outputCGImage = sharedContext.createCGImage(outputCIImage,
                                                            from: outputCIImage.extent)
        else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    // Technique #5
    @objc public static func resizedImage5(image: UIImage, for size: CGSize) -> UIImage? {
        
        guard let cgImage = image.cgImage else {
            return nil
        }

        // Define the image format
        var format = vImage_CGImageFormat(bitsPerComponent: 8,
                                          bitsPerPixel: 32,
                                          colorSpace: nil,
                                          bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue),
                                          version: 0,
                                          decode: nil,
                                          renderingIntent: .defaultIntent)

        var error: vImage_Error

        // Create and initialize the source buffer
        var sourceBuffer = vImage_Buffer()
        defer { sourceBuffer.data.deallocate() }
        error = vImageBuffer_InitWithCGImage(&sourceBuffer,
                                             &format,
                                             nil,
                                             cgImage,
                                             vImage_Flags(kvImageNoFlags))
        guard error == kvImageNoError else { return nil }

        // Create and initialize the destination buffer
        var destinationBuffer = vImage_Buffer()
        error = vImageBuffer_Init(&destinationBuffer,
                                  vImagePixelCount(size.height),
                                  vImagePixelCount(size.width),
                                  format.bitsPerPixel,
                                  vImage_Flags(kvImageNoFlags))
        guard error == kvImageNoError else { return nil }

        // Scale the image
        error = vImageScale_ARGB8888(&sourceBuffer,
                                     &destinationBuffer,
                                     nil,
                                     vImage_Flags(kvImageHighQualityResampling))
        guard error == kvImageNoError else { return nil }

        // Create a CGImage from the destination buffer
        guard let resizedImage =
            vImageCreateCGImageFromBuffer(&destinationBuffer,
                                          &format,
                                          nil,
                                          nil,
                                          vImage_Flags(kvImageNoAllocate),
                                          &error)?.takeRetainedValue(),
            error == kvImageNoError
        else {
            return nil
        }

        return UIImage(cgImage: resizedImage)
    }
    
    //UIKit
    @objc public static func resizedImage6(image: UIImage, for size: CGSize) -> UIImage? {
        /**
         创建一个图片类型的上下文。调用UIGraphicsBeginImageContextWithOptions函数就可获得用来处理图片的图形上下文。利用该上下文，你就可以在其上进行绘图，并生成图片
         
         size：表示所要创建的图片的尺寸
         opaque：表示这个图层是否完全透明，如果图形完全不用透明最好设置为YES以优化位图的存储，这样可以让图层在渲染的时候效率更高
         scale：指定生成图片的缩放因子，这个缩放因子与UIImage的scale属性所指的含义是一致的。传入0则表示让图片的缩放因子根据屏幕的分辨率而变化，所以我们得到的图片不管是在单分辨率还是视网膜屏上看起来都会很好
         */
        UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.main.scale)
        image.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}



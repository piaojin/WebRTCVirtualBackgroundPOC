//
//  RcvCVPixelBufferUtils.h
//  OCCaptureDemo
//
//  Created by rcadmin on 2021/1/6.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreImage/CoreImage.h>
#import <UIKit/UIKit.h>

@interface RcvCVPixelBufferScaler : NSObject

+(CGFloat)scaleFactorWidth:(size_t)width andHeight:(size_t)height;

-(CVPixelBufferRef)scalePixelBuffer:(CVPixelBufferRef)pixelBuffer withFactorX:(CGFloat)factorX factorY:(CGFloat)factorY;

-(CVPixelBufferRef)scalePixelBuffer:(CVPixelBufferRef)pixelBuffer withFactor:(CGFloat)factor;

-(CVPixelBufferRef)scalePixelBuffer:(CVPixelBufferRef)pixelBuffer toSize:(CGSize)size;

@end

@interface RcvCVPixelBufferConverter : NSObject

// 1
-(CVPixelBufferRef)createPixelBufferFromPoolWithCIImage:(CIImage *)image inContext:(CIContext *)context size:(CGSize)size;

// 2
- (CVPixelBufferRef)createPixelBufferWithCIImage:(CIImage *)image inContext:(CIContext *)context size:(CGSize)size;

// 3
-(CVPixelBufferRef)createPixelBufferWithCGImageViavImage:(CGImageRef)image;

// 4
-(CVPixelBufferRef)createPixelBufferFromPoolWithCGImage:(CGImageRef)image;

// 5
- (CVPixelBufferRef)createPixelBufferWithImage: (UIImage *)image;

// 6
- (CVPixelBufferRef)createPixelBufferWithCGImage:(CGImageRef)image;

@end



//
//  RcvCVPixelBufferUtils.m
//  OCCaptureDemo
//
//  Created by rcadmin on 2021/1/6.
//

#import "RcvCVPixelBufferUtils.h"
#import <Accelerate/Accelerate.h>

#define FORMAT_TYPE kCVPixelFormatType_420YpCbCr8BiPlanarFullRange

#define rcv_defer_block_name_with_prefix(prefix, suffix) prefix ## suffix
#define rcv_defer_block_name(suffix) rcv_defer_block_name_with_prefix(rcv_defer_, suffix)
#define rcv_defer __strong void(^rcv_defer_block_name(__LINE__))(void) __attribute__((cleanup(rcv_defer_cleanup_block), unused)) = ^
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"
static void rcv_defer_cleanup_block(__strong void(^*block)(void)) {
    (*block)();
}
#pragma clang diagnostic pop

@interface RcvCVPixelBufferScaler() {
    CVPixelBufferRef _pixelBuffer;
    NSMutableData *_tmpBuffer;
}
-(void)prepareBufferWithSize:(size_t)bufferSize;
@end

@implementation RcvCVPixelBufferScaler : NSObject

+(CGFloat)scaleFactorWidth:(size_t)width andHeight:(size_t)height {
    // Based on 3.1 level 1280 X 720 is max resolution
    CGFloat maxDimension = (CGFloat) MAX(width, height);
    CGFloat minDimension = (CGFloat) MIN(width, height);
    if (maxDimension <= 1280 && minDimension <= 720) {
        return 1.0;
    }
    return MIN((CGFloat)1280.0 / maxDimension, (CGFloat)720.0 / minDimension);
}

+(NSDictionary *)pixelAttributes {
    return  @{
              (id)kCVPixelBufferIOSurfacePropertiesKey: @{},
              (id)kCVPixelBufferOpenGLESCompatibilityKey: @(YES)
              };
}

-(CVPixelBufferRef)scalePixelBuffer:(CVPixelBufferRef)pixelBuffer toSize:(CGSize)size {
    size_t width = (size_t)size.width;
    size_t height = (size_t)size.height;

    OSType pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
    CVReturn cvResult = kCVReturnSuccess;
    vImage_Error vImgResult = kvImageNoError;
    BOOL checkTmpBuffer = NO;
    
    if (_pixelBuffer) {
        
        CVPixelBufferRetain(_pixelBuffer);
        
        if (CVPixelBufferGetWidth(_pixelBuffer) != width || CVPixelBufferGetHeight(_pixelBuffer) != height ||
            CVPixelBufferGetPixelFormatType(_pixelBuffer) != pixelFormat) {
            CVPixelBufferRelease(_pixelBuffer);
            _pixelBuffer = NULL;
        }
    }
    
    if (_pixelBuffer == NULL) {
        NSDictionary *attributes = [RcvCVPixelBufferScaler pixelAttributes];
        cvResult = CVPixelBufferCreate(kCFAllocatorDefault, width, height, pixelFormat, (__bridge CFDictionaryRef _Nullable)(attributes), &_pixelBuffer);
        checkTmpBuffer = YES;
    }
    
    if (cvResult != kCVReturnSuccess) {
        return NULL;
    }
    
    cvResult = CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    if (cvResult != kCVReturnSuccess) {
        return NULL;
    }
    
    rcv_defer {
        CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    };
    
    cvResult = CVPixelBufferLockBaseAddress(_pixelBuffer, 0);
    if (cvResult != kCVReturnSuccess) {
        return NULL;
    }
    
    rcv_defer {
        CVPixelBufferUnlockBaseAddress(self->_pixelBuffer, 0);
    };
    
    vImage_Buffer originalYBuffer = {
        CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0),
        CVPixelBufferGetHeightOfPlane(pixelBuffer, 0),
        CVPixelBufferGetWidthOfPlane(pixelBuffer, 0),
        CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0) };
    
    vImage_Buffer originalUVBuffer = {
        CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1),
        CVPixelBufferGetHeightOfPlane(pixelBuffer, 1),
        CVPixelBufferGetWidthOfPlane(pixelBuffer, 1),
        CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1) };
    
    vImage_Buffer scaledYBuffer = {
        CVPixelBufferGetBaseAddressOfPlane(_pixelBuffer, 0),
        CVPixelBufferGetHeightOfPlane(_pixelBuffer, 0),
        CVPixelBufferGetWidthOfPlane(_pixelBuffer, 0),
        CVPixelBufferGetBytesPerRowOfPlane(_pixelBuffer, 0) };
    
    vImage_Buffer scaledUVBuffer = {
        CVPixelBufferGetBaseAddressOfPlane(_pixelBuffer, 1),
        CVPixelBufferGetHeightOfPlane(_pixelBuffer, 1),
        CVPixelBufferGetWidthOfPlane(_pixelBuffer, 1),
        CVPixelBufferGetBytesPerRowOfPlane(_pixelBuffer, 1) };
    
    if (checkTmpBuffer) {
        ssize_t bufferSize1 = vImageScale_Planar8(&originalYBuffer, &scaledYBuffer, NULL, kvImageGetTempBufferSize);
        ssize_t bufferSize2 = vImageScale_CbCr8(&originalUVBuffer, &scaledUVBuffer, NULL, kvImageGetTempBufferSize);
        NSAssert(bufferSize1 >= 0 && bufferSize2 >= 0, @"5d8deadf-475d-490a-9525-9d4b0feb5f72");
        size_t bufferSize = bufferSize1 >= 0 && bufferSize2 >= 0 ? MAX(bufferSize1, bufferSize2) : 0;
        [self prepareBufferWithSize:bufferSize];
    }
    
    vImgResult = vImageScale_Planar8(&originalYBuffer, &scaledYBuffer, _tmpBuffer.mutableBytes, kvImageNoFlags);
    if (vImgResult != kvImageNoError) {
        return NULL;
    }
    
    vImgResult = vImageScale_CbCr8(&originalUVBuffer, &scaledUVBuffer, _tmpBuffer.mutableBytes, kvImageNoFlags);
    if (vImgResult != kvImageNoError) {
        return NULL;
    }
    
    return _pixelBuffer;
}

-(CVPixelBufferRef)scalePixelBuffer:(CVPixelBufferRef)pixelBuffer withFactorX:(CGFloat)factorX factorY:(CGFloat)factorY {
    size_t width = CVPixelBufferGetWidth(pixelBuffer) * factorX;
    size_t height = CVPixelBufferGetHeight(pixelBuffer) * factorY;
    return [self scalePixelBuffer:pixelBuffer toSize:CGSizeMake(width, height)];
}

-(CVPixelBufferRef)scalePixelBuffer:(CVPixelBufferRef)pixelBuffer withFactor:(CGFloat)factor {
    return [self scalePixelBuffer:pixelBuffer withFactorX:factor factorY:factor];
}

-(void)dealloc {
    CVPixelBufferRelease(_pixelBuffer);
    _pixelBuffer = NULL;
}

-(void)prepareBufferWithSize:(size_t)bufferSize {
    if (_tmpBuffer == nil) {
        _tmpBuffer = [NSMutableData dataWithLength:bufferSize];
    } else {
        _tmpBuffer.length = bufferSize;
    }
}

@end

@interface RcvCVPixelBufferConverter() {
    vImageCVImageFormatRef _dstFormat;
    NSMutableDictionary* _poolDictionary;
}
@end

@implementation RcvCVPixelBufferConverter

+(NSDictionary *)pixelAttributes
{
    return  @{
              (id)kCVPixelBufferIOSurfacePropertiesKey: @{},
              (id)kCVPixelBufferOpenGLESCompatibilityKey: @(YES),
//              (id)kCVPixelBufferPixelFormatTypeKey: @(FORMAT_TYPE)
              (id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32ARGB)
              };
}

+(NSDictionary *)pixelAttributesWith:(NSInteger)width height:(NSInteger)height
{
    return  @{
              (id)kCVPixelBufferIOSurfacePropertiesKey: @{},
              (id)kCVPixelBufferOpenGLESCompatibilityKey: @(YES),
              (id)kCVPixelBufferPixelFormatTypeKey: @(FORMAT_TYPE),
//              (id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32ARGB),
              (id)kCVPixelBufferWidthKey : @(width),
              (id)kCVPixelBufferHeightKey : @(height)
              };
}


-(instancetype)init
{
    if (self = [super init])
    {
        _poolDictionary = [@{} mutableCopy];
        CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceITUR_709);
        _dstFormat = vImageCVImageFormat_Create(FORMAT_TYPE, kvImage_ARGBToYpCbCrMatrix_ITU_R_709_2, kCVImageBufferChromaLocation_DV420, colorSpace, 0);
        CFRelease(colorSpace);
        return self;
    }
    return nil;
}

-(void)dealloc
{
    vImageCVImageFormat_Release(_dstFormat);
    for (int i = 0; i < _poolDictionary.count; i++) {
        CVPixelBufferPoolRef pool = (__bridge CVPixelBufferPoolRef)(_poolDictionary.allValues[i]);
        CVPixelBufferPoolFlush(pool, kCVPixelBufferPoolFlushExcessBuffers);
        CVPixelBufferPoolRelease(pool);
    }
}

- (CVPixelBufferRef) createPixelBufferWithImage: (UIImage *)image {
    CVPixelBufferRef pixelBuffer = NULL;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    NSDictionary *options = @{(NSString*)kCVPixelBufferCGImageCompatibilityKey : @YES, (NSString*)kCVPixelBufferCGBitmapContextCompatibilityKey : @YES};
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                          kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef)options, &pixelBuffer);
    NSParameterAssert(status == kCVReturnSuccess && pixelBuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);

    void *pxdata = CVPixelBufferGetBaseAddress(pixelBuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata, width, height, 8, CVPixelBufferGetBytesPerRow(pixelBuffer), colorSpace, kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    
    UIGraphicsPushContext(context);
    
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1, -1);
    [image drawInRect:CGRectMake(0, 0, width, height)];
    
    UIGraphicsPopContext();
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    
    return pixelBuffer;
}

- (CVPixelBufferRef)createPixelBufferWithCGImage:(CGImageRef)image {

    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
    CGFloat width = CGImageGetWidth(image);
    CGFloat height = CGImageGetHeight(image);
    
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                          kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef)options, &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);

    CVPixelBufferLockBaseAddress(pxbuffer, kCVPixelBufferLock_ReadOnly);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);

    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, width, height, 8, CVPixelBufferGetBytesPerRow(pxbuffer), rgbColorSpace, kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, kCVPixelBufferLock_ReadOnly);

    return pxbuffer;
}

-(CVPixelBufferRef)createPixelBufferWithCGImageViavImage:(CGImageRef)image
{
    CVReturn cvResult = kCVReturnSuccess;
    vImage_Error vImgResult = kvImageNoError;

    vImage_CGImageFormat sourceFormat = {
        .bitsPerComponent = (uint32_t)CGImageGetBitsPerComponent(image),
        .bitsPerPixel = (uint32_t)CGImageGetBitsPerPixel(image),
        .colorSpace = CGImageGetColorSpace(image),
        .bitmapInfo = CGImageGetBitmapInfo(image),
        .version = 0,
        .decode = NULL,
        .renderingIntent = CGImageGetRenderingIntent(image)
    };
    
    CGFloat backgroundColor[] = {0,0,0};
    
    vImageConverterRef converter = vImageConverter_CreateForCGToCVImageFormat(&sourceFormat, _dstFormat, backgroundColor, kvImagePrintDiagnosticsToConsole, &vImgResult);

    NSAssert(vImgResult == kvImageNoError , @"6fe1a02b-3179-477d-980d-06f66ad1646c");
    
    NSAssert(vImageConverter_GetNumberOfSourceBuffers(converter) == 1, @"86e70865-d0ac-4e7d-9c13-b58e35e44420");
    NSAssert(vImageConverter_GetNumberOfDestinationBuffers(converter) == 2, @"653c4cad-4bd2-4e89-83a7-baab35dbeb41");
    
    vImage_Buffer sourceBuffer;
    vImage_Buffer destinationBuffer[2];
    
    vImgResult = vImageBuffer_InitWithCGImage(&sourceBuffer, &sourceFormat, NULL, image, kvImageNoFlags);
    NSAssert(vImgResult == kvImageNoError , @"62feda91-6b11-4734-a88d-d33322912e59");
    
    NSDictionary *attributes = [RcvCVPixelBufferConverter pixelAttributes];

    CVPixelBufferRef pixelBuffer = NULL;
    cvResult = CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(image), CGImageGetHeight(image), FORMAT_TYPE, (__bridge CFDictionaryRef _Nullable)(attributes), &pixelBuffer);

    NSAssert(cvResult == kCVReturnSuccess, @"b86e69e3-71a2-4ff1-9ea0-20e234362db5");
    
    cvResult = CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    NSAssert(cvResult == kCVReturnSuccess, @"c04d20cc-c3e1-4286-b28e-ce13fd99740f");
    
    vImgResult = vImageBuffer_InitForCopyToCVPixelBuffer(destinationBuffer, converter, pixelBuffer, kvImageNoAllocate | kvImagePrintDiagnosticsToConsole);
    NSAssert(vImgResult == kvImageNoError, @"f1be03d4-0068-40c0-9459-f8c71ea35ffb");
    
    vImgResult = vImageConvert_AnyToAny(converter, &sourceBuffer, destinationBuffer, NULL, kvImagePrintDiagnosticsToConsole);
    NSAssert(vImgResult == kvImageNoError, @"7741f9f0-12c9-46d0-9096-35e6fb1fd051");
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    
    free(sourceBuffer.data);
    
    vImageConverter_Release(converter);
    
    return pixelBuffer;
}

- (CVPixelBufferRef)createPixelBufferWithCIImage:(CIImage *)image inContext:(CIContext *)context size:(CGSize)size {
    CVReturn cvResult = kCVReturnSuccess;

    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
    NSInteger width = size.width;
    NSInteger height = size.height;
    
    CVPixelBufferRef pixelBuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                          kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef)options, &pixelBuffer);
    NSParameterAssert(status == kCVReturnSuccess && pixelBuffer != NULL);
    
    cvResult = CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    NSAssert(cvResult == kCVReturnSuccess, @"c04d20cc-c3e1-4286-b28e-ce13fd99740f");

    [context render:image toCVPixelBuffer:pixelBuffer];
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    
    return pixelBuffer;
}

- (CVPixelBufferRef)createPixelBufferFromPoolWithCIImage:(CIImage *)image inContext:(CIContext *)context size:(CGSize)size {
    NSInteger width = size.width;
    NSInteger height = size.height;
    
    NSString *poolKey = [NSString stringWithFormat:@"%ld_%ld", (long)width, height];
    CVPixelBufferPoolRef pool = (__bridge CVPixelBufferPoolRef)(_poolDictionary[poolKey]);
    if (pool == nil) {
        NSDictionary *attributes = [RcvCVPixelBufferConverter pixelAttributesWith:width height:height];
        CVReturn theError = CVPixelBufferPoolCreate(kCFAllocatorDefault, NULL, (__bridge CFDictionaryRef) attributes, &pool);
        NSAssert(theError == kCVReturnSuccess, @"9ea069e3-71a2-4ff1-9ea0-20e234362db5");
        if (pool) {
            _poolDictionary[poolKey] = (__bridge id _Nullable)pool;
        }
    }
    
    CVReturn cvResult = kCVReturnSuccess;

    CVPixelBufferRef pixelBuffer = NULL;
    cvResult = CVPixelBufferPoolCreatePixelBuffer(NULL, pool, &pixelBuffer);

    NSAssert(cvResult == kCVReturnSuccess, @"b86e69e3-71a2-4ff1-9ea0-20e234362db5");
    
    cvResult = CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    NSAssert(cvResult == kCVReturnSuccess, @"c04d20cc-c3e1-4286-b28e-ce13fd99740f");

    [context render:image toCVPixelBuffer:pixelBuffer];
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    
    return pixelBuffer;
}

-(CVPixelBufferRef)createPixelBufferFromPoolWithCGImage:(CGImageRef)image {
    NSInteger width = CGImageGetWidth(image);
    NSInteger height = CGImageGetHeight(image);
    NSString *poolKey = [NSString stringWithFormat:@"%ld_%ld", (long)width, height];
    CVPixelBufferPoolRef pool = (__bridge CVPixelBufferPoolRef)(_poolDictionary[poolKey]);
    if (pool == nil) {
        NSDictionary *attributes = [RcvCVPixelBufferConverter pixelAttributesWith:width height:height];
        CVReturn theError = CVPixelBufferPoolCreate(kCFAllocatorDefault, NULL, (__bridge CFDictionaryRef) attributes, &pool);
        NSAssert(theError == kCVReturnSuccess, @"9ea069e3-71a2-4ff1-9ea0-20e234362db5");
        if (pool) {
            _poolDictionary[poolKey] = (__bridge id _Nullable)pool;
        }
    }
    CVReturn cvResult = kCVReturnSuccess;
    vImage_Error vImgResult = kvImageNoError;

    vImage_CGImageFormat sourceFormat = {
        .bitsPerComponent = (uint32_t)CGImageGetBitsPerComponent(image),
        .bitsPerPixel = (uint32_t)CGImageGetBitsPerPixel(image),
        .colorSpace = CGImageGetColorSpace(image),
        .bitmapInfo = CGImageGetBitmapInfo(image),
        .version = 0,
        .decode = NULL,
        .renderingIntent = CGImageGetRenderingIntent(image)
    };

    CGFloat backgroundColor[] = {0,0,0};

    vImageConverterRef converter = vImageConverter_CreateForCGToCVImageFormat(&sourceFormat, _dstFormat, backgroundColor, kvImagePrintDiagnosticsToConsole, &vImgResult);

    NSAssert(vImgResult == kvImageNoError , @"6fe1a02b-3179-477d-980d-06f66ad1646c");
        
    NSAssert(vImageConverter_GetNumberOfSourceBuffers(converter) == 1, @"86e70865-d0ac-4e7d-9c13-b58e35e44420");
    NSAssert(vImageConverter_GetNumberOfDestinationBuffers(converter) == 2, @"653c4cad-4bd2-4e89-83a7-baab35dbeb41");
        
    vImage_Buffer sourceBuffer;
    vImage_Buffer destinationBuffer[2];
        
    vImgResult = vImageBuffer_InitWithCGImage(&sourceBuffer, &sourceFormat, NULL, image, kvImageNoFlags);
    NSAssert(vImgResult == kvImageNoError , @"62feda91-6b11-4734-a88d-d33322912e59");
        
    CVPixelBufferRef pixelBuffer = NULL;
    cvResult = CVPixelBufferPoolCreatePixelBuffer(NULL, pool, &pixelBuffer);
        
    NSAssert(cvResult == kCVReturnSuccess, @"b86e69e3-71a2-4ff1-9ea0-20e234362db5");
        
    cvResult = CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    NSAssert(cvResult == kCVReturnSuccess, @"c04d20cc-c3e1-4286-b28e-ce13fd99740f");
        
    vImgResult = vImageBuffer_InitForCopyToCVPixelBuffer(destinationBuffer, converter, pixelBuffer, kvImageNoAllocate | kvImagePrintDiagnosticsToConsole);
    NSAssert(vImgResult == kvImageNoError, @"f1be03d4-0068-40c0-9459-f8c71ea35ffb");
        
    vImgResult = vImageConvert_AnyToAny(converter, &sourceBuffer, destinationBuffer, NULL, kvImagePrintDiagnosticsToConsole);
    NSAssert(vImgResult == kvImageNoError, @"7741f9f0-12c9-46d0-9096-35e6fb1fd051");
        
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        
    free(sourceBuffer.data);
        
    vImageConverter_Release(converter);
        
    return pixelBuffer;
}

@end

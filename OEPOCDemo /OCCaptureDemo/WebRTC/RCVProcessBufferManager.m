//
//  RCVProcessBufferManager.m
//  rcv
//
//  Created by Zoey Weng on 2020/12/8.
//  Copyright © 2020 RingCentral. All rights reserved.
//

#import "RCVProcessBufferManager.h"
#import "RCVProcessPixelBufferProtocol.h"
#import <UIKit/UIKit.h>

@implementation RCVProcessBufferManager

@synthesize effectPlayer = _effectPlayer;

+ (instancetype)sharedManager {
    static RCVProcessBufferManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)resetProcesser {
    [_effectPlayer unloadEffect];
    _shouldProcessFrameBuffer = NO;
    _isUsingTransparency = NO;
}

- (_Nullable id<RCVProcessPixelBufferProtocol>)pixelBufferProcesser {
    return (id<RCVProcessPixelBufferProtocol>)self.effectPlayer;
}

- (BNBOffscreenEffectPlayer *)effectPlayer {
    if (!_effectPlayer) {
        CGSize size = CGSizeMake(540, 960);
        _effectPlayer = [[BNBOffscreenEffectPlayer alloc] initWithEffectWidth:size.width andHeight:size.height manualAudio:false];
    }
    return _effectPlayer;
}

@end

@interface BNBOffscreenEffectPlayer(BanubaProcesser)<RCVProcessPixelBufferProtocol>

@end

@implementation BNBOffscreenEffectPlayer(BanubaProcesser)

- (BOOL)shouldProcessFrameBuffer {
    return RCVProcessBufferManager.sharedManager.shouldProcessFrameBuffer;
}

- (_Nullable CVPixelBufferRef)processBuffer:(CVPixelBufferRef)pixelBuffer {
    CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    CGSize size = CGSizeMake(width, height);
    EpImageFormat imageFormat;
    imageFormat.imageSize = size;
    imageFormat.orientation = EPOrientationAngles90;
    imageFormat.resultedImageOrientation = EPOrientationAngles90;
    imageFormat.faceOrientation = 0;
    imageFormat.needAlphaInOutput = RCVProcessBufferManager.sharedManager.isUsingTransparency;
    imageFormat.isMirrored = YES;
    imageFormat.isYFlip = RCVProcessBufferManager.sharedManager.isUsingTransparency;
    
    // NOTE: the processY method will return object with CF_RETURNS_RETAINED, so need to release the object out side.
    CVPixelBufferRef resPixelBuffer = [self processImage:pixelBuffer withFormat:&imageFormat];
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    
    return resPixelBuffer;
}
@end


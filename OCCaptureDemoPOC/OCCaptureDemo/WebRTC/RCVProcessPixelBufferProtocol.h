//
//  RCVProcessPixelBufferProtocol.h
//  rcv
//
//  Created by Zoey Weng on 2020/12/8.
//  Copyright © 2020 RingCentral. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CVPixelBuffer.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RCVProcessPixelBufferProtocol <NSObject>

- (BOOL)shouldProcessFrameBuffer;

- (_Nullable CVPixelBufferRef)processBuffer:(CVPixelBufferRef)pixelBuffer;

@end

NS_ASSUME_NONNULL_END

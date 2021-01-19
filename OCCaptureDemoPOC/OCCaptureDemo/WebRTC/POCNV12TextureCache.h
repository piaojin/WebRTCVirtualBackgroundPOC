//
//  POCNV12TextureCache.h
//  rcv
//
//  Created by rcadmin on 2020/12/25.
//  Copyright © 2020 RingCentral. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GLKit/GLKit.h>

#import <WebRTC/WebRTC.h>

@class RTC_OBJC_TYPE(RTCVideoFrame);

NS_ASSUME_NONNULL_BEGIN

@interface POCNV12TextureCache : NSObject

@property(nonatomic, readonly) GLuint texture;

- (instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithContext:(EAGLContext *)context NS_DESIGNATED_INITIALIZER;

- (BOOL)uploadFrameToTextures:(RTC_OBJC_TYPE(RTCVideoFrame) *)frame;

- (void)releaseTextures;

@end

NS_ASSUME_NONNULL_END


//
//  POCEAGLVideoView.h
//  rcv
//
//  Created by rcadmin on 2020/12/24.
//  Copyright © 2020 RingCentral. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <WebRTC/WebRTC.h>

#import "POCVideoViewShading.h"

NS_ASSUME_NONNULL_BEGIN

@class RTC_OBJC_TYPE(POCEAGLVideoView);

/**
 * RTCEAGLVideoView is an RTCVideoRenderer which renders video frames
 * in its bounds using OpenGLES 2.0 or OpenGLES 3.0.
 */
RTC_OBJC_EXPORT
NS_EXTENSION_UNAVAILABLE_IOS("Rendering not available in app extensions.")
@interface RTC_OBJC_TYPE (POCEAGLVideoView) : UIView <RTC_OBJC_TYPE(RTCVideoRenderer)>

@property(nonatomic, weak) id<RTC_OBJC_TYPE(RTCVideoViewDelegate)> delegate;

- (instancetype)initWithFrame:(CGRect)frame
                       shader:(id<RTC_OBJC_TYPE(POCVideoViewShading)>)shader
    NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
                       shader:(id<RTC_OBJC_TYPE(POCVideoViewShading)>)shader
    NS_DESIGNATED_INITIALIZER;

/** @abstract Wrapped RTCVideoRotation, or nil.
 */
@property(nonatomic, nullable) NSValue *rotationOverride;

- (void)renderFrame:(nullable RTC_OBJC_TYPE(RTCVideoFrame) *)frame;
@end

NS_ASSUME_NONNULL_END


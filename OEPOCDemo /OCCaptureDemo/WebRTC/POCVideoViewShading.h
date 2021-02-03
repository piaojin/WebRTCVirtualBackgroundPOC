//
//  POCVideoViewShading.h
//  rcv
//
//  Created by rcadmin on 2020/12/29.
//  Copyright © 2020 RingCentral. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * RTCVideoViewShading provides a way for apps to customize the OpenGL(ES shaders
 * used in rendering for the RTCEAGLVideoView/RTCNSGLVideoView.
 */
RTC_OBJC_EXPORT
@protocol RTC_OBJC_TYPE
(POCVideoViewShading)<NSObject>

/** Callback for NV12 frames. Each plane is given as a texture. */
- (void)applyShadingForFrameWithWidth:(int)width
                               height:(int)height
                             rotation:(RTCVideoRotation)rotation
                              texture:(GLuint)texture;

@end

NS_ASSUME_NONNULL_END

//
//  POCDefaultShader.h
//  rcv
//
//  Created by rcadmin on 2020/12/24.
//  Copyright © 2020 RingCentral. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>

#import "POCVideoViewShading.h"

NS_ASSUME_NONNULL_BEGIN

/** Default RTCVideoViewShading that will be used in RTCNSGLVideoView
 *  and RTCEAGLVideoView if no external shader is specified. This shader will render
 *  the video in a rectangle without any color or geometric transformations.
 */
@interface POCDefaultShader : NSObject <RTC_OBJC_TYPE (POCVideoViewShading)>

@end

NS_ASSUME_NONNULL_END

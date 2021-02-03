//
//  RCVAIForwardVideoSource.h
//  rcv
//
//  Created by Zoey Weng on 2020/12/8.
//  Copyright © 2020 RingCentral. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>

@protocol RTCVideoCapturerDelegate, RCVProcessPixelBufferProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface RCVAIForwardVideoSource : NSObject<RTCVideoCapturerDelegate>

@property(nullable, nonatomic, weak) id<RTCVideoCapturerDelegate> forWardTarget;
@property(nullable, nonatomic, weak) id<RCVProcessPixelBufferProtocol> pixelBufferProcesser;

- (instancetype)initWithDelegate:(id<RTCVideoCapturerDelegate>)forWardTarget;

@end

NS_ASSUME_NONNULL_END

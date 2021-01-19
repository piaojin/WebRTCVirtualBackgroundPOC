//
//  RCVProcessBufferManager.h
//  rcv
//
//  Created by Zoey Weng on 2020/12/8.
//  Copyright © 2020 RingCentral. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCVProcessPixelBufferProtocol.h"
#import <WebRTC/WebRTC.h>

#import <UIKit/UIKit.h>
#import "POCEAGLVideoView.h"

@class BNBOffscreenEffectPlayer;
@protocol RCVProcessPixelBufferProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface RCVProcessBufferManager : NSObject

@property(nullable, nonatomic, readonly, strong) id<RCVProcessPixelBufferProtocol> pixelBufferProcesser;
@property (nullable, nonatomic, readonly, strong) BNBOffscreenEffectPlayer *effectPlayer;
@property (nonatomic, assign) BOOL shouldProcessFrameBuffer;
@property (nullable, nonatomic, weak) POCEAGLVideoView *weatherManPreView;

+ (instancetype)sharedManager;
- (void) loadEffect;

@end

NS_ASSUME_NONNULL_END

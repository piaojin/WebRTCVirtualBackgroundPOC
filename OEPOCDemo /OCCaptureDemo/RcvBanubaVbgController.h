//
//  RcvBanubaVbgController.h
//  rcv
//
//  Created by Jackie Ou on 2020/7/21.
//  Copyright © 2020 RingCentral. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+Extension.h"

@class RcvXVbgModel;

typedef void(^LoadEffectsCompletion)(NSArray<RcvXVbgModel *> *_Nonnull);
typedef void(^SetEffectsCompletion)(void);

NS_ASSUME_NONNULL_BEGIN

@interface RcvBanubaVbgController : NSObject

+ (instancetype)sharedInstance;

- (void)initComponents;

- (void)loadEffectsWith:(LoadEffectsCompletion _Nonnull)completion;

- (NSArray<RcvXVbgModel *> *_Nonnull)loadEffects;

- (void)setEffect:(nonnull NSString *)name completion:(SetEffectsCompletion _Nonnull)completion;

- (BOOL)isUsingTransparency;

- (void)resetEffect;

- (nonnull NSString *)currentEffectName;

- (void)enableVirtualBackground:(BOOL)enabled;

- (void)setVirtualBackground:(nonnull NSString *)name;

- (void)enableBlurBackground:(BOOL)enabled;

- (void)setBlurStrength:(int32_t)value;

- (void)enableLipsColor:(BOOL)enabled;

- (void)setLipsColor:(nonnull NSString *)rgba;

- (void)enableEyesColor:(BOOL)enabled;

- (void)setEyesColor:(nonnull NSString *)rgba;

- (void)enableHairColor:(BOOL)enabled;

- (void)setHairColor:(nonnull NSString *)rgba;

- (void)onDataUpdate:(nonnull NSString *)json;

- (void)destroyEffectPlayer;

@end

NS_ASSUME_NONNULL_END

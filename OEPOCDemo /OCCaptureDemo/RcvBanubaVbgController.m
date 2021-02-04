//
//  RcvBanubaVbgController.m
//  rcv
//
//  Created by Jackie Ou on 2020/7/21.
//  Copyright © 2020 RingCentral. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RcvBanubaVbgController.h"
#import <BanubaEffectPlayer/BanubaEffectPlayer.h>
#import "RCVProcessBufferManager.h"
#import "RcvXVbgModel.h"

@interface RcvBanubaVbgController()
@property (atomic, strong) NSString* effectName;
@property (nullable, nonatomic, weak) BNBOffscreenEffectPlayer *effectPlayer;

@end

@implementation RcvBanubaVbgController {
}

+ (instancetype) sharedInstance {
    static RcvBanubaVbgController* _instance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
        _instance.effectName = @"";
    }) ;
    
    return _instance;
}

- (void)dealloc {
    NSLog(@" ~RcvBanubaVbgController dealloc");
}

- (BNBOffscreenEffectPlayer *)effectPlayer {
    return [RCVProcessBufferManager sharedManager].effectPlayer;
}

- (NSArray<RcvXVbgModel *> *_Nonnull)loadEffects {
    NSMutableArray<RcvXVbgModel *> *effects = [NSMutableArray<RcvXVbgModel *> array];
    RcvXVbgModel *offModel = [[RcvXVbgModel alloc] initWithType:RcvVbgBackgroundTypeNONE effectName: @"" thumbnailPath:@"" imagePath:@""];
    [effects addObject:offModel];
    
    // Load effects from Resourc/effects/
    NSURL *effectsURL = [NSBundle.mainBundle URLForResource:@"effects" withExtension:nil];
    if (effectsURL.absoluteString) {
        NSString *path = [effectsURL.absoluteString stringByReplacingOccurrencesOfString:@"file:///" withString:@""];
        NSError *error;
        NSArray<NSString *> *dirPaths = [NSFileManager.defaultManager contentsOfDirectoryAtPath:path error:&error];
        
        for (NSString *effectName in dirPaths) {
            // Will use effect `Beauty` when select custome or default vbg image. So ignore `Beauty` here.
            if (![effectName isEqualToString:@"Beauty"]) {
                RcvXVbgModel *model = [[RcvXVbgModel alloc] initWithType:RcvVbgBackgroundTypeEFFECT effectName:effectName thumbnailPath:@"" imagePath:@""];
                [effects addObject:model];
            }
        }
    }
    
    // Load vbg images from Resourc/vbg/images/
    NSURL *vbgURL = [NSBundle.mainBundle URLForResource:@"vbg/images" withExtension:nil];
    if (vbgURL.absoluteString) {
        NSString *path = [vbgURL.absoluteString stringByReplacingOccurrencesOfString:@"file:///" withString:@""];
        NSError *error;
        NSArray<NSString *> *filePaths = [NSFileManager.defaultManager contentsOfDirectoryAtPath:path error:&error];
        NSInteger vbgImageCount = filePaths.count / 2;
        for (int i = 0; i < vbgImageCount; i++) {
            NSString *imagePath = [NSString stringWithFormat:@"%@rcv_bg_%d.jpg", path, i + 1];
            NSString *thumbnailPath = [NSString stringWithFormat:@"%@thumbnail_rcv_bg_%d.jpg", path, i + 1];
            RcvXVbgModel *model = [[RcvXVbgModel alloc] initWithType:RcvVbgBackgroundTypeDEFAULT effectName: @"Beauty" thumbnailPath:thumbnailPath imagePath:imagePath];
            [effects addObject:model];
        }
    }

    RcvXVbgModel *moreModel = [[RcvXVbgModel alloc] initWithType:RcvVbgBackgroundTypeMORE effectName: @"" thumbnailPath:@"" imagePath:@""];
    [effects addObject:moreModel];
    return effects;
}

- (void)loadEffectsWith:(LoadEffectsCompletion _Nonnull)completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (completion) {
            completion([self loadEffects]);
        }
    });
}

- (void)setEffect:(nonnull NSString *)name completion:(SetEffectsCompletion _Nonnull)completion {
    if ([self.effectName isEqualToString:name]) {
        [RCVProcessBufferManager sharedManager].shouldProcessFrameBuffer = ![NSString isBlankString: name];
        return;
    }
    
    [self destroyEffectPlayer];
    
    self.effectName = name;
    [self.effectPlayer loadEffect:_effectName completion:^{
        [RCVProcessBufferManager sharedManager].shouldProcessFrameBuffer = ![NSString isBlankString: name];
        if ([name isEqualToString:@"Blur"]) {
            [self enableBlurBackground:YES];
            [self setBlurStrength:6];
        } else if ([name isEqualToString:@"Beauty"]) {
            [self enableVirtualBackground:YES];
        }
        if (completion) {
            completion();
        }
    }];
}

- (nonnull NSString *)currentEffectName {
    return _effectName;
}

- (BOOL)isUsingTransparency {
    return [RCVProcessBufferManager sharedManager].isUsingTransparency;
}

- (void)resetEffect {
    [[RCVProcessBufferManager sharedManager] resetProcesser];
    self.effectName = @"";
}

- (void)enableVirtualBackground:(BOOL)enabled {
    if (enabled) {
        [self.effectPlayer callJsMethod:@"initBackground" withParam:@"true"];
    } else {
        [self.effectPlayer callJsMethod:@"deleteBackground" withParam:@"true"];
    }
}

- (void)setVirtualBackground:(nonnull NSString *)name {
    [self.effectPlayer callJsMethod:@"setBackgroundTexture" withParam:name];
}

- (void)enableBlurBackground:(BOOL)enabled {
    if (enabled) {
        [self.effectPlayer callJsMethod:@"initBlurBackground" withParam:@"true"];
    } else {
        [self.effectPlayer callJsMethod:@"deleteBlurBackground" withParam:@"true"];
    }
}

- (void)setBlurStrength:(int32_t)value {
    NSString* params = [NSString stringWithFormat:@"%d", value];
    [self.effectPlayer callJsMethod:@"setBlurRadius" withParam:params];
}

- (void)enableLipsColor:(BOOL)enabled {
    if (enabled) {
        [self.effectPlayer callJsMethod:@"initLipsColoring" withParam:@"true"];
    } else {
        [self.effectPlayer callJsMethod:@"deleteLipsColoring" withParam:@"true"];
    }
}

- (void)setLipsColor:(nonnull NSString *)rgba {
    [self.effectPlayer callJsMethod:@"setLipsColor" withParam:rgba];
}

- (void)enableEyesColor:(BOOL)enabled {
    if (enabled) {
        [self.effectPlayer callJsMethod:@"initEyesColoring" withParam:@"true"];
    } else {
        [self.effectPlayer callJsMethod:@"deleteEyesColoring" withParam:@"true"];
    }
}

- (void)setEyesColor:(nonnull NSString *)rgba {
    [self.effectPlayer callJsMethod:@"setEyesColor" withParam:rgba];
}

- (void)enableHairColor:(BOOL)enabled {
    if (enabled) {
        [self.effectPlayer callJsMethod:@"initHairColoring" withParam:@"true"];
    } else {
        [self.effectPlayer callJsMethod:@"deleteHairColoring" withParam:@"true"];
    }
}

- (void)setHairColor:(nonnull NSString *)rgba {
    [self.effectPlayer callJsMethod:@"setHairColor" withParam:rgba];
}

- (void)onDataUpdate:(nonnull NSString *)json {
    [self.effectPlayer callJsMethod:@"onDataUpdate" withParam:json];
}

- (void)destroyEffectPlayer {
    [[RCVProcessBufferManager sharedManager] resetProcesser];
    self.effectPlayer = nil;
}

@end

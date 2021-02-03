//
//  RcvXVbgModel.m
//  OCCaptureDemo
//
//  Created by rcadmin on 2021/2/2.
//

#import "RcvXVbgModel.h"

@implementation RcvXVbgModel

- (nonnull instancetype)initWithType:(RcvVbgBackgroundType)type
                           effectName:(nonnull NSString *)effectName
                        thumbnailPath:(nonnull NSString *)thumbnailPath
                            imagePath:(nonnull NSString *)imagePath {
    if (self = [super init]) {
        _type = type;
        _effectName = effectName;
        _thumbnailPath = [thumbnailPath copy];
        _imagePath = [imagePath copy];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p effectName:%@ thumbnailPath:%@ imagePath:%@>", self.class, (void *)self, self.effectName, self.thumbnailPath, self.imagePath];
}

@end

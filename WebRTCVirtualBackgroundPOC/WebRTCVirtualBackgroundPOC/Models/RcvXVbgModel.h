//
//  RcvXVbgModel.h
//  WebRTCVirtualBackgroundPOC
//
//  Created by piaojin on 2021/2/2.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RcvVbgBackgroundType)
{
    RcvVbgBackgroundTypeNONE, // Turn Off vbg.
    RcvVbgBackgroundTypeEFFECT, // Blur,Beauty,transparency and etc.
    RcvVbgBackgroundTypeMORE, // Add more custom vbg background image from album.
    RcvVbgBackgroundTypeDEFAULT, // The default vbg background image.
    RcvVbgBackgroundTypeCUSTOM, // The custom vbg background image.
};

NS_ASSUME_NONNULL_BEGIN

@interface RcvXVbgModel : NSObject

- (nonnull instancetype)initWithType:(RcvVbgBackgroundType)type
                           effectName:(nonnull NSString *)effectName
                        thumbnailPath:(nonnull NSString *)thumbnailPath
                            imagePath:(nonnull NSString *)imagePath;

@property (nonatomic, readonly) RcvVbgBackgroundType type;

@property (nonatomic, readonly, nonnull) NSString * thumbnailPath;

@property (nonatomic, readonly, nonnull) NSString * imagePath;

@property (nonatomic, readonly, nonnull) NSString * effectName;

@end

NS_ASSUME_NONNULL_END

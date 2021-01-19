//
//  TestCovertImageToBufferViewController.h
//  OCCaptureDemo
//
//  Created by rcadmin on 2021/1/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PixelBufferModel : NSObject

@property (nonatomic, assign, nullable) CVPixelBufferRef pixelBuffer;
@property (nonatomic, assign, nullable) CFTypeRef backingData;

@end

@interface TestCovertImageToBufferViewController : UIViewController

@end

NS_ASSUME_NONNULL_END

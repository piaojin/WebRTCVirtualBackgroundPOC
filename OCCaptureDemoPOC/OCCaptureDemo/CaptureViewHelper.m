//
//  CaptureViewHelper.m
//  OCCaptureDemo
//
//  Created by rcadmin on 2021/1/11.
//

#import "CaptureViewHelper.h"
#import <UIKit/UIKit.h>

//https://stackoverflow.com/questions/4334233/how-to-capture-uiview-to-uiimage-without-loss-of-quality-on-retina-display
@implementation CaptureViewHelper

// https://developer.apple.com/library/archive/qa/qa1817/_index.html
+ (UIImage *) takeSnapshotFrom1: (UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, [UIScreen mainScreen].scale);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

+ (UIImage *) takeSnapshotFrom2: (UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

+ (UIImage *) takeSnapshotFrom3: (UIView *)view {
    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
    format.scale = [UIScreen mainScreen].scale;
    format.opaque = view.isOpaque;
    UIGraphicsImageRenderer *render = [[UIGraphicsImageRenderer alloc] initWithBounds:view.bounds format:format];
    return [render imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    }];
}

+ (UIImage *) takeSnapshotFrom4:(UIView *)view {
    UIView *capturedView = [view snapshotViewAfterScreenUpdates:YES];
    UIImage *image = nil;
    if (capturedView) {
        image = [self takeSnapshotFrom1:capturedView];
    }
    return image;
}

@end


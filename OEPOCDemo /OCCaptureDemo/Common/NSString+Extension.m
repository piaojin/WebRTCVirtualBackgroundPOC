//
//  NSString+Extension.m
//  OCCaptureDemo
//
//  Created by rcadmin on 2021/2/3.
//

#import "NSString+Extension.h"

@implementation NSString (NSString_Extension)

+ (BOOL)isBlankString:(NSString *)str {
    if (!str) {
        return YES;
    }
    if ([str isKindOfClass:[NSNull class]]) {
        return YES;
    }
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedStr = [str stringByTrimmingCharactersInSet:set];
    if (!trimmedStr.length) {
        return YES;
    }
    return NO;
}

@end

// AUTOGENERATED FILE - DO NOT MODIFY!
// This file generated by Djinni from effect_player.djinni

#import <Foundation/Foundation.h>


/** Interface to receive notifications on effect change */
@protocol BNBEffectActivatedListener

/** called when effect is activated */
- (void)onEffectActivated:(nonnull NSString *)url;

@end
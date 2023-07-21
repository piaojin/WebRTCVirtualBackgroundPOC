//
//  AppDelegate.m
//  WebRTCVirtualBackgroundPOC
//
//  Created by piaojin on 2020/12/15.
//

#import "AppDelegate.h"
#import <BanubaEffectPlayer/BanubaEffectPlayer.h>
#import "RcvBanubaVbgController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self setUpBNBOffscreenEffectPlayer];
    return YES;
}

- (void) setUpBNBOffscreenEffectPlayer {
    NSString *effectsPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/effects"];
    NSString *bundleRoot = [NSBundle bundleForClass:BNBEffectPlayer.self].bundlePath;
    NSArray<NSString *> *dir = @[[NSString stringWithFormat:@"%@/bnb-resources", bundleRoot], effectsPath];

    [BNBUtilityManager initialize:dir clientToken:@"dXIoj3ORBOo1sERKxdLraTRKfEC8pkAjGbiOTzWJ6EqEoXzI+0YsMWaCXvyAGeFpsa9EPkz0PvBMRjz3XxLuXKNp2bWXQOeVHtM2ZbeKhBAS17khcXuQvR+iiASo1+K+CVbsM5BVlYUB0nPgGi0DIE250AdXROpUh+/f44/MsTB2emQnRnfvMRvzCmidWvEGELB/WKdhrICIH5mwgy2GJxVmazuaeKj2Vj3lpxevnGzaK9Ia/7zJBPdktoxZh1TQ814fj8Ftrp+5s9pM1J6q/pRl6RxKg1NK1/rqpMFXngMxe27w0I0pJ+Ni8i2ixPYEFgeeAvLa63se6qvJNXfqNftbmYPXhB4SRX1Rm3Tl/mBhZEsmxW+xj1xfzv1xNUwpEtsYqCephnvgmsufdAQQN/Frv4K/AsCuMQBwvadcYY92zFZB0Q2c0qTfdl1zUZHJcxyH5qxwBtvkLpI3mFh2xdywtVph4fOmxHEDeqVjsCb7qm9gUnXbdi8RuIocqUNCFDlOKpF7+lO+FLHZ9TGGR/jSazZOLVNBctRXCwSzDkP7Dd7IpDforQDjwQG7r0JUBZh0tWCVtEeVfsbwEipY3GZVEsdgUcKkbC5AWocSvPmuFXFlnrlpXOpY/R2tLGwROT7u0vdTDGiUmcMO0WAy5K68mKlb6SwJOq4UhOQBq9U0AEcheFogSQtVUXr1HED6EdrU"
     ];
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options  API_AVAILABLE(ios(13.0)){
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions  API_AVAILABLE(ios(13.0)){
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end

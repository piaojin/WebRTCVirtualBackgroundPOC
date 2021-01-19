#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, EPOrientation) {
    EPOrientationAngles0,
    EPOrientationAngles90,
    EPOrientationAngles180,
    EPOrientationAngles270
};


typedef struct
{
    /**
     * size of input image
     */
    CGSize imageSize;
    /**
     * Image orientation, Angles0 means head at the top, other angles mean counterlockwise rotation
     */
    EPOrientation orientation;
    /**
     * Resulted image orientation. If coincide with orientation then image will be returned in the same orientation.
     * Set to EPOrientationAngles0 to keep OEP default orientation.
     */
    EPOrientation resultedImageOrientation;
    /**
     * The angle, see UIDeviceOrientation and BanubaSdkManager extension of it.
     */
    NSInteger faceOrientation;
    /**
     * If YES then resulted image will be mirrored
     */
    BOOL isMirrored;
    /**
     * if YES, (0,0) in bottom left, else in top left. This parameter overrided if orientation and resultedImageOrientation are equal except the case then this value is EPOrientationAngles0
     */
    BOOL isYFlip;
    /**
     * TODO: Add support to return YUV with Alpha. Returns BGRA since YUV-Alpha is not supported yet
     * Used for the cases then returned image should include valid alpha channel
     */
    BOOL needAlphaInOutput;
} EpImageFormat;

typedef void (^BNBOEPVoidBlock)(void);

/**
 * All methods must be called from the same thread
 * (in which the object was created BNBOffscreenEffectPlayer)
 * All methods are synchronous
 *
 * WARNING: SDK should be initialized with BNBUtilityManager before BNBOfscreenEffectPlayer creating
 */
@interface BNBOffscreenEffectPlayer : NSObject

/*
 * effectWidth andHeight the size of the inner area where the effect is drawn
 * NOTE: There is an assumption that it is user responsibility to make sure that
 *       size of rendering area equal to the image size passed to processImage
 */
- (instancetype)initWithEffectWidth:(NSUInteger)width
                          andHeight:(NSUInteger)height
                        manualAudio:(BOOL)manual;

/*
* EpImageFormat::imageSize - size of input Y image
* the size of the output image is equal to the size of the inner area where the effect is drawn
*/
- (nullable CVPixelBufferRef)processImage:(CVPixelBufferRef)pixelBuffer withFormat:(EpImageFormat*)imageFormat CF_RETURNS_RETAINED;

- (void)loadEffect:(NSString*)effectName;
- (void)loadEffect:(NSString* _Nonnull)effectName completion:(BNBOEPVoidBlock _Nonnull) completion;
- (void)unloadEffect;

/*
 *pause/resume controls only audio playback
 */
- (void)pause;
- (void)resume;

/*
 * When you use EffectPlayer with CallKit you should enable audio manually at the point when CallKit
 * notifies that its Audio Session is ready (its session is created in privileged mode, so it should be respected).
 */
- (void)enableAudio:(BOOL)enable;

- (void)callJsMethod:(NSString*)method withParam:(NSString*)param;

@end

NS_ASSUME_NONNULL_END

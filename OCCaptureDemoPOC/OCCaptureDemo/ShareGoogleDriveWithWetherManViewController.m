//
//  ShareGoogleDriveWithWetherManViewController.m
//  OCCaptureDemo
//
//  Created by rcadmin on 2021/1/19.
//

#import "ShareGoogleDriveWithWetherManViewController.h"
#import "OCCaptureDemo-Swift.h"
#import <WebKit/WebKit.h>
#import "CaptureViewHelper.h"
#import <WebRTC/WebRTC.h>
#import "RcvCVPixelBufferUtils.h"
#import <BanubaEffectPlayer/BanubaEffectPlayer.h>
#import "OCCaptureDemo-Swift.h"
#import "POCEAGLVideoView.h"
#import "RCVAIForwardVideoSource.h"
#import "RCVProcessBufferManager.h"
@import CoreImage.CIFilterBuiltins;

typedef NS_ENUM(NSInteger, RcvCaptureFrame) {
    RcvCaptureFramePreset352X288,
    RcvCaptureFramePreset640X480,
    RcvCaptureFramePreset960X540,
    RcvCaptureFramePreset1280x720,
};

#pragma mark - WebRTC @property
@interface ShareGoogleDriveWithWetherManViewController ()
@property (nonatomic, strong) RTCCameraVideoCapturer *cameraVideoCapturer;
@property (nonatomic, strong) POCEAGLVideoView *rtcEAGLVideoView;
@property (nonatomic, strong) RTCVideoSource *videoSource;
@property (nonatomic, strong) RCVAIForwardVideoSource *forWardVideoSource;
@property (nonatomic, strong) RTCPeerConnectionFactory *factory;
@property (nonatomic, strong) RTCVideoTrack *rtcTrack;
@property (nonatomic, assign) RcvCaptureFrame frame;
@end

#pragma mark - Capture WKWebView @property
@interface ShareGoogleDriveWithWetherManViewController ()
@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) RcvCVPixelBufferConverter *pixelBufferConverter;
@property (nonatomic, strong) dispatch_queue_t convertPixelBufferQueue;

@property (nonatomic, strong) CIContext *context;
@property (nonatomic, strong) CIFilter *filter;
@property (nonatomic, strong) UIImage *image;
@end

#pragma mark - Capture WKWebView @property
@interface ShareGoogleDriveWithWetherManViewController ()
@property (nullable, nonatomic, strong) BNBOffscreenEffectPlayer *effectPlayer;
@end

@implementation ShareGoogleDriveWithWetherManViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _image = [UIImage imageNamed:@"shotcut4"];
    [self setUpView];
    [self setUpData];
}

- (void) setUpView {
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.wkWebView];
    [[self.wkWebView.topAnchor constraintEqualToAnchor:self.view.topAnchor] setActive:YES];
    [[self.wkWebView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor] setActive:YES];
    [[self.wkWebView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor] setActive:YES];
    [[self.wkWebView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.5] setActive:YES];
//    [[self.wkWebView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
    
    [self.view addSubview:self.imageView];
    [[self.imageView.topAnchor constraintEqualToAnchor:self.wkWebView.bottomAnchor] setActive:YES];
    [[self.imageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
    [[self.imageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor] setActive:YES];
    [[self.imageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor] setActive:YES];
    
    self.view.backgroundColor = UIColor.whiteColor;
    [self.wkWebView addSubview:self.rtcEAGLVideoView];
    self.rtcEAGLVideoView.frame = CGRectMake(0, 0, 100, 100);
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:(UIBarButtonItemStyleDone) target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

- (void)setUpData {
    self.sessionQueue = dispatch_queue_create("sessionQueue", DISPATCH_QUEUE_SERIAL);
    [self.wkWebView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.baidu.com/"]]];
    [self.displayLink setPaused:NO];
    
    self.frame = RcvCaptureFramePreset1280x720;
    [self.rtcTrack addRenderer:self.rtcEAGLVideoView];
    
    AVCaptureDevicePosition position = AVCaptureDevicePositionFront;
    AVCaptureDevice *device = [self findDeviceForPosition:position];
    
    AVCaptureDeviceFormat *format = [self selectFormatForDevice:device];
    int fps = [self selectFpsForFormat:format];
    [self.cameraVideoCapturer startCaptureWithDevice:device format:format fps:fps completionHandler:^(NSError * _Nonnull error) {
        
    }];
    
    [[RCVProcessBufferManager sharedManager] loadEffect];
}

#pragma mark - Capture WKWebView
- (void)displayDidRefresh:(CADisplayLink *)displayLink {
    if (@available(iOS 11.0, *)) {
        WKSnapshotConfiguration *snapshotConfiguration = [[WKSnapshotConfiguration alloc] init];
        snapshotConfiguration.snapshotWidth = @(720 / UIScreen.mainScreen.scale);
        if (@available(iOS 13.0, *)) {
            snapshotConfiguration.afterScreenUpdates = NO;
        }
        __weak typeof(self)weakSelf = self;
        [self.wkWebView takeSnapshotWithConfiguration:snapshotConfiguration completionHandler:^(UIImage * _Nullable snapshotImage, NSError * _Nullable error) {
            if (snapshotImage.CGImage != nil) {
                dispatch_async(self.convertPixelBufferQueue, ^{
                    size_t width = snapshotImage.size.width * UIScreen.mainScreen.scale;
                    size_t height = snapshotImage.size.height * UIScreen.mainScreen.scale;

                    CGFloat scale = [RcvCVPixelBufferScaler scaleFactorWidth:width andHeight:height];
                    width = width * scale;
                    height = height * scale;
                    width = width & ~1;
                    height = height & ~1;
                    
                    @autoreleasepool {
                        CIImage *tempCIImage = [[CIImage alloc] initWithImage:snapshotImage];
                        
                        UIImage *reSizedCGImage = [ReSizeImageHelper resizedImage4WithImage:tempCIImage scale:scale aspectRatio:1.0];

                        CVPixelBufferRef pixelBuffer = [self.pixelBufferConverter createPixelBufferFromPoolWithCIImage:[[CIImage alloc] initWithImage:reSizedCGImage] inContext:self.context size:CGSizeMake(width, height)];
                        
                        UIImage *image = [ImageHelper  imageWithPixelBuffer:pixelBuffer];
                        CVPixelBufferRelease(pixelBuffer);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.imageView.image = image;
                        });

//                        CVPixelBufferRelease(pixelBuffer);
                    }
                });
            }
//            weakSelf.imageView.image = snapshotImage;
        }];
    }
}

- (void) backAction {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (WKWebView *)wkWebView {
    if (!_wkWebView) {
        _wkWebView = [[WKWebView alloc] init];
        [_wkWebView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _wkWebView;
}

- (UIImageView *) imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [_imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _imageView;
}

- (CADisplayLink *)displayLink {
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayDidRefresh:)];
        _displayLink.preferredFramesPerSecond = 10;
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _displayLink;
}

- (RcvCVPixelBufferConverter *)pixelBufferConverter {
    if (!_pixelBufferConverter) {
        _pixelBufferConverter = [[RcvCVPixelBufferConverter alloc] init];
    }
    return _pixelBufferConverter;
}

- (dispatch_queue_t)convertPixelBufferQueue {
    if (!_convertPixelBufferQueue) {
        _convertPixelBufferQueue = dispatch_queue_create("com.ringcentral.convert.image.to.pixelbuffer", DISPATCH_QUEUE_SERIAL);
    }
    return _convertPixelBufferQueue;
}

- (CIContext *)context {
    if (!_context) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[kCIContextUseSoftwareRenderer] = @(NO);
        dic[kCIContextCacheIntermediates] = @(NO);
        if (@available(iOS 12.0, *)) {
            dic[kCIContextName] = @"com.ringcentral.convert.image.to.pixelbuffer";
        }
        _context = [CIContext contextWithOptions:dic];
    }
    return _context;
}

- (CIFilter *)filter {
    if (!_filter) {
        if (@available(iOS 13.0, *)) {
            _filter = [CIFilter lanczosScaleTransformFilter];
        } else {
            _filter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
        }
    }
    return _filter;
}

#pragma mark - WebRTC
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.rtcEAGLVideoView.frame = CGRectMake(CGRectGetMaxX(self.wkWebView.frame) - 120, CGRectGetMaxY(self.wkWebView.frame) - 150, 100, 130);
}

- (AVCaptureDevice *)findDeviceForPosition:(AVCaptureDevicePosition)position {
    NSArray<AVCaptureDevice *> *captureDevices = [RTCCameraVideoCapturer captureDevices];
    for (AVCaptureDevice *device in captureDevices) {
        
        if (device.position == position) {
            return device;
        }
    }
    return captureDevices[0];
}

- (AVCaptureDeviceFormat *)selectFormatForDevice:(AVCaptureDevice *)device {
    NSArray<AVCaptureDeviceFormat *> *formats =
    [RTCCameraVideoCapturer supportedFormatsForDevice:device];
    int targetWidth = 0;
    int targetHeight = 0;
    
    switch (self.frame) {
        case RcvCaptureFramePreset352X288:
            targetWidth = 352;
            targetHeight = 288;
            break;
        case RcvCaptureFramePreset640X480:
            targetWidth = 640;
            targetHeight = 480;
            break;
        case RcvCaptureFramePreset960X540:
            targetWidth = 960;
            targetHeight = 540;
            break;
        case RcvCaptureFramePreset1280x720:
            targetWidth = 1280;
            targetHeight = 720;
            break;
    }
    
    AVCaptureDeviceFormat *selectedFormat = nil;
    int currentDiff = INT_MAX;
    
    for (AVCaptureDeviceFormat *format in formats) {
        CMVideoDimensions dimension = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
        int diff = abs(targetWidth - dimension.width) + abs(targetHeight - dimension.height);
        if (diff < currentDiff) {
            selectedFormat = format;
            currentDiff = diff;
        }
    }
    
    NSAssert(selectedFormat != nil, @"No suitable capture format found.");
    return selectedFormat;
}

- (int)selectFpsForFormat:(AVCaptureDeviceFormat *)format {
    Float64 maxFramerate = 0;
    for (AVFrameRateRange *fpsRange in format.videoSupportedFrameRateRanges) {
        if (fpsRange.minFrameRate < 30 && fpsRange.maxFrameRate >= 30) {
            maxFramerate = 30;
        } else {
            maxFramerate = fmax(maxFramerate, fpsRange.maxFrameRate);
        }
    }
    return (int)maxFramerate;
}

- (RTCCameraVideoCapturer *) cameraVideoCapturer {
    if (!_cameraVideoCapturer) {
        _cameraVideoCapturer = [[RTCCameraVideoCapturer alloc] initWithDelegate:self.forWardVideoSource];
    }
    return _cameraVideoCapturer;
}

- (POCEAGLVideoView *) rtcEAGLVideoView {
    if (!_rtcEAGLVideoView) {
        _rtcEAGLVideoView = [[POCEAGLVideoView alloc] init];
    }
    return _rtcEAGLVideoView;
}

- (RTCVideoSource *) videoSource {
    if (!_videoSource) {
        _videoSource = [self.factory videoSource];
    }
    return _videoSource;
}

- (RTCPeerConnectionFactory *) factory {
    if (!_factory) {
        id<RTCVideoEncoderFactory> encoderFactory = [[RTCDefaultVideoEncoderFactory alloc] init];
        id<RTCVideoDecoderFactory> decoderFactory = [[RTCDefaultVideoDecoderFactory alloc] init];
        _factory = [[RTCPeerConnectionFactory alloc] initWithEncoderFactory:encoderFactory
                                                                 decoderFactory:decoderFactory];
    }
    return _factory;
}

- (RTCVideoTrack *)rtcTrack {
    if (!_rtcTrack) {
        _rtcTrack = [self.factory videoTrackWithSource:self.forWardVideoSource.forWardTarget trackId:@"com.piaojin.WebRTCViewController"];
    }
    return _rtcTrack;
}

- (RCVAIForwardVideoSource *)forWardVideoSource {
    if (!_forWardVideoSource) {
        _forWardVideoSource = [[RCVAIForwardVideoSource alloc] initWithDelegate:self.videoSource];
        _forWardVideoSource.pixelBufferProcesser = [RCVProcessBufferManager sharedManager].pixelBufferProcesser;
    }
    return _forWardVideoSource;
}

#pragma mark - OEP

- (CVPixelBufferRef _Nullable)processBuffer:(CVPixelBufferRef) pixelBuffer {
    CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);

    CGSize size = CGSizeMake(width, height);
    EpImageFormat imageFormat;
    imageFormat.imageSize = size;
    imageFormat.orientation = EPOrientationAngles270;
    imageFormat.resultedImageOrientation = EPOrientationAngles90;
    imageFormat.faceOrientation = 0;
    imageFormat.needAlphaInOutput = YES;
    imageFormat.isMirrored = NO;
    imageFormat.isYFlip = NO;

    // NOTE: the processY method will return object with CF_RETURNS_RETAINED, so need to release the object out side.
    CVPixelBufferRef resPixelBuffer = [self.effectPlayer processImage:pixelBuffer withFormat:&imageFormat];
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    return resPixelBuffer;
}

- (BNBOffscreenEffectPlayer *) effectPlayer {
    return [RCVProcessBufferManager sharedManager].effectPlayer;
}

- (void)dealloc {
    [_displayLink setPaused:YES];
    [_displayLink invalidate];
    [_cameraVideoCapturer stopCapture];
//    [_effectPlayer unloadEffect];
//    _effectPlayer = nil;
}

@end

//
//  WebRTCViewController.m
//  OCCaptureDemo
//
//  Created by rcadmin on 2020/12/30.
//

#import "WebRTCViewController.h"
#import <WebRTC/WebRTC.h>
#import "RCVAIForwardVideoSource.h"
#import "RCVProcessBufferManager.h"
#import "OCCaptureDemo-Swift.h"
#import "RcvXVbgModel.h"
#import "POCEAGLVideoView.h"

typedef NS_ENUM(NSInteger, RcvCaptureFrame) {
    RcvCaptureFramePreset352X288,
    RcvCaptureFramePreset640X480,
    RcvCaptureFramePreset960X540,
    RcvCaptureFramePreset1280x720,
};

@interface WebRTCViewController()<SelfPreviewBeautyEditViewDelegate>

@property (nonatomic, strong) RTCCameraVideoCapturer *cameraVideoCapturer;
@property (nonatomic, strong) UIView <RTCVideoRenderer> *rtcEAGLVideoView;
@property (nonatomic, strong) UIView <RTCVideoRenderer> *rtcTransparencyVideoView;
@property (nonatomic, strong) RTCVideoSource *videoSource;
@property (nonatomic, strong) RCVAIForwardVideoSource *forWardVideoSource;
@property (nonatomic, strong) RTCPeerConnectionFactory *factory;
@property (nonatomic, strong) RTCVideoTrack *rtcTrack;
@property (nonatomic, assign) RcvCaptureFrame frame;
@property (nonatomic, assign) BOOL shouldShowVBGPreview;
@property (nonatomic, strong) SelfPreviewBeautyEditView *beautyEditView;
@property (nonatomic, strong) NSMutableArray<RcvXVbgModel *> *effects;

@end

@implementation WebRTCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpView];
    [self setUpData];
}

- (void)setUpView {
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.rtcEAGLVideoView];
    self.rtcEAGLVideoView.frame = self.view.bounds;
    [self.view addSubview:self.rtcTransparencyVideoView];
    self.rtcTransparencyVideoView.frame = self.view.bounds;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:(UIBarButtonItemStyleDone) target:self action:@selector(closeAction)];
}

- (void)setUpData {
    self.frame = RcvCaptureFramePreset960X540;
    [self.rtcTrack addRenderer:self.rtcEAGLVideoView];
    
    AVCaptureDevicePosition position = AVCaptureDevicePositionFront;
    AVCaptureDevice *device = [self findDeviceForPosition:position];
    
    AVCaptureDeviceFormat *format = [self selectFormatForDevice:device];
    int fps = [self selectFpsForFormat:format];
    [self.cameraVideoCapturer startCaptureWithDevice:device format:format fps:fps completionHandler:^(NSError * _Nonnull error) {
        
    }];
    
//    [RcvBanubaVbgController.sharedInstance setEffect:@"Transparency"];
    
    [self loadEffectModels];
}

- (void)loadEffectModels {
    [self.effects addObjectsFromArray:[RcvBanubaVbgController.sharedInstance loadEffects]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.rtcEAGLVideoView.frame = self.view.bounds;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    self.shouldShowVBGPreview = !self.shouldShowVBGPreview;
    if (self.shouldShowVBGPreview) {
        [self.beautyEditView showInView:self.view];
        [self.beautyEditView updateBackgroundModels:self.effects];
    } else {
        [self.beautyEditView dismiss];
    }
}

- (void)closeAction {
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (UIView <RTCVideoRenderer> *) rtcEAGLVideoView {
    if (!_rtcEAGLVideoView) {
        _rtcEAGLVideoView = [[RTCEAGLVideoView alloc] init];
        [_rtcEAGLVideoView setHidden:YES];
    }
    return _rtcEAGLVideoView;
}

- (UIView <RTCVideoRenderer> *) rtcTransparencyVideoView {
    if (!_rtcTransparencyVideoView) {
        // POCEAGLVideoView support effect `Transparency`
        _rtcTransparencyVideoView = [[POCEAGLVideoView alloc] init];
        [_rtcTransparencyVideoView setHidden:YES];
    }
    return _rtcTransparencyVideoView;
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

- (SelfPreviewBeautyEditView *)beautyEditView {
    if (!_beautyEditView) {
        _beautyEditView = [[SelfPreviewBeautyEditView alloc] init];
        _beautyEditView.showingInfoLabel = YES;
        _beautyEditView.delegate = self;
    }
    return _beautyEditView;
}

- (NSMutableArray<RcvXVbgModel *> *)effects {
    if (!_effects) {
        _effects = [NSMutableArray<RcvXVbgModel *> array];
    }
    return _effects;
}

- (void)dealloc {
    [_cameraVideoCapturer stopCapture];
//    [[RcvBanubaVbgController sharedInstance] destroyEffectPlayer];
}

#pragma Mark - SelfPreviewBeautyEditViewDelegate

- (void)editView:(SelfPreviewBeautyEditView * _Nonnull)editView didRemoveBackgroundAt:(NSIndexPath * _Nonnull)indexPath {
    
}

- (void)editView:(SelfPreviewBeautyEditView * _Nonnull)editView didSelectBackgroundAt:(NSIndexPath * _Nonnull)indexPath {
    RcvXVbgModel *model = self.effects[indexPath.row];
    
    BOOL isUsingTransparency = [model.effectName isEqualToString:@"Transparency"];
    [self.rtcTransparencyVideoView setHidden:!isUsingTransparency];
    [self.rtcEAGLVideoView setHidden:isUsingTransparency];
    
    if (isUsingTransparency) {
        [self.rtcTrack removeRenderer:self.rtcEAGLVideoView];
        [self.rtcTrack addRenderer:self.rtcTransparencyVideoView];
    } else {
        [self.rtcTrack removeRenderer:self.rtcTransparencyVideoView];
        [self.rtcTrack addRenderer:self.rtcEAGLVideoView];
    }
    
    switch (model.type) {
        case RcvVbgBackgroundTypeEFFECT:
            [RcvBanubaVbgController.sharedInstance setEffect:model.effectName];
            break;
        case RcvVbgBackgroundTypeDEFAULT:
            [RcvBanubaVbgController.sharedInstance setEffect:model.effectName];
            [RcvBanubaVbgController.sharedInstance setVirtualBackground:[NSString stringWithFormat:@"/%@", model.imagePath]];
            break;
        case RcvVbgBackgroundTypeNONE:
//            [RcvBanubaVbgController.sharedInstance enableVirtualBackground:NO];
//            [RcvBanubaVbgController.sharedInstance enableBlurBackground:NO];
            [RcvBanubaVbgController.sharedInstance destroyEffectPlayer];
            break;
        case RcvVbgBackgroundTypeCUSTOM:
            [RcvBanubaVbgController.sharedInstance setEffect:model.effectName];
            [RcvBanubaVbgController.sharedInstance setVirtualBackground:model.imagePath];
            break;
            
        case RcvVbgBackgroundTypeMORE:
            break;
    }
}

- (void)editViewWillDismiss:(SelfPreviewBeautyEditView * _Nonnull)editView {
    
}

@end

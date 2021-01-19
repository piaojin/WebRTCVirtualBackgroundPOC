//
//  WebRTCViewController.m
//  OCCaptureDemo
//
//  Created by rcadmin on 2020/12/30.
//

#import "WebRTCViewController.h"
#import <WebRTC/WebRTC.h>

typedef NS_ENUM(NSInteger, RcvCaptureFrame) {
    RcvCaptureFramePreset352X288,
    RcvCaptureFramePreset640X480,
    RcvCaptureFramePreset960X540,
    RcvCaptureFramePreset1280x720,
};

@interface WebRTCViewController ()

@property (nonatomic, strong) RTCCameraVideoCapturer *cameraVideoCapturer;
@property (nonatomic, strong) RTCEAGLVideoView *rtcEAGLVideoView;
@property (nonatomic, strong) RTCVideoSource *videoSource;
@property (nonatomic, strong) RTCPeerConnectionFactory *factory;
@property (nonatomic, strong) RTCVideoTrack *rtcTrack;
@property (nonatomic, assign) RcvCaptureFrame frame;

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
}

- (void)setUpData {
    self.frame = RcvCaptureFramePreset1280x720;
    [self.rtcTrack addRenderer:self.rtcEAGLVideoView];
    
    AVCaptureDevicePosition position = AVCaptureDevicePositionFront;
    AVCaptureDevice *device = [self findDeviceForPosition:position];
    
    AVCaptureDeviceFormat *format = [self selectFormatForDevice:device];
    int fps = [self selectFpsForFormat:format];
//    CMVideoDimensions dimension = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
//    CGFloat frameAspectRatio = (CGFloat)dimension.width / (CGFloat)dimension.height;
    [self.cameraVideoCapturer startCaptureWithDevice:device format:format fps:fps completionHandler:^(NSError * _Nonnull error) {
        
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.rtcEAGLVideoView.frame = self.view.bounds;
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
        _cameraVideoCapturer = [[RTCCameraVideoCapturer alloc] initWithDelegate:self.videoSource];
    }
    return _cameraVideoCapturer;
}

- (RTCEAGLVideoView *) rtcEAGLVideoView {
    if (!_rtcEAGLVideoView) {
        _rtcEAGLVideoView = [[RTCEAGLVideoView alloc] init];
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
        _rtcTrack = [self.factory videoTrackWithSource:self.videoSource trackId:@"com.piaojin.WebRTCViewController"];
    }
    return _rtcTrack;
}

- (void)dealloc {
    [_cameraVideoCapturer stopCapture];
}

@end

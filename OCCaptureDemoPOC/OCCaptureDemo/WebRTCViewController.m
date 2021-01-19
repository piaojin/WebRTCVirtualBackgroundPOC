//
//  WebRTCViewController.m
//  OCCaptureDemo
//
//  Created by rcadmin on 2020/12/30.
//

#import "WebRTCViewController.h"
#import <WebRTC/WebRTC.h>

@interface WebRTCViewController ()

@property (nonatomic, strong) RTCCameraVideoCapturer *cameraVideoCapturer;
@property (nonatomic, strong) RTCEAGLVideoView *rtcEAGLVideoView;
@property (nonatomic, strong) RTCVideoSource *videoSource;
@property (nonatomic, strong) RTCPeerConnectionFactory *factory;

@end

@implementation WebRTCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpView];
    [self setUpData];
}

- (void)setUpView {
    [self.view addSubview:self.rtcEAGLVideoView];
    self.rtcEAGLVideoView.frame = self.view.bounds;
}

- (void)setUpData {
//    RTCVideoTrack *rtcTrack = [self.factory videoTrackWithSource:rcvSource.rtcSource trackId:label];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.rtcEAGLVideoView.frame = self.view.bounds;
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

@end

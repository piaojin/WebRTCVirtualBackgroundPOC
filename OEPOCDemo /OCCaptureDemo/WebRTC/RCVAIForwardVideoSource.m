//
//  RCVAIForwardVideoSource.m
//  rcv
//
//  Created by Zoey Weng on 2020/12/8.
//  Copyright © 2020 RingCentral. All rights reserved.
//

#import "RCVProcessPixelBufferProtocol.h"
#import "RCVAIForwardVideoSource.h"
#import "RCVProcessBufferManager.h"

@interface RTCVideoFrame (orentation)

- (void)fixFrameRotation:(UIInterfaceOrientation)statusBarOrientation usingFrontCamera:(BOOL)isFrontCamera;
 
@end

@implementation RTCVideoFrame (orentation)

- (void)fixFrameRotation:(UIInterfaceOrientation)statusBarOrientation usingFrontCamera:(BOOL)isFrontCamera {
    RTCVideoRotation rotation = RTCVideoRotation_90;
    switch (statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
            rotation = RTCVideoRotation_90;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            rotation = RTCVideoRotation_270;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            rotation = isFrontCamera ? RTCVideoRotation_0 : RTCVideoRotation_180;
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotation = isFrontCamera ? RTCVideoRotation_180 : RTCVideoRotation_0;
            break;
        default:
            break;
    }
    [self setValue:[NSNumber numberWithInt:(int)rotation] forKeyPath:@"rotation"];
}

@end

@implementation RCVAIForwardVideoSource {
    UIInterfaceOrientation _orientation;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithDelegate:(id<RTCVideoCapturerDelegate>)forWardTarget {
    if (self = [super init]) {
        _forWardTarget = forWardTarget;
        _orientation = UIInterfaceOrientationPortrait;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(statusBarOrientationDidChange:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    return self;
}

- (void)capturer: (RTCVideoCapturer *)capturer didCaptureVideoFrame: (RTCVideoFrame *)frame {
    // Fix frame ortation for RTCVideoRotation_270
    [frame fixFrameRotation:_orientation usingFrontCamera:[self isUsingFrontCamera:capturer]];
    if ([self.pixelBufferProcesser shouldProcessFrameBuffer]) {
        CVPixelBufferRef pixelBuffer = nil;
        // Get pixelBuffer.
        if ([frame.buffer isKindOfClass:RTCCVPixelBuffer.class]) {
            RTCCVPixelBuffer *rtcCVPixelBuffer = (RTCCVPixelBuffer *)frame.buffer;
            if (rtcCVPixelBuffer != nil) {
                pixelBuffer = rtcCVPixelBuffer.pixelBuffer;
            }
        }
        
        // Process pixelBuffer.
        if ([self.pixelBufferProcesser respondsToSelector:@selector(processBuffer:)]) {
            if (pixelBuffer != nil) {
                CVPixelBufferRef tempPixelBuffer = [self.pixelBufferProcesser processBuffer:pixelBuffer];
                
                if (tempPixelBuffer != nil) {
                    pixelBuffer = tempPixelBuffer;
                } else {
                    NSLog(@"tempPixelBuffer is nil");
                }
            }
        }
        
        // Forward frame to RTCVideoSource.
        if ([self.forWardTarget respondsToSelector:@selector(capturer:didCaptureVideoFrame:)]) {
            if (pixelBuffer != nil) {
                RTCVideoRotation rotation = frame.rotation;
                if (rotation == RTCVideoRotation_270) {
                    rotation = RTCVideoRotation_0;
                }
                RTCCVPixelBuffer *rtcPixelBuffer = [[RTCCVPixelBuffer alloc] initWithPixelBuffer:pixelBuffer];
                RTCVideoFrame *videoFrame = [[RTCVideoFrame alloc] initWithBuffer:rtcPixelBuffer
                                                          rotation: rotation
                                                       timeStampNs:frame.timeStampNs];
                // NOTE: the processY method will return object with CF_RETURNS_RETAINED, so need to release the object here or will cause memory leak.
                CVPixelBufferRelease(pixelBuffer);
                [self.forWardTarget capturer:capturer didCaptureVideoFrame:videoFrame];
            } else {
                // If Process LD flag is off(then _pixelBufferProcesser = NO) then just pass the original frame to RTCVideoSource.
                [self.forWardTarget capturer:capturer didCaptureVideoFrame:frame];
            }
        }
    } else {
        RTCCVPixelBuffer *buffer = (RTCCVPixelBuffer *)frame.buffer;
        [self.forWardTarget capturer:capturer didCaptureVideoFrame:frame];
    }
}

- (BOOL)isUsingFrontCamera: (RTCVideoCapturer *)capture {
    RTCCameraVideoCapturer *cameraCapture = (RTCCameraVideoCapturer *)capture;
    if (cameraCapture) {
        AVCaptureDeviceInput *deviceInput = (AVCaptureDeviceInput *)cameraCapture.captureSession.inputs.firstObject;
        return AVCaptureDevicePositionFront == deviceInput.device.position;
    }
    return true;
}

- (void)statusBarOrientationDidChange:(NSNotification *)notification {
    _orientation = UIApplication.sharedApplication.statusBarOrientation;
}

@end


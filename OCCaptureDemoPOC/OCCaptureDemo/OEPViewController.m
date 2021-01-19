//
//  OEPViewController.m
//  OCCaptureDemo
//
//  Created by rcadmin on 2020/12/29.
//

#import "OEPViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <BanubaEffectPlayer/BanubaEffectPlayer.h>
#import "OCCaptureDemo-Swift.h"

@interface OEPViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureVideoDataOutput *output;
@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nullable, nonatomic, strong) BNBOffscreenEffectPlayer *effectPlayer;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) BOOL loadingEffect;
@property (nonatomic, assign) AVCaptureVideoOrientation outputVideoOrientation;
@property (nonatomic, assign) AVCaptureDevicePosition cameraPosition;
 
@end

@implementation OEPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpView];
    [self setUp];
    [self start];
}

- (void) setUp {
    self.sessionQueue = dispatch_queue_create("sessionQueue", DISPATCH_QUEUE_SERIAL);
    _outputVideoOrientation = AVCaptureVideoOrientationLandscapeRight;
    _cameraPosition = AVCaptureDevicePositionFront;
    
    if ([self.captureSession canSetSessionPreset:(AVCaptureSessionPreset1280x720)]) {
        [self.captureSession setSessionPreset:AVCaptureSessionPreset1280x720];
    }
    
    [self.captureSession beginConfiguration];
    
    //add video input to AVCaptureSession
    if([self.captureSession canAddInput:self.input]){
        [self.captureSession addInput:self.input];
    }
    
    [self.output setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    [self.output setSampleBufferDelegate:self queue:self.sessionQueue];
    
    //add video data output to capture session
    if([self.captureSession canAddOutput:self.output]){
        [self.captureSession addOutput:self.output];
    }
    
    //setting orientaion
    AVCaptureConnection *connection = [self.output connectionWithMediaType:AVMediaTypeVideo];
    [connection setVideoMirrored:YES];
    [connection setVideoOrientation:self.outputVideoOrientation];

    [self.captureSession commitConfiguration];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.loadingEffect = YES;
        [self.effectPlayer loadEffect:@"transparency" completion:^{
            self.loadingEffect = NO;
        }];
    });
}

- (void) setUpView {
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.imageView];
    [[self.imageView.topAnchor constraintEqualToAnchor:self.view.topAnchor] setActive:YES];
    [[self.imageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
    [[self.imageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor] setActive:YES];
    [[self.imageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor] setActive:YES];
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:(UIBarButtonItemStyleDone) target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

- (void) backAction {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)start {
    [self.captureSession startRunning];
}

-(void)stop {
    [self.captureSession stopRunning];
}

- (EPOrientation) getImageOrientation {
    if (self.outputVideoOrientation == AVCaptureVideoOrientationLandscapeRight) {
        return self.cameraPosition == AVCaptureDevicePositionFront ? EPOrientationAngles270 : EPOrientationAngles90;
    } else if (self.outputVideoOrientation == AVCaptureVideoOrientationLandscapeLeft) {
        return self.cameraPosition == AVCaptureDevicePositionFront ? EPOrientationAngles270 : EPOrientationAngles90;
    } else if (self.outputVideoOrientation == AVCaptureVideoOrientationPortrait) {
        return EPOrientationAngles0;
    }
    return EPOrientationAngles180;
}

- (AVCaptureSession *) captureSession {
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
    }
    return _captureSession;
}

- (AVCaptureDeviceInput *) input {
    if (!_input) {
        NSError *error = nil;
        _input = [[AVCaptureDeviceInput alloc] initWithDevice:[AVCaptureDevice defaultDeviceWithDeviceType:(AVCaptureDeviceTypeBuiltInWideAngleCamera) mediaType:AVMediaTypeVideo position: self.cameraPosition] error:&error];
        if (error) {
            NSLog(@"Can not init AVCaptureDeviceInput");
        }
    }
    return _input;
}

- (AVCaptureVideoDataOutput *) output {
    if (!_output) {
        _output = [[AVCaptureVideoDataOutput alloc] init];
        _output.alwaysDiscardsLateVideoFrames = YES;
        [_output setVideoSettings: [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey]];
    }
    return _output;
}

- (BNBOffscreenEffectPlayer *) effectPlayer {
    if (!_effectPlayer) {
        _effectPlayer = [[BNBOffscreenEffectPlayer alloc] initWithEffectWidth:720 andHeight:1280 manualAudio: NO];
    }
    return _effectPlayer;
}

- (UIImageView *) imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [_imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _imageView;
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (!self.loadingEffect) {
        CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
        [self processBuffer:pixelBuffer];
    }
}

- (void)processBuffer:(CVPixelBufferRef) pixelBuffer {
    CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);

    CGSize size = CGSizeMake(width, height);
    EpImageFormat imageFormat;
    imageFormat.imageSize = size;
    imageFormat.orientation = [self getImageOrientation];
    imageFormat.resultedImageOrientation = EPOrientationAngles90;
    imageFormat.faceOrientation = 0;
    imageFormat.needAlphaInOutput = YES;
    imageFormat.isMirrored = NO;
    imageFormat.isYFlip = NO;

    // NOTE: the processY method will return object with CF_RETURNS_RETAINED, so need to release the object out side.
    CVPixelBufferRef resPixelBuffer = [self.effectPlayer processImage:pixelBuffer withFormat:&imageFormat];
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    
    if (resPixelBuffer != nil) {
        UIImage *image = [ImageHelper  imageWithPixelBuffer:resPixelBuffer];
        CVPixelBufferRelease(resPixelBuffer);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = image;
        });
    }
}

- (void)dealloc {
    [_effectPlayer unloadEffect];
    _effectPlayer = nil;
}

@end


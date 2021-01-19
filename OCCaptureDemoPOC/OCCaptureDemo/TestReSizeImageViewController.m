//
//  TestReSizeImageViewController.m
//  OCCaptureDemo
//
//  Created by rcadmin on 2021/1/11.
//

#import "TestReSizeImageViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "OCCaptureDemo-Swift.h"

#import "RcvCVPixelBufferUtils.h"

@interface TestReSizeImageViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureVideoDataOutput *output;
@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) AVCaptureVideoOrientation outputVideoOrientation;
@property (nonatomic, assign) AVCaptureDevicePosition cameraPosition;


@property (nonatomic, strong) RcvCVPixelBufferConverter *pixelBufferConverter;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) CIContext *context;
@property (nonatomic, strong) RcvCVPixelBufferScaler *scaler;
 
@end

@implementation TestReSizeImageViewController

- (RcvCVPixelBufferConverter *)pixelBufferConverter {
    if (!_pixelBufferConverter) {
        _pixelBufferConverter = [[RcvCVPixelBufferConverter alloc] init];
    }
    return _pixelBufferConverter;
}

- (RcvCVPixelBufferScaler *)scaler {
    if (!_scaler) {
        _scaler = [[RcvCVPixelBufferScaler alloc] init];
    }
    return _scaler;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _image = [UIImage imageNamed:@"shotcut4"];
//    _context = [CIContext contextWithOptions:@{kCIContextPriorityRequestLow: [NSNumber numberWithBool:NO], kCIContextUseSoftwareRenderer: [NSNumber numberWithBool:NO]}];
    _context = [CIContext context];
    
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

- (UIImageView *) imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [_imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _imageView;
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    
    CGFloat minRatio = MIN(1280 / self.image.size.height, 720 / self.image.size.width);
    CGSize toSize = CGSizeMake(self.image.size.width * minRatio, self.image.size.height * minRatio);
    
    // 1
    UIImage *image = [ReSizeImageHelper resizedImage1WithImage:self.image for:toSize];
    
    // 2
//    UIImage *image = [ReSizeImageHelper resizedImage2WithImage:self.image.CGImage for:toSize];
    
    // 3
//    UIImage *image = [ReSizeImageHelper resizedImage3WithImage:self.image for:toSize];
    
    // 4 best
//    CIImage *ciimage = [CIImage imageWithCGImage:self.image.CGImage];
//    UIImage *image = [ReSizeImageHelper resizedImage4WithImage:ciimage scale:minRatio aspectRatio:1.0];
    
    // 5
//    UIImage *image = [ReSizeImageHelper resizedImage5WithImage:self.image for:toSize];
    
    // 6
//    UIImage *image = [ReSizeImageHelper resizedImage6WithImage:self.image for:toSize];
    
    CVPixelBufferRef pixelBuffer = [self.pixelBufferConverter createPixelBufferFromPoolWithCIImage:[CIImage imageWithCGImage:image.CGImage] inContext:self.context size:image.size];
    
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    NSLog(@"%f", end - start);
    
    [self processBuffer:pixelBuffer];
}

- (void)processBuffer:(CVPixelBufferRef) pixelBuffer {
    UIImage *image = [ImageHelper imageWithPixelBuffer:pixelBuffer];
    CVPixelBufferRelease(pixelBuffer);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = image;
    });
}

@end

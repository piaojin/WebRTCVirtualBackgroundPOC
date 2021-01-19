//
//  TestCovertImageToBufferViewController.m
//  OCCaptureDemo
//
//  Created by rcadmin on 2021/1/11.
//

#import "TestCovertImageToBufferViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "OCCaptureDemo-Swift.h"

#import "RcvCVPixelBufferUtils.h"

@implementation PixelBufferModel

- (void)dealloc {
    CVPixelBufferRelease(_pixelBuffer);
    CFRelease(_backingData);
}

@end

@interface TestCovertImageToBufferViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>

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
 
@end

@implementation TestCovertImageToBufferViewController

- (RcvCVPixelBufferConverter *)pixelBufferConverter {
    if (!_pixelBufferConverter) {
        _pixelBufferConverter = [[RcvCVPixelBufferConverter alloc] init];
    }
    return _pixelBufferConverter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _image = [UIImage imageNamed:@"shotcut4"];
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
    
    // 1 best
    CVPixelBufferRef pixelBuffer = [self.pixelBufferConverter createPixelBufferFromPoolWithCIImage:[CIImage imageWithCGImage:self.image.CGImage] inContext:self.context size:self.image.size];
    
    // 2
//    CVPixelBufferRef pixelBuffer = [self.pixelBufferConverter createPixelBufferWithCIImage:[CIImage imageWithCGImage:self.image.CGImage] inContext:self.context size:self.image.size];
    
    // 3
//    CVPixelBufferRef pixelBuffer = [self.pixelBufferConverter createPixelBufferWithCGImageViavImage:self.image.CGImage];
    
    // 4
//    CVPixelBufferRef pixelBuffer = [self.pixelBufferConverter createPixelBufferFromPoolWithCGImage:self.image.CGImage];
    
    // 5
//    CVPixelBufferRef pixelBuffer = [self.pixelBufferConverter createPixelBufferWithImage:self.image];
    
    // 6
//    CVPixelBufferRef pixelBuffer = [self.pixelBufferConverter createPixelBufferWithCGImage:self.image.CGImage];
    
    // 7, will crash above iOS 11.x
//    dispatch_async(dispatch_get_main_queue(), ^{
//        PixelBufferModel *model = [self createPixelBufferWithCGImage:self.image.CGImage];
//        UIImage *image = [ImageHelper imageWithPixelBuffer:model.pixelBuffer];
//        self.imageView.image = image;
//    });
    
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    NSLog(@"%f", end - start);
    
    [self processBuffer:pixelBuffer];
    CVPixelBufferRelease(pixelBuffer);
}

- (void)processBuffer:(CVPixelBufferRef) pixelBuffer {
    UIImage *image = [ImageHelper imageWithPixelBuffer:pixelBuffer];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = image;
    });
}

- ( PixelBufferModel *) createPixelBufferWithCGImage: (CGImageRef) image {
    CVReturn status = kCVReturnSuccess;
    CVPixelBufferRef pixelBuffer = NULL;
    CFTypeRef backingData;

    CGDataProviderRef dataProvider = CGImageGetDataProvider(image);
    CFDataRef data = CGDataProviderCopyData(dataProvider);
    backingData = CFDataCreateMutableCopy(kCFAllocatorSystemDefault, CFDataGetLength(data), data);
    CFRelease(data);

    const UInt8 *bytePtr = CFDataGetBytePtr(backingData);

    status = CVPixelBufferCreateWithBytes(kCFAllocatorSystemDefault,
                                          CGImageGetWidth(image),
                                          CGImageGetHeight(image),
                                          kCVPixelFormatType_32BGRA,
                                          (void *)bytePtr,
                                          CGImageGetBytesPerRow(image),
                                          NULL,
                                          NULL,
                                          NULL,
                                          &pixelBuffer);
    NSParameterAssert(status == kCVReturnSuccess && pixelBuffer);
    PixelBufferModel *model = [[PixelBufferModel alloc] init];
    model.pixelBuffer = pixelBuffer;
    model.backingData = backingData;
    return model;
}

@end

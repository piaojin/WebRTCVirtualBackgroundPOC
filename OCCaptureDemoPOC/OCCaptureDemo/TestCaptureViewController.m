//
//  TestCaptureViewController.m
//  OCCaptureDemo
//
//  Created by rcadmin on 2021/1/11.
//

#import "TestCaptureViewController.h"
#import "OCCaptureDemo-Swift.h"
#import <WebKit/WebKit.h>
#import "CaptureViewHelper.h"

#import "RcvCVPixelBufferUtils.h"
@import CoreImage.CIFilterBuiltins;

@interface TestCaptureViewController ()

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

@implementation TestCaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _image = [UIImage imageNamed:@"shotcut4"];
    [self setUpView];
    [self setUp];
}

- (void) setUp {
    self.sessionQueue = dispatch_queue_create("sessionQueue", DISPATCH_QUEUE_SERIAL);
    [self.wkWebView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.baidu.com/"]]];
    [self.displayLink setPaused:NO];
}

- (void) setUpView {
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.wkWebView];
    [[self.wkWebView.topAnchor constraintEqualToAnchor:self.view.topAnchor] setActive:YES];
    [[self.wkWebView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor] setActive:YES];
    [[self.wkWebView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor] setActive:YES];
//    [[self.wkWebView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.5] setActive:YES];
    [[self.wkWebView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
    
//    [self.view addSubview:self.imageView];
//    [[self.imageView.topAnchor constraintEqualToAnchor:self.wkWebView.bottomAnchor] setActive:YES];
//    [[self.imageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
//    [[self.imageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor] setActive:YES];
//    [[self.imageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor] setActive:YES];
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:(UIBarButtonItemStyleDone) target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

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
//                            CIImage *reSizedCGImage = [self createCIImageWith:snapshotImage scale:scale aspectRatio:1.0];
                        
                        CIImage *tempCIImage = [[CIImage alloc] initWithImage:snapshotImage];
//
                        CVPixelBufferRef pixelBuffer = [self.pixelBufferConverter createPixelBufferFromPoolWithCIImage:tempCIImage inContext:self.context size:CGSizeMake(width, height)];
                        
//                            CVPixelBufferRef pixelBuffer = [self.pixelBufferConverter createPixelBufferWithImage:snapshotImage size:(CGSizeMake(width, height))];
                        
                        CVPixelBufferRelease(pixelBuffer);
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
        // kCIContextWorkingColorSpace: [NSNull null]
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

- (void)dealloc {
    [_displayLink setPaused:YES];
    [_displayLink invalidate];
}

@end

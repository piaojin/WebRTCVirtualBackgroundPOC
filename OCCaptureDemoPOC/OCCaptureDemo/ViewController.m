//
//  ViewController.m
//  OCCaptureDemo
//
//  Created by rcadmin on 2020/12/15.
//

#import "ViewController.h"
#import "OEPViewController.h"
#import "TestCaptureViewController.h"
#import "TestReSizeImageViewController.h"
#import "TestCovertImageToBufferViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpView];
}

- (void) setUpView {
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIStackView *stackView = [[UIStackView alloc] init];
    [stackView setTranslatesAutoresizingMaskIntoConstraints:NO];
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.distribution = UIStackViewDistributionFill;
    stackView.spacing = 10;
    
    [self.view addSubview:stackView];
    [[stackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor] setActive:YES];
    [[stackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor] setActive:YES];
    [[stackView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor] setActive:YES];
    
    UIButton *captureWKWebViewContentButton = [self createButtonWith:@"Capture WKWebView Content" action:@selector(captureWKWebViewContentAction:)];
    
    UIButton *reSizeImageButton = [self createButtonWith:@"Resize Image" action:@selector(reSizeImageAction:)];
    
    UIButton *convertImageToBufferButton = [self createButtonWith:@"Convert Image To Pixel Buffer" action:@selector(convertImageToBufferAction:)];
    
    [stackView addArrangedSubview:captureWKWebViewContentButton];
    [stackView addArrangedSubview:reSizeImageButton];
    [stackView addArrangedSubview:convertImageToBufferButton];
}

- (UIButton *) createButtonWith: (NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [button setTitle:title forState:(UIControlStateNormal)];
    [button setBackgroundColor:UIColor.systemBlueColor];
    [button setTranslatesAutoresizingMaskIntoConstraints:NO];
    [button addTarget:self action:action forControlEvents:(UIControlEventTouchUpInside)];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 6;
    [[button.heightAnchor constraintEqualToConstant:60] setActive:YES];
    return button;
}

- (void) startOEPAction: (UIButton *)sender {
    OEPViewController *viewController = [[OEPViewController alloc] init];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void) captureWKWebViewContentAction: (UIButton *)sender {
    TestCaptureViewController *viewController = [[TestCaptureViewController alloc] init];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void) reSizeImageAction: (UIButton *)sender {
    TestReSizeImageViewController *viewController = [[TestReSizeImageViewController alloc] init];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void) convertImageToBufferAction: (UIButton *)sender {
    TestCovertImageToBufferViewController *viewController = [[TestCovertImageToBufferViewController alloc] init];
    [self presentViewController:viewController animated:YES completion:nil];
}

@end


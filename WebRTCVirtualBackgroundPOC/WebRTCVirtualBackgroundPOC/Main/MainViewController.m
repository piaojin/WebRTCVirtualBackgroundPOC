//
//  MainViewController.m
//  WebRTCVirtualBackgroundPOC
//
//  Created by piaojin on 2020/12/15.
//

#import "MainViewController.h"
#import "WebRTCViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

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
    
    UIButton *webRTCButton = [self createButtonWith:@"Test" action:@selector(webRTCCaptureAction:)];
    
    [stackView addArrangedSubview:webRTCButton];
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
    [[button.widthAnchor constraintEqualToConstant:60] setActive:YES];
    return button;
}

- (void) webRTCCaptureAction: (UIButton *)sender {
    WebRTCViewController *viewController = [[WebRTCViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:nav animated:YES completion:nil];
}

@end


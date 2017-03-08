//
//  TodayViewController.m
//  ARReaderWidget
//
//  Created by Objective-C on 2017/2/28.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 300);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(-10, 0, [UIScreen mainScreen].bounds.size.width, 20)];
    label.text = @"Test Widget";
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(-10, 20,[UIScreen mainScreen].bounds.size.width , 20);
    [button setTitle:@"Test Button" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(changeFrame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    self.view.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeFrame)];
    [self.view addGestureRecognizer:tapView];
}

- (void)changeFrame
{
    self.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 200);
}

- (BOOL)isPortrait {
    BOOL screenIsPortrait = NO;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize nativeSize = [UIScreen mainScreen].currentMode.size;
    CGSize sizeInPoints = [UIScreen mainScreen].bounds.size;
    if (scale * sizeInPoints.width == nativeSize.width) {
        screenIsPortrait = YES;
    }
    return screenIsPortrait;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 10.0){
        self.extensionContext.widgetLargestAvailableDisplayMode =NCWidgetDisplayModeCompact;
    }
    self.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 110);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets
{
    return UIEdgeInsetsZero;
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    completionHandler(NCUpdateResultNewData);
}

@end

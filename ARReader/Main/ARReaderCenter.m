//
//  ARReaderCenter.m
//  ARReader
//
//  Created by Objective-C on 2017/2/9.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "ARReaderCenter.h"
#import "ARComposing.h"

#import "ARReaderMacros.h"

#import "ARReaderKit.h"

#import "ARReaderDataSource.h"

#import "ARMediator.h"
#import "ARMediator+Reader.h"

#import "UIView+Quick.h"

#import "ARGCD.h"

#import "ARBookIndicator.h"

#import <QMUIKit/QMUIKit.h>

@interface ARReaderCenter () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) ARReaderNavigation *readerNavigation;
@property (nonatomic, strong) ARReaderTool       *readerTool;
@property (nonatomic, strong) ARReaderView       *readerView;

@property (nonatomic, copy) NSString             *readerContent;
@property (nonatomic, copy) NSString             *readerCellIdentifier;
@property (nonatomic, strong) ARPageParser       *readerParser;
@property (nonatomic, strong) ARReaderDataSource *readerDataSource;

@property (nonatomic, strong) ARBookIndicator    *readerIndicator;

@end

@implementation ARReaderCenter

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithHexString:@"f4f6f7"];
    
    self.view.addSubview(self.readerView).addSubview(self.readerNavigation).addSubview(self.readerTool);
    
    [ARGCDQueue executeInGlobalQueue:^{
        self.readerDataSource.readerPages = [[ARMediator sharedInstance] Reader_parseContentWithParser:self.readerParser content:self.readerContent];
        [ARGCDQueue executeInMainQueue:^{
            [self.readerView reloadData];
        }];
    }];
    
    UITapGestureRecognizer *tapReader = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTest:)];
    [self.view addGestureRecognizer:tapReader];
}

- (void)tapTest:(UITapGestureRecognizer *)tap
{
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)dealloc
{
    [[ARMediator sharedInstance] Reader_cleanCollectionViewCellTarget];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)textViewDidSelectBegin:(ARTextView *)textView
{
    self.readerView.scrollEnabled = NO;
}

-(void)textViewDidSelectEnd:(ARTextView *)textView
{
    self.readerView.scrollEnabled = YES;
}

- (void)textViewDidSelectCancel:(ARTextView *)textView
{
    self.readerView.scrollEnabled = YES;
}


#pragma mark - Lazy Init(Custom)

- (ARReaderView *)readerView
{
    if (!_readerView) {
        _readerView = [[ARReaderView alloc] initWithCellIdentifier:@"PageCell"];
        _readerView.delegate = self;
        _readerView.dataSource = self.readerDataSource;
    }
    return _readerView;
}

- (UIView *)readerNavigation
{
    if (!_readerNavigation) {
        _readerNavigation = [[ARReaderNavigation alloc] init];
        _readerNavigation.hidden = YES;
    }
    return _readerNavigation;
}

- (UIView *)readerTool
{
    if (!_readerTool) {
        _readerTool = [[ARReaderTool alloc] init];
        _readerTool.hidden = YES;
    }
    return _readerTool;
}

- (NSString *)readerContent
{
    if (!_readerContent) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"tianzhubian" ofType:@"txt"];
        unsigned long encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSData *responseData = [NSData dataWithContentsOfFile:path];
        NSString *content = [[NSString alloc] initWithData:responseData encoding:encode];
        //        NSString *newPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"txt"];
        //        NSString *content = [[NSString alloc] initWithContentsOfFile:newPath encoding:NSUTF8StringEncoding error:nil];
        _readerContent = content;
    }
    return _readerContent;
}

- (ARPageParser *)readerParser
{
    if (!_readerParser) {
        _readerParser = [ARPageParser sharedInstance];
        _readerParser.fontSize = 21;
        _readerParser.titleLength = 11;
        _readerParser.indent = YES;
        _readerParser.pageSize = CGSizeMake(ScreenWidth - 30, ScreenHeight - 80);
        _readerParser.lineSpacing = 10;
        _readerParser.textAlignment = NSTextAlignmentJustified;
    }
    return _readerParser;
}

- (ARReaderDataSource *)readerDataSource
{
    if (!_readerDataSource) {
        _readerDataSource = [[ARReaderDataSource alloc] initWithCellIdentifier:@"PageCell" configureCellBlock:^(id cell, ARPageData *pageData) {
            [[ARMediator sharedInstance] Reader_configCollectionViewCell:cell pageData:pageData];
        }];
    }
    return _readerDataSource;
}

- (ARBookIndicator *)readerIndicator
{
    if (!_readerIndicator) {
        _readerIndicator = [[ARBookIndicator alloc]initWithStyle:ARBookIndicatorStyleNormal];
        _readerIndicator.frame = CGRectMake((ScreenWidth - 38)/2.0, (ScreenHeight - 30)/2.0, 48, 30);
    };
    return _readerIndicator;
}

@end

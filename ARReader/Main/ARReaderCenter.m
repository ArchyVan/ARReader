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
#import "ARMediator.h"
#import "ARMediator+Reader.h"

@interface ARReaderCenter () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIView            *readerNavigation;
@property (nonatomic, strong) UIView            *readerTool;

@property (nonatomic, copy) NSString            *readerContent;
@property (nonatomic, strong) NSArray           *readerPages;
@property (nonatomic, strong) UICollectionView  *readerView;
@property (nonatomic, strong) ARPageParser      *readerParser;

@end

@implementation ARReaderCenter

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithHexString:@"f4f6f7"];
    
    [self.view addSubview:self.readerView];
    [self.view addSubview:self.readerNavigation];
    [self.view addSubview:self.readerTool];
    
    self.readerPages = [[ARMediator sharedInstance] Reader_parseContentWithParser:self.readerParser content:self.readerContent];
    [self.readerView reloadData];
}

- (void)dealloc
{
    [[ARMediator sharedInstance] Reader_cleanCollectionViewCellTarget];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.readerPages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [[ARMediator sharedInstance] Reader_cellWithIdentifier:@"PageCell" collectionView:collectionView indexPath:indexPath];
    ARPageData *pageData = [self.readerPages objectAtIndex:indexPath.item];
    [[ARMediator sharedInstance] Reader_configCollectionViewCell:cell pageData:pageData];
    return cell;
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

#pragma mark - Lazy Init

- (UICollectionView *)readerView
{
    if (!_readerView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(ScreenWidth, ScreenHeight - 80);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _readerView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 40, ScreenWidth, ScreenHeight - 80) collectionViewLayout:layout];
        _readerView.pagingEnabled = YES;
        _readerView.backgroundColor = [UIColor colorWithHexString:@"f4f6f7"];
        _readerView.delegate = self;
        _readerView.dataSource = self;
        _readerView.clipsToBounds = NO;
        _readerView.showsVerticalScrollIndicator = NO;
        _readerView.showsHorizontalScrollIndicator = NO;
        [_readerView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"PageCell"];
    }
    return _readerView;
}

- (UIView *)readerNavigation
{
    if (!_readerNavigation) {
        _readerNavigation = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
        _readerNavigation.backgroundColor = [UIColor whiteColor];
        _readerNavigation.layer.shadowColor = [UIColor blackColor].CGColor;
        _readerNavigation.layer.shadowOffset = CGSizeMake(0, 1);
        _readerNavigation.layer.shadowRadius = 4;
        _readerNavigation.layer.shadowOpacity = 0.05;
        _readerNavigation.clipsToBounds = NO;
        _readerNavigation.hidden = YES;
    }
    return _readerNavigation;
}

- (UIView *)readerTool
{
    if (!_readerTool) {
        _readerTool = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 44, ScreenWidth, 44)];
        _readerTool.backgroundColor = [UIColor whiteColor];
        _readerTool.layer.shadowColor = [UIColor blackColor].CGColor;
        _readerTool.layer.shadowOffset = CGSizeMake(0, 1);
        _readerTool.layer.shadowRadius = 4;
        _readerTool.layer.shadowOpacity = 0.05;
        _readerTool.clipsToBounds = NO;
        _readerTool.hidden = YES;
    }
    return _readerTool;
}

- (NSString *)readerContent
{
    if (!_readerContent) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"sishen" ofType:@"txt"];
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
        _readerParser.titleLength = 2;
        _readerParser.indent = YES;
        _readerParser.pageSize = CGSizeMake(ScreenWidth - 30, ScreenHeight - 80);
        _readerParser.lineSpacing = 10;
        _readerParser.textAlignment = NSTextAlignmentJustified;
    }
    return _readerParser;
}


@end

//
//  ARReaderKit.m
//  ARReader
//
//  Created by Objective-C on 2017/2/15.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "ARReaderKit.h"
#import "UIColor+Reader.h"

@implementation ARReaderView

- (instancetype)initWithCellIdentifier:(NSString *)cellIdentifier
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(ScreenWidth, ScreenHeight - 80);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self = [super initWithFrame:CGRectMake(0, 40, ScreenWidth, ScreenHeight - 80) collectionViewLayout:layout];
    if (self) {
        self.pagingEnabled = YES;
        self.backgroundColor = [UIColor colorWithHexString:@"f4f6f7"];
        self.clipsToBounds = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithCellIdentifier:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithCellIdentifier:nil];
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    return [self initWithCellIdentifier:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithCellIdentifier:nil];
}

@end

@implementation ARReaderNavigation

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 1);
        self.layer.shadowRadius = 4;
        self.layer.shadowOpacity = 0.05;
        self.clipsToBounds = NO;
    }
    return self;
}

@end

@implementation ARReaderTool

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, ScreenHeight - 49, ScreenWidth, 49)];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, -1);
        self.layer.shadowRadius = 4;
        self.layer.shadowOpacity = 0.05;
        self.clipsToBounds = NO;
    }
    return self;
}

@end

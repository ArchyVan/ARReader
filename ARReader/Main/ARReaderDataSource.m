//
//  ARReaderDataSource.m
//  ARReader
//
//  Created by Objective-C on 2017/2/15.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "ARReaderDataSource.h"

@interface ARReaderDataSource ()

@property (nonatomic, copy) NSString  *cellIdentifer;
@property (nonatomic, copy) ReaderCellConfigureBlock configureCellBlock;

@end

@implementation ARReaderDataSource

- (instancetype)initWithCellIdentifier:(NSString *)cellIdentifier configureCellBlock:(ReaderCellConfigureBlock)configureCellBlock
{
    self = [super init];
    if (self) {
        self.cellIdentifer = cellIdentifier;
        self.configureCellBlock = configureCellBlock;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithCellIdentifier:nil configureCellBlock:nil];
}

- (instancetype)pageDataAtIndexPath:(NSIndexPath *)indexPath
{
    return self.readerPages[indexPath.item];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.readerPages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [[ARMediator sharedInstance] Reader_cellWithIdentifier:self.cellIdentifer collectionView:collectionView indexPath:indexPath];
    ARPageData *pageData = [self.readerPages objectAtIndex:indexPath.item];
    self.configureCellBlock(cell,pageData);
    return cell;
}

@end

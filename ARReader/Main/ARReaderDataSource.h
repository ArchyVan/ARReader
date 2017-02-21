//
//  ARReaderDataSource.h
//  ARReader
//
//  Created by Objective-C on 2017/2/15.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARReaderMacros.h"
#import "ARMediator+Reader.h"

typedef void(^ReaderCellConfigureBlock)(id cell,ARPageData *pageData);

@interface ARReaderDataSource : NSObject <UICollectionViewDataSource>

@property (nonatomic, strong) NSArray *readerPages;

- (instancetype)initWithCellIdentifier:(NSString *)cellIdentifier configureCellBlock:(ReaderCellConfigureBlock)configureCellBlock AR_DESIGNATED_INITIALIZER;

- (instancetype)init AR_UNAVAILABLE_INSTEAD("initWithCellIdentifier:configureCellBlock:");

- (instancetype)pageDataAtIndexPath:(NSIndexPath *)indexPath;

@end

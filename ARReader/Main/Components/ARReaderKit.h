//
//  ARReaderKit.h
//  ARReader
//
//  Created by Objective-C on 2017/2/15.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARReaderMacros.h"

NS_ASSUME_NONNULL_BEGIN

/**
 阅读器主滚动视图
 */
@interface ARReaderView : UICollectionView

- (instancetype)initWithCellIdentifier:(nullable NSString *)cellIdentifier AR_DESIGNATED_INITIALIZER;

- (instancetype)init AR_UNAVAILABLE_INSTEAD("initWithCellIdentifier:");

- (instancetype)initWithFrame:(CGRect)frame AR_UNAVAILABLE_INSTEAD("initWithCellIdentifier:");

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout AR_UNAVAILABLE_INSTEAD("initWithCellIdentifier:");

- (instancetype)initWithCoder:(NSCoder *)aDecoder AR_UNAVAILABLE_INSTEAD("initWithCellIdentifier:");

@end

/**
 阅读器导航栏
 */
@interface ARReaderNavigation : UIView

@end

/**
 阅读器工具栏
 */
@interface ARReaderTool : UIView

@end

NS_ASSUME_NONNULL_END

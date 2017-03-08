//
//  ARMediator+Reader.h
//  ARReader
//
//  Created by Objective-C on 2017/2/15.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "ARMediator.h"
#import "ARComposing.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ARMediator (Reader)

- (UIViewController *)Reader_center;
- (NSArray *)Reader_parseContentWithParser:(ARPageParser *)parser content:(NSString *)content;

- (UICollectionViewCell *)Reader_cellWithIdentifier:(NSString *)identifier collectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

- (void)Reader_configCollectionViewCell:(UICollectionViewCell *)cell pageData:(ARPageData *)pageData;


- (void)Reader_cleanCollectionViewCellTarget;

@end

NS_ASSUME_NONNULL_END

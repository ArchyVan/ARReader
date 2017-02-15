//
//  ARMediator+Reader.m
//  ARReader
//
//  Created by Objective-C on 2017/2/15.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "ARMediator+Reader.h"
#import "ARReaderCenter.h"

NSString * const kARMediatorTargetReader = @"Reader";

NSString * const kARMediatorActionParseContent = @"parseContent";
NSString * const kARMediatorActionViewController = @"viewController";
NSString * const kARMediatorActionCell = @"readerCell";
NSString * const kARMediatorActionConfigCell = @"configReaderCell";

@implementation ARMediator (Reader)

- (UIViewController *)Reader_center
{
    ARReaderCenter *center = [self performTarget:kARMediatorTargetReader action:kARMediatorActionViewController params:nil shouldCacheTarget:NO];
    if ([center isKindOfClass:[UIViewController class]]) {
        return center;
    } else {
        return [[UIViewController alloc] init];
    }
}

- (NSArray *)Reader_parseContentWithParser:(ARPageParser *)parser content:(NSString *)content
{
    return [self performTarget:kARMediatorTargetReader
                        action:kARMediatorActionParseContent
                        params:@{
                                 @"parser":parser,
                                 @"content":content
                                 }
             shouldCacheTarget:YES];
}

- (UICollectionViewCell *)Reader_cellWithIdentifier:(NSString *)identifier collectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath
{
    return [self performTarget:kARMediatorTargetReader
                        action:kARMediatorActionCell
                        params:@{
                                 @"identifier":identifier,
                                 @"collectionView":collectionView,
                                 @"indexPath":indexPath
                                 }
             shouldCacheTarget:YES];
}

- (void)Reader_configCollectionViewCell:(UICollectionViewCell *)cell pageData:(ARPageData *)pageData
{
    [self performTarget:kARMediatorTargetReader
                 action:kARMediatorActionConfigCell
                 params:@{
                          @"cell":cell,
                          @"pageData":pageData
                          }
      shouldCacheTarget:YES];
}

- (void)Reader_cleanCollectionViewCellTarget
{
    [self releaseCachedTargetWithTargetName:kARMediatorTargetReader];
}

@end

//
//  ARTarget.m
//  ARReader
//
//  Created by Objective-C on 2017/2/15.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "ARTarget.h"
#import "ARComposing.h"

#import "ARReaderCenter.h"
#import "ARReaderMacros.h"

#import "UIView+Quick.h"

#import <QMUIKit/QMUIKit.h>

typedef void (^ARUrlRouterCallbackBlock)(NSDictionary *info);

@implementation Target_Reader

- (UIViewController *)Action_center:(NSDictionary *)params
{
    ARReaderCenter *center = [[ARReaderCenter alloc] init];
    return center;
}

- (NSArray *)Action_parseContent:(NSDictionary *)params
{
    ARPageParser *parser = params[@"parser"];
    NSString *content = params[@"content"];
    if (content.length == 0 || content == nil) {
        return nil;
    }
    return [parser parseContent:content];
}

- (id)Action_showAlert:(NSDictionary *)params
{
    QMUIAlertAction *cancelAction = [QMUIAlertAction actionWithTitle:@"cancel" style:QMUIAlertActionStyleCancel handler:^(QMUIAlertAction *action) {
        ARUrlRouterCallbackBlock callback = params[@"cancelAction"];
        if (callback) {
            callback(@{@"alertAction":action});
        }
    }];
    
    QMUIAlertAction *confirmAction = [QMUIAlertAction actionWithTitle:@"confirm" style:QMUIAlertActionStyleDefault handler:^(QMUIAlertAction * _Nonnull action) {
        ARUrlRouterCallbackBlock callback = params[@"confirmAction"];
        if (callback) {
            callback(@{@"alertAction":action});
        }
    }];
    
    QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:@"Reader" message:params[@"message"] preferredStyle:QMUIAlertControllerStyleAlert];
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    return nil;
}

- (UICollectionViewCell *)Action_readerCell:(NSDictionary *)params
{
    UICollectionView *collectionView = params[@"collectionView"];
    NSString *identifier = params[@"identifier"];
    NSIndexPath *indexPath = params[@"indexPath"];
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    return cell;
}

- (id)Action_configReaderCell:(NSDictionary *)params
{
    UICollectionViewCell *cell = params[@"cell"];
    cell.contentView.removeAllSubviews();
    ARPageData *pageData = params[@"pageData"];
    ARTextView *textView = [[ARTextView alloc] initWithFrame:CGRectMake(15, 0, ScreenWidth - 30, ScreenHeight - 80)];
    textView.pageData = pageData;
    textView.textColor = [UIColor colorWithHexString:@"#3A3D40"];
    textView.font = [UIFont systemFontOfSize:21];
    textView.indent = YES;
    textView.lineSpacing = 10;
    textView.editable = YES;
    textView.textAlignment = NSTextAlignmentJustified;
    textView.backgroundColor = [UIColor colorWithHexString:@"#F4F6F7"];
    [cell.contentView addSubview:textView];
    return nil;
}



@end

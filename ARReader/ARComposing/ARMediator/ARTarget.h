//
//  ARTarget.h
//  ARReader
//
//  Created by Objective-C on 2017/2/15.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Target_Reader : NSObject

- (UIViewController *)Action_center:(NSDictionary *)params;
- (NSArray *)Action_parseContent:(NSDictionary *)params;
- (id)Action_showAlert:(NSDictionary *)params;

//- (id)Action_nativeJumpPercent:(NSDictionary *)params;
//- (id)Action_nativeNoBook:(NSDictionary *)params;

- (UICollectionViewCell *)Action_readerCell:(NSDictionary *)params;
- (id)Action_configReaderCell:(NSDictionary *)params;

@end

//
//  ARGCDGroup.h
//  ARReader
//
//  Created by Objective-C on 2017/2/22.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 封装GCD 任务组
 */
@interface ARGCDGroup : NSObject

@property (nonatomic, readonly, strong) dispatch_group_t executeGroup;

- (void)wait;
- (void)enter;
- (void)leave;
- (BOOL)wait:(NSTimeInterval)delay;

@end

NS_ASSUME_NONNULL_END

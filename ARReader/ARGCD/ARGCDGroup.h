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
/**
 当前执行任务组
 */
@property (nonatomic, readonly, strong) dispatch_group_t executeGroup;

/**
 等待
 */
- (void)wait;
/**
 进入
 */
- (void)enter;
/**
 离开
 */
- (void)leave;
/**
 等待

 @param delay 等待时间
 @return 是否成功等待
 */
- (BOOL)wait:(NSTimeInterval)delay;

@end

NS_ASSUME_NONNULL_END

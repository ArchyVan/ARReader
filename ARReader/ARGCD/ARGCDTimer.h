//
//  ARGCDTimer.h
//  ARReader
//
//  Created by Objective-C on 2017/2/22.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ARGCDQueue;
/**
 封装GCD计时器，需要作为属性持有，否则执行block不会运行，source会被立即释放。
 */
@interface ARGCDTimer : NSObject

@property (nonatomic, readonly, strong) dispatch_source_t executeSource;

- (instancetype)initWithExecuteQueue:(ARGCDQueue *)queue;

- (void)execute:(dispatch_block_t)block interval:(NSTimeInterval)interval;

- (void)execute:(dispatch_block_t)block interval:(NSTimeInterval)interval delay:(NSTimeInterval)delay;

- (void)start;
- (void)suspend;
- (void)destory;

@end

NS_ASSUME_NONNULL_END

//
//  ARGCDQueue.h
//  ARReader
//
//  Created by Objective-C on 2017/2/22.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ARGCDGroup,ARGCDSemaphore;

typedef void (^ar_block_t)(void);
typedef void (^ar_apply_block_t)(size_t);

typedef NS_ENUM(NSUInteger, ARQueuePriority) {
    ARQueuePriorityLow = DISPATCH_QUEUE_PRIORITY_LOW,
    ARQueuePriorityHigh = DISPATCH_QUEUE_PRIORITY_HIGH,
    ARQueuePriorityDefault = DISPATCH_QUEUE_PRIORITY_DEFAULT,
    ARQueuePriorityBackground = DISPATCH_QUEUE_PRIORITY_BACKGROUND
};

/**
 封装GCD 队列
 */
@interface ARGCDQueue : NSObject
/**
 当前执行队列
 */
@property (nonatomic, readonly, strong) dispatch_queue_t executeQueue;
@property (nonatomic, readonly, strong) ar_block_t executeBlock;
@property (nonatomic, readonly, strong) ar_block_t barrierBlock;
@property (nonatomic, readonly, strong) ar_apply_block_t applyBlock;
/**
 主队列

 @return 封装GCD队列
 */
+ (instancetype)mainQueue;
/**
 低优先级队列

 @return 封装GCD队列
 */
+ (instancetype)lowPriorityQueue;
/**
 高优先级队列

 @return 封装GCD队列
 */
+ (instancetype)highPriorityQueue;
/**
 默认优先级队列

 @return 封装GCD队列
 */
+ (instancetype)defaultPriorityQueue;
/**
 后台队列

 @return 封装GCD队列
 */
+ (instancetype)backgroundPriorityQueue;

+ (void)executeInMainQueue: (ar_block_t)block;
+ (void)executeInGlobalQueue: (ar_block_t)block;
+ (void)executeInGlobalQueue: (ar_block_t)block queuePriority: (ARQueuePriority)queuePriority;

+ (void)executeInMainQueue: (ar_block_t)block delay: (NSTimeInterval)delay;
+ (void)executeInGlobalQueue: (ar_block_t)block delay: (NSTimeInterval)delay;
+ (void)executeInGlobalQueue: (ar_block_t)block queuePriority: (ARQueuePriority)queuePriority delay: (NSTimeInterval)delay;

- (instancetype)init;
- (instancetype)initSerial;
- (instancetype)initSerialWithIdentifier: (NSString *)identifier;
- (instancetype)initConcurrent;
- (instancetype)initConcurrentWithIdentifier: (NSString *)identifier;

- (void)execute:(ar_block_t)block;
- (void)execute:(ar_block_t)block delay: (NSTimeInterval)delay;
- (void)execute:(ar_block_t)block wait: (ARGCDSemaphore *)semaphore;
- (void)execute:(ar_block_t)block delay: (NSTimeInterval)delay wait: (ARGCDSemaphore *)semaphore;


- (void)resume;
- (void)suspend;
- (void)barrierExecute:(ar_block_t)block;
- (void)applyExecute:(size_t)times block:(ar_apply_block_t)block;
- (void)setTargetQueue:(ARGCDQueue *)queue;

- (void)notify:(ar_block_t)block inGroup: (ARGCDGroup *)group;
- (void)execute:(ar_block_t)block inGroup: (ARGCDGroup *)group;

@end

NS_ASSUME_NONNULL_END

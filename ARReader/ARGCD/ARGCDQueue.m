//
//  ARGCDQueue.m
//  ARReader
//
//  Created by Objective-C on 2017/2/22.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "ARGCDQueue.h"
#import "ARGCDGroup.h"
#import "ARGCDSemaphore.h"

static ARGCDQueue * mainQueue;
static ARGCDQueue * lowPriorityQueue;
static ARGCDQueue * highPriorityQueue;
static ARGCDQueue * defaultPriorityQueue;
static ARGCDQueue * backgroundPriorityQueue;

@interface ARGCDQueue ()

@property (nonatomic, strong) dispatch_queue_t executeQueue;
@property (nonatomic, strong) ar_block_t executeBlock;
@property (nonatomic, strong) ar_block_t barrierBlock;
@property (nonatomic, strong) ar_apply_block_t applyBlock;

@end

@implementation ARGCDQueue

+ (instancetype)mainQueue
{
    return mainQueue;
}

+ (instancetype)lowPriorityQueue
{
    return lowPriorityQueue;
}

+ (instancetype)highPriorityQueue
{
    return highPriorityQueue;
}

+ (instancetype)defaultPriorityQueue
{
    return defaultPriorityQueue;
}

+ (instancetype)backgroundPriorityQueue
{
    return backgroundPriorityQueue;
}

+ (void)initialize
{
    if (self == [ARGCDQueue self]) {
        mainQueue = [ARGCDQueue new];
        lowPriorityQueue = [ARGCDQueue new];
        highPriorityQueue = [ARGCDQueue new];
        defaultPriorityQueue = [ARGCDQueue new];
        backgroundPriorityQueue = [ARGCDQueue new];
        
        mainQueue.executeQueue = dispatch_get_main_queue();
        lowPriorityQueue.executeQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        highPriorityQueue.executeQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        defaultPriorityQueue.executeQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        backgroundPriorityQueue.executeQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    }
}

#pragma mark - 便利方法
+ (void)executeInMainQueue: (dispatch_block_t)block
{
    NSParameterAssert(block);
    dispatch_async(dispatch_get_main_queue(), block);
}

+ (void)executeInGlobalQueue: (dispatch_block_t)block
{
    NSParameterAssert(block);
    dispatch_async(dispatch_get_global_queue(ARQueuePriorityDefault, 0), block);
}

+ (void)executeInGlobalQueue: (dispatch_block_t)block queuePriority: (ARQueuePriority)queuePriority
{
    NSParameterAssert(block);
    dispatch_async(dispatch_get_global_queue(queuePriority, 0), block);
}

+ (void)executeInMainQueue: (dispatch_block_t)block delay: (NSTimeInterval)delay
{
    NSParameterAssert(block);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), block);
}

+ (void)executeInGlobalQueue: (dispatch_block_t)block delay: (NSTimeInterval)delay
{
    NSParameterAssert(block);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_global_queue(ARQueuePriorityDefault, 0), block);
}

+ (void)executeInGlobalQueue: (dispatch_block_t)block queuePriority: (ARQueuePriority)queuePriority delay: (NSTimeInterval)delay
{
    NSParameterAssert(block);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_global_queue(queuePriority, 0), block);
}

#pragma mark - 创建线程
- (instancetype)init
{
    return [self initSerial];
}

- (instancetype)initSerial
{
    if (self = [super init]) {
        self.executeQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (instancetype)initSerialWithIdentifier: (NSString *)identifier
{
    if (self = [super init]) {
        self.executeQueue = dispatch_queue_create(identifier.UTF8String, DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (instancetype)initConcurrent
{
    if (self = [super init]) {
        self.executeQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (instancetype)initConcurrentWithIdentifier: (NSString *)identifier
{
    if (self = [super init]) {
        self.executeQueue = dispatch_queue_create(identifier.UTF8String, DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

#pragma mark - 任务
- (void)execute:(dispatch_block_t)block
{
    NSParameterAssert(block);
    self.executeBlock = block;
    dispatch_async(self.executeQueue, block);
}

- (void)execute: (dispatch_block_t)block delay: (NSTimeInterval)delay
{
    NSParameterAssert(block);
    self.executeBlock = block;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), self.executeQueue, block);
}

- (void)execute:(dispatch_block_t)block wait: (ARGCDSemaphore *)semaphore
{
    NSParameterAssert(block);
    self.executeBlock = block;
    dispatch_block_t executeBlock = ^{
        [semaphore wait];
        block();
        [semaphore signal];
    };
    dispatch_async(self.executeQueue, executeBlock);
}

- (void)execute: (dispatch_block_t)block delay: (NSTimeInterval)delay wait: (ARGCDSemaphore *)semaphore
{
    NSParameterAssert(block);
    self.executeBlock = block;
    dispatch_block_t executeBlock = ^{
        [semaphore wait];
        block();
        [semaphore signal];
    };
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), self.executeQueue, executeBlock);
}

- (void)applyExecute:(size_t)times block:(void (^)(size_t))block
{
    NSParameterAssert(block);
    self.applyBlock = block;
    dispatch_apply(times, self.executeQueue, block);
}

- (void)resume
{
    dispatch_resume(self.executeQueue);
}

- (void)suspend
{
    dispatch_suspend(self.executeQueue);
}

- (void)barrierExecute:(dispatch_block_t)block
{
    NSParameterAssert(block);
    self.barrierBlock = block;
    dispatch_barrier_async(self.executeQueue, block);
}

- (void)setTargetQueue:(ARGCDQueue *)queue
{
    dispatch_set_target_queue(self.executeQueue, queue.executeQueue);
}

#pragma mark - 其他操作
- (void)execute:(dispatch_block_t)block inGroup:(ARGCDGroup *)group
{
    NSParameterAssert(block);
    dispatch_group_async(group.executeGroup, self.executeQueue, block);
}

- (void)notify:(dispatch_block_t)block inGroup:(ARGCDGroup *)group
{
    NSParameterAssert(block);
    dispatch_group_notify(group.executeGroup, self.executeQueue, block);
}



@end

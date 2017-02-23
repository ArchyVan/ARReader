//
//  ARGCDTimer.m
//  ARReader
//
//  Created by Objective-C on 2017/2/22.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "ARGCDTimer.h"
#import "ARGCDQueue.h"

@interface ARGCDTimer ()

@property (nonatomic, strong) dispatch_source_t executeSource;

@end

@implementation ARGCDTimer

- (instancetype)init
{
    if (self = [super init]) {
        self.executeSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, ARGCDQueue.defaultPriorityQueue.executeQueue);
    }
    return self;
}

- (instancetype)initWithExecuteQueue:(ARGCDQueue *)queue
{
    if (self = [super init]) {
        self.executeSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue.executeQueue);
    }
    return self;
}

#pragma mark - 操作
- (void)execute: (dispatch_block_t)block interval: (NSTimeInterval)interval
{
    NSParameterAssert(block);
    dispatch_source_set_timer(self.executeSource, dispatch_time(DISPATCH_TIME_NOW, 0), interval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(self.executeSource, block);
}

- (void)execute: (dispatch_block_t)block interval: (NSTimeInterval)interval delay: (NSTimeInterval)delay
{
    NSParameterAssert(block);
    dispatch_source_set_timer(self.executeSource, dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(self.executeSource, block);
}

- (void)start
{
    dispatch_resume(self.executeSource);
}

- (void)suspend
{
    dispatch_suspend(self.executeSource);
}

- (void)destory
{
    dispatch_source_cancel(self.executeSource);
}

@end

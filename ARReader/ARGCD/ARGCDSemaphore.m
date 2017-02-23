//
//  ARGCDSemaphore.m
//  ARReader
//
//  Created by Objective-C on 2017/2/22.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "ARGCDSemaphore.h"

@interface ARGCDSemaphore ()

@property (nonatomic, strong) dispatch_semaphore_t executeSemaphore;

@end

@implementation ARGCDSemaphore

- (instancetype)init
{
    return [self initWithValue:1];
}

- (instancetype)initWithValue:(NSUInteger)value
{
    if (self = [super init]) {
        self.executeSemaphore = dispatch_semaphore_create(value);
    }
    return self;
}

- (void)wait
{
    dispatch_semaphore_wait(self.executeSemaphore, DISPATCH_TIME_FOREVER);
}

- (BOOL)waitWithTimeout:(NSTimeInterval)timeout
{
    return dispatch_semaphore_wait(self.executeSemaphore,  dispatch_time(DISPATCH_TIME_NOW, timeout * NSEC_PER_SEC)) == 0;
}

- (BOOL)signal
{
    return dispatch_semaphore_signal(self.executeSemaphore) != 0;
}

@end

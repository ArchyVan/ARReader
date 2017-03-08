//
//  ARGCDSemaphore.h
//  ARReader
//
//  Created by Objective-C on 2017/2/22.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 封装GCD 信号量
 */
@interface ARGCDSemaphore : NSObject

@property (nonatomic, readonly, strong) dispatch_semaphore_t executeSemaphore;

- (instancetype)initWithValue:(NSUInteger)value;

- (void)wait;
- (BOOL)waitWithTimeout:(NSTimeInterval)timeout;
- (BOOL)signal;

@end

NS_ASSUME_NONNULL_END

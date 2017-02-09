//
//  ARDispatchQueuePool.h
//  ARReader
//
//  Created by Objective-C on 2017/1/20.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef ARDispatchQueuePool_h
#define ARDispatchQueuePool_h

NS_ASSUME_NONNULL_BEGIN

@interface ARDispatchQueuePool : NSObject

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithName:(nullable NSString *)name queueCount:(NSUInteger)queueCount qos:(NSQualityOfService)qos;

@property (nullable, nonatomic, readonly) NSString *name;

- (dispatch_queue_t)queue;

+ (instancetype)defaultPoolForQOS:(NSQualityOfService)qos;

@end

extern dispatch_queue_t ARDispatchQueueGetForQOS(NSQualityOfService qos);

NS_ASSUME_NONNULL_END

#endif

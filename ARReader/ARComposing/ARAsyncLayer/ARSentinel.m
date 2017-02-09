//
//  ARSentinel.m
//  ARReader
//
//  Created by Objective-C on 2017/1/20.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "ARSentinel.h"
#import <libkern/OSAtomic.h>
#import <stdatomic.h>

@implementation ARSentinel
{
    int32_t _value;
}

- (int32_t)value
{
    return _value;
}

- (int32_t)increase
{
    return OSAtomicAdd32(1, &_value);
}

@end

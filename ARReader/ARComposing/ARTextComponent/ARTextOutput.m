//
//  ARTextOutput.m
//  ARReader
//
//  Created by Objective-C on 2017/2/21.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "ARTextOutput.h"

@implementation ARTextRange
{
    NSUInteger _start;
    NSUInteger _end;
}

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;
    _start = 0;
    _end = 0;
    return self;
}

- (NSUInteger)start
{
    return _start;
}

- (NSUInteger)end
{
    return _end;
}

- (BOOL)isEmpty
{
    return _start == _end;
}

- (NSRange)asRange
{
    return NSMakeRange(_start, _end - _start);
}

+ (instancetype)rangeWithRange:(NSRange)range
{
    return [self rangeWithStart:range.location end:range.location + range.length];
}

+ (instancetype)rangeWithStart:(NSUInteger)start end:(NSUInteger)end
{
    ARTextRange *range = [ARTextRange new];
    range->_start = start;
    range->_end = end;
    return range;
}

+ (instancetype)defaultRange
{
    return [self new];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self.class rangeWithStart:_start end:_end];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p> (%@, %@)", self.class, self, @(_start), @(_end - _start)];
}

- (NSUInteger)hash
{
    return (sizeof(NSUInteger) == 8 ? OSSwapInt64(_start): OSSwapInt32(_start)) + _end;
}

- (BOOL)isEqual:(ARTextRange *)object
{
    if (!object) {
        return NO;
    }
    return _start == object.start && _end == object.end;
}

@end

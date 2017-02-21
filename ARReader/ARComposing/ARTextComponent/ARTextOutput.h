//
//  ARTextOutput.h
//  ARReader
//
//  Created by Objective-C on 2017/2/21.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ARTextRange : NSObject <NSCopying>

@property (nonatomic, readonly) NSUInteger start;
@property (nonatomic, readonly) NSUInteger end;
@property (nonatomic, readonly, getter=isEmpty) BOOL empty;

+ (instancetype)rangeWithRange:(NSRange)range;
+ (instancetype)rangeWithStart:(NSUInteger)start end:(NSUInteger)end;
+ (instancetype)defaultRange;

- (NSRange)asRange;

@end

NS_ASSUME_NONNULL_END

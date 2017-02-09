//
//  ARSentinel.h
//  ARReader
//
//  Created by Objective-C on 2017/1/20.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ARSentinel : NSObject

@property (readonly) int32_t value;

- (int32_t)increase;

@end

NS_ASSUME_NONNULL_END

//
//  CALayer+Quick.m
//  ARReader
//
//  Created by Objective-C on 2017/2/23.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "CALayer+Quick.h"

@implementation CALayer (Quick)

- (CALayer *(^)(CALayer *))addSublayer
{
    return ^(CALayer *layer){
        [self addSublayer:layer];
        return self;
    };
}
@end

//
//  CALayer+Quick.m
//  ARReader
//
//  Created by Objective-C on 2017/2/23.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "CALayer+Quick.h"
#import "ARReaderMacros.h"

DUMMY_CLASS(CALayer_Quick)

@implementation CALayer (Quick)

- (CALayer *(^)(CALayer *))addSublayer
{
    return ^(CALayer *layer){
        [self addSublayer:layer];
        return self;
    };
}
@end

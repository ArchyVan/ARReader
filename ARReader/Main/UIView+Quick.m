//
//  UIView+Quick.m
//  ARReader
//
//  Created by Objective-C on 2017/2/16.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "UIView+Quick.h"

@implementation UIView (Quick)

- (UIView *(^)(UIView *))addSubview
{
    return ^(UIView *subView){
        [self addSubview:subView];
        return self;
    };
}

@end

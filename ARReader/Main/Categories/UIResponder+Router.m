//
//  UIResponder+Router.m
//  bearead
//
//  Created by koofrank on 2017/3/3.
//  Copyright © 2017年 bearead. All rights reserved.
//

#import "UIResponder+Router.h"

@implementation UIResponder (Router)

- (void)routerEventWithName:(NSString *)eventName userinfo:(NSDictionary *)userInfo {
    [[self nextResponder] routerEventWithName:eventName userinfo:userInfo];
}

@end

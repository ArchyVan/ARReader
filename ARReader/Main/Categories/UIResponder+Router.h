//
//  UIResponder+Router.h
//  bearead
//
//  Created by koofrank on 2017/3/3.
//  Copyright © 2017年 bearead. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIResponder (Router)

- (void)routerEventWithName:(NSString *)eventName userinfo:(NSDictionary *)userInfo;

@end

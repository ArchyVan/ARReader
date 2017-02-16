//
//  UIView+Quick.h
//  ARReader
//
//  Created by Objective-C on 2017/2/16.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Quick)

- (UIView *(^)(UIView *subView))addSubview;

@end

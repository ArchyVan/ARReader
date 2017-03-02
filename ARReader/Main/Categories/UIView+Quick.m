//
//  UIView+Quick.m
//  ARReader
//
//  Created by Objective-C on 2017/2/16.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "UIView+Quick.h"
#import "ARReaderMacros.h"

DUMMY_CLASS(UIView_Quick)
@implementation UIView (Quick)

- (UIView *(^)(UIView *))addSubview;
{
    return ^(UIView *view){
        [self addSubview:view];
        return self;
    };
}

- (UIView *(^)(UIView *))sendSubviewToBack;
{
    return ^(UIView *view){
        [self sendSubviewToBack:view];
        return self;
    };
}

- (UIView *(^)(UIView *))bringSubviewToFront;
{
    return ^(UIView *view){
        [self bringSubviewToFront:view];
        return self;
    };
}

- (UIView *(^)(UIView *,NSInteger))insertSubViewAtIndex;
{
    return ^(UIView *view,NSInteger index){
        [self insertSubview:view atIndex:index];
        return self;
    };
}

- (UIView *(^)(UIView *,UIView *))insertSubViewAboveSubview;
{
    return ^(UIView *view,UIView *siblingSubview){
        [self insertSubview:view aboveSubview:siblingSubview];
        return self;
    };
}
- (UIView *(^)(UIView *view,UIView *siblingSubview))insertSubviewBelowSubview
{
    return ^(UIView *view,UIView *siblingSubview){
        [self insertSubview:view belowSubview:siblingSubview];
        return self;
    };
}
- (UIView *(^)())removeAllSubviews;
{
    return ^{
        for (UIView *subView in self.subviews) {
            [subView removeFromSuperview];
        }
        return self;
    };
}

- (UIView *(^)(UIView *))reAddSubview;
{
    return ^(UIView *view){
        return self.removeAllSubviews().addSubview(view);
    };
}

- (UIView *(^)(NSInteger))subviewAtIndex
{
    return ^(NSInteger index){
       return [self.subviews objectAtIndex:index];
    };
}

@end

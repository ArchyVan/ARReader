//
//  UIView+ComposingKit.m
//  ARKit
//
//  Created by Objective-C on 16/8/26.
//  Copyright © 2016年 Objective-C. All rights reserved.
//

#import "UIView+Reader.h"
#import <objc/runtime.h>

@interface UIView_Reader: NSObject @end
@implementation UIView_Reader @end

@implementation UIView (Reader)

- (void)setAr_origin:(CGPoint)ar_origin {
    CGRect frame = self.frame;
    frame.origin = ar_origin;
    self.frame = frame;
}

- (CGPoint)ar_origin {
    return self.frame.origin;
}

- (void)setAr_originX:(CGFloat)ar_originX {
    [self setAr_origin:CGPointMake(ar_originX, self.ar_originY)];
}

- (CGFloat)ar_originX {
    return self.ar_origin.x;
}

- (void)setAr_originY:(CGFloat)ar_originY {
    [self setAr_origin:CGPointMake(self.ar_originX, ar_originY)];
}

- (CGFloat)ar_originY {
    return self.ar_origin.y;
}

- (void)setAr_center:(CGPoint)ar_center {
    self.center = ar_center;
}

- (CGPoint)ar_center {
    return self.center;
}

- (void)setAr_centerX:(CGFloat)ar_centerX {
    [self setAr_center:CGPointMake(ar_centerX, self.ar_centerY)];
}

- (CGFloat)ar_centerX {
    return self.ar_center.x;
}

- (void)setAr_centerY:(CGFloat)ar_centerY {
    [self setAr_center:CGPointMake(self.ar_centerX, ar_centerY)];
}

- (CGFloat)ar_centerY {
    return self.ar_center.y;
}

- (void)setAr_size:(CGSize)ar_size {
    CGRect frame = self.frame;
    frame.size = ar_size;
    self.frame = frame;
}

- (CGSize)ar_size {
    return self.frame.size;
}

- (void)setAr_width:(CGFloat)ar_width {
    self.ar_size = CGSizeMake(ar_width, self.ar_height);
}

- (CGFloat)ar_width {
    return self.ar_size.width;
}

- (void)setAr_height:(CGFloat)ar_height {
    self.ar_size = CGSizeMake(self.ar_width, ar_height);
}

- (CGFloat)ar_height {
    return self.ar_size.height;
}

- (CGFloat)ar_left {
    return self.frame.origin.x;
}

- (void)setAr_left:(CGFloat)ar_left {
    CGRect frame = self.frame;
    frame.origin.x = ar_left;
    self.frame = frame;
}

- (CGFloat)ar_top {
    return self.frame.origin.y;
}

- (void)setAr_top:(CGFloat)ar_top {
    CGRect frame = self.frame;
    frame.origin.y = ar_top;
    self.frame = frame;
}

- (CGFloat)ar_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setAr_right:(CGFloat)ar_right {
    CGRect frame = self.frame;
    frame.origin.x = ar_right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)ar_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setAr_bottom:(CGFloat)ar_bottom {
    CGRect frame = self.frame;
    frame.origin.y = ar_bottom - frame.size.height;
    self.frame = frame;
}

- (UIViewController *)ar_viewController {
    for (UIView *view = self; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (CGFloat)ar_visibleAlpha {
    if ([self isKindOfClass:[UIWindow class]]) {
        if (self.hidden) return 0;
        return self.alpha;
    }
    if (!self.window) return 0;
    CGFloat alpha = 1;
    UIView *v = self;
    while (v) {
        if (v.hidden) {
            alpha = 0;
            break;
        }
        alpha *= v.alpha;
        v = v.superview;
    }
    return alpha;
}

- (CGPoint)ar_convertPoint:(CGPoint)point toViewOrWindow:(UIView *)view {
    if (!view) {
        if ([self isKindOfClass:[UIWindow class]]) {
            return [((UIWindow *)self) convertPoint:point toWindow:nil];
        } else {
            return [self convertPoint:point toView:nil];
        }
    }
    
    UIWindow *from = [self isKindOfClass:[UIWindow class]] ? (id)self : self.window;
    UIWindow *to = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    if ((!from || !to) || (from == to)) return [self convertPoint:point toView:view];
    point = [self convertPoint:point toView:from];
    point = [to convertPoint:point fromWindow:from];
    point = [view convertPoint:point fromView:to];
    return point;
}

- (CGPoint)ar_convertPoint:(CGPoint)point fromViewOrWindow:(UIView *)view {
    if (!view) {
        if ([self isKindOfClass:[UIWindow class]]) {
            return [((UIWindow *)self) convertPoint:point fromWindow:nil];
        } else {
            return [self convertPoint:point fromView:nil];
        }
    }
    
    UIWindow *from = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    UIWindow *to = [self isKindOfClass:[UIWindow class]] ? (id)self : self.window;
    if ((!from || !to) || (from == to)) return [self convertPoint:point fromView:view];
    point = [from convertPoint:point fromView:view];
    point = [to convertPoint:point fromWindow:from];
    point = [self convertPoint:point fromView:to];
    return point;
}

- (CGRect)ar_convertRect:(CGRect)rect toViewOrWindow:(UIView *)view {
    if (!view) {
        if ([self isKindOfClass:[UIWindow class]]) {
            return [((UIWindow *)self) convertRect:rect toWindow:nil];
        } else {
            return [self convertRect:rect toView:nil];
        }
    }
    
    UIWindow *from = [self isKindOfClass:[UIWindow class]] ? (id)self : self.window;
    UIWindow *to = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    if (!from || !to) return [self convertRect:rect toView:view];
    if (from == to) return [self convertRect:rect toView:view];
    rect = [self convertRect:rect toView:from];
    rect = [to convertRect:rect fromWindow:from];
    rect = [view convertRect:rect fromView:to];
    return rect;
}

- (CGRect)ar_convertRect:(CGRect)rect fromViewOrWindow:(UIView *)view {
    if (!view) {
        if ([self isKindOfClass:[UIWindow class]]) {
            return [((UIWindow *)self) convertRect:rect fromWindow:nil];
        } else {
            return [self convertRect:rect fromView:nil];
        }
    }
    
    UIWindow *from = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    UIWindow *to = [self isKindOfClass:[UIWindow class]] ? (id)self : self.window;
    if ((!from || !to) || (from == to)) return [self convertRect:rect fromView:view];
    rect = [from convertRect:rect fromView:view];
    rect = [to convertRect:rect fromWindow:from];
    rect = [self convertRect:rect fromView:to];
    return rect;
}

@end

@interface UIView_MainThread: NSObject @end
@implementation UIView_MainThread @end


@implementation UIView (MainThread)

static inline void swizzling_exchangeMethod(Class sClass,SEL originalSelector,SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(sClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(sClass, swizzledSelector);
    BOOL success = class_addMethod(sClass, originalSelector,  method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (success) {
        class_replaceMethod(sClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL needsLayoutOriginalSelector = @selector(setNeedsLayout);
        SEL needsLayoutSwizzleSelector  = @selector(guard_setNeedsLayout);
        swizzling_exchangeMethod(self, needsLayoutOriginalSelector,needsLayoutSwizzleSelector);

        SEL needsDisplaOriginalSelector = @selector(setNeedsDisplay);
        SEL needsDisplaSwizzleSelector  = @selector(guard_setNeedsDisplay);
        swizzling_exchangeMethod(self, needsDisplaOriginalSelector,needsDisplaSwizzleSelector);

        SEL needsDisplayInRectOriginalSelector = @selector(setNeedsDisplayInRect:);
        SEL needsDisplayInRectSwizzleSelector  = @selector(guard_setNeedsDisplayInRect:);
        swizzling_exchangeMethod(self, needsDisplayInRectOriginalSelector,needsDisplayInRectSwizzleSelector);
    });
}

- (void)guard_setNeedsLayout
{
    [self UIMainThreadCheck];
    [self guard_setNeedsLayout];
}

- (void)guard_setNeedsDisplay
{
    [self UIMainThreadCheck];
    [self guard_setNeedsDisplay];
}

- (void)guard_setNeedsDisplayInRect:(CGRect)rect
{
    [self UIMainThreadCheck];
    [self guard_setNeedsDisplayInRect:rect];
}

- (void)UIMainThreadCheck
{
    NSString *desc = [NSString stringWithFormat:@"%@", self.class];
    NSAssert([NSThread isMainThread], desc);
}

@end

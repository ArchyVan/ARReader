//
//  CALayer+Reader.m
//  ARReader
//
//  Created by Objective-C on 2017/2/15.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "CALayer+Reader.h"
#import <objc/runtime.h>

@interface CALayer_MainThread: NSObject @end
@implementation CALayer_MainThread @end

@implementation CALayer (MainThread)

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

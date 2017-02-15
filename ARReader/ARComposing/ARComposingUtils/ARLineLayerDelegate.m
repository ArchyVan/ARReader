//
//  ARLineLayerDelegate.m
//  ARReader
//
//  Created by Objective-C on 2017/1/17.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "ARLineLayerDelegate.h"
#import "ARComposingUtils.h"
#import "ARAsyncLayer.h"
#import "ARTransaction.h"
#import "ARPageParser.h"
#import "CALayer+Reader.h"

@interface ARLineLayerDelegate () <ARAsyncLayerDelegate>

@property (nonatomic, strong) ARPageParser              *composingParser;
@property (nonatomic, strong) ARComposingUtils          *composingUtils;

@end

@implementation ARLineLayerDelegate

- (void)setPageFrame:(CTFrameRef)pageFrame
{
    if (_pageFrame != pageFrame) {
        if (_pageFrame != nil) {
            CFRelease(_pageFrame);
        }
        CFRetain(pageFrame);
        _pageFrame = pageFrame;
    }
}

- (void)dealloc
{
    if (_pageFrame != nil) {
        CFRelease(_pageFrame);
        _pageFrame = nil;
    }
}
/**
 异步绘制代理

 @return 代理任务
 */
- (ARAsyncLayerDisplayTask *)newAsyncDisplayTask
{
    if (!self.pageContent || self.pageContent.length == 0) {
        return nil;
    }
    if (!self.pageFrame) {
        return nil;
    }
    ARAsyncLayerDisplayTask *task = [ARAsyncLayerDisplayTask new];
    task.willDisplay = ^(CALayer *layer) {
        layer.contentsScale = [UIScreen mainScreen].scale;
    };
    task.display = ^(CGContextRef ctx, CGSize size, BOOL (^isCancelled)(void)) {
        CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
        CGContextTranslateCTM(ctx, 0, self.composingParser.pageSize.height);
        CGContextScaleCTM(ctx, 1.0, -1.0);
        if (self.underLineArray.count > 0) {
            [self.underLineArray enumerateObjectsUsingBlock:^(NSValue * _Nonnull lineRange, NSUInteger idx, BOOL * _Nonnull stop) {
                NSInteger startLocation = lineRange.rangeValue.location;
                NSInteger endLocation = lineRange.rangeValue.location + lineRange.rangeValue.length;
                [self drawUnderLineWithStartLocation:startLocation endLocation:endLocation underlineStyle:self.underLineStyle inContext:ctx];
            }];
        }
    };
    task.didDisplay = ^(CALayer *layer, BOOL finished) {
    };
    return task;
}
/**
 绘制下滑线

 @param exStartLocation 下划线起点
 @param exEndLocation 下划线终点
 @param underlineStyle 下滑线样式
 @param context 绘制用上下文
 */
- (void)drawUnderLineWithStartLocation:(NSInteger)exStartLocation endLocation:(NSInteger)exEndLocation underlineStyle:(ARUnderLineStyle)underlineStyle inContext:(CGContextRef)context
{
    if (exStartLocation < 0 || exEndLocation > self.pageContent.length) {
        return;
    }
    CTFrameRef textFrame = self.pageFrame;
    CFArrayRef lines = CTFrameGetLines(textFrame);
    if (!lines) {
        return;
    }
    
    CGAffineTransform transform =  CGAffineTransformMakeTranslation(0, self.composingParser.pageSize.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);
    
    CGFloat underlineSpacing = 0;
    if (self.underLineSpacing != 0) {
        underlineSpacing = self.underLineSpacing;
    }
    
    CFIndex count = CFArrayGetCount(lines);
    CGPoint origins[count];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
    for (int i = 0; i < count; i++) {
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CFRange range = CTLineGetStringRange(line);
        
        NSInteger location = range.location;
        NSInteger length = range.length;
        NSString *lineString = [self.pageContent substringWithRange:NSMakeRange(location, length)];
        if ([lineString isEqualToString:@"\n"]) {
            continue;
        }
        
        if ([self.composingUtils isPosition:exStartLocation inRange:range] && [self.composingUtils isPosition:exEndLocation inRange:range]) {
            CGFloat ascent, descent, leading, offset, offset2;
            offset = CTLineGetOffsetForStringIndex(line, exStartLocation, NULL);
            offset2 = CTLineGetOffsetForStringIndex(line, exEndLocation, NULL);
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x + offset , linePoint.y - descent - underlineSpacing, offset2 - offset, 1);
            [self fillLineInRect:lineRect style:underlineStyle inContext:context];
            break;
        }
        
        if ([self.composingUtils isPosition:exStartLocation inRange:range]) {
            CGFloat ascent, descent, leading, width, offset;
            offset = CTLineGetOffsetForStringIndex(line, exStartLocation, NULL);
            width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x + offset , linePoint.y - descent - underlineSpacing, width - offset, 1);
            [self fillLineInRect:lineRect style:underlineStyle inContext:context];
        }
        else if (exStartLocation < range.location && exEndLocation >= range.location + range.length) {
            CGFloat ascent, descent, leading, width;
            width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x, linePoint.y - descent - underlineSpacing , width, 1);
            [self fillLineInRect:lineRect style:underlineStyle inContext:context];
        }
        else if (exStartLocation < range.location && [self.composingUtils isPosition:exEndLocation inRange:range]) {
            CGFloat ascent, descent, leading, width, offset;
            offset = CTLineGetOffsetForStringIndex(line, exEndLocation, NULL);
            width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x , linePoint.y - descent - underlineSpacing, offset, 1);
            [self fillLineInRect:lineRect style:underlineStyle inContext:context];
        }
    }
}


- (void)fillLineInRect:(CGRect)rect style:(ARUnderLineStyle)style inContext:(CGContextRef)ctx {
    
    UIColor *excerptLineColor;
    if (self.underLineColor) {
        excerptLineColor = self.underLineColor;
    } else {
       excerptLineColor = [UIColor colorWithRed:168/255.0 green:176/255.0 blue:181/255.0 alpha:0.5];
    }
    CGContextRef context = ctx;
    // 实线
    CGFloat dash = 12, dot = 5, space = 3, phase = 0, width = 1;
    if (self.underLineWidth > 0) {
        width = self.underLineWidth;
    }
    CGContextSetLineWidth(context, width);
    CGContextSetStrokeColorWithColor(context,excerptLineColor.CGColor);
    NSUInteger pattern = style & 0xF00;
    if (pattern == ARUnderLineStylePatternSolid) {
        CGContextSetLineDash(context, phase, NULL, 0);
    } else if (pattern == ARUnderLineStylePatternDot) {
        CGFloat lengths[2] = {width * dot, width * space};
        CGContextSetLineDash(context, phase, lengths, 2);
    } else if (pattern == ARUnderLineStylePatternDash) {
        CGFloat lengths[2] = {width * dash, width * space};
        CGContextSetLineDash(context, phase, lengths, 2);
    } else if (pattern == ARUnderLineStylePatternDashDot) {
        CGFloat lengths[4] = {width * dash, width * space, width * dot, width * space};
        CGContextSetLineDash(context, phase, lengths, 4);
    } else if (pattern == ARUnderLineStylePatternDashDotDot) {
        CGFloat lengths[6] = {width * dash, width * space,width * dot, width * space, width * dot, width * space};
        CGContextSetLineDash(context, phase, lengths, 6);
    } else if (pattern == ARUnderLineStylePatternCircleDot) {
        CGFloat lengths[2] = {width * 0, width * 3};
        CGContextSetLineDash(context, phase, lengths, 2);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineJoin(context, kCGLineJoinRound);
    }
    
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
    CGContextStrokePath(context);
}

- (ARComposingUtils *)composingUtils
{
    if (!_composingUtils) {
        _composingUtils = [ARComposingUtils sharedInstance];
    }
    return _composingUtils;
}

- (ARPageParser *)composingParser
{
    if (!_composingParser) {
        _composingParser = [ARPageParser sharedInstance];
    }
    return _composingParser;
}

@end

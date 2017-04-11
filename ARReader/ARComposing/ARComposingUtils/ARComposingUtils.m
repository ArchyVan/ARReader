//
//  ARComposingUtils.m
//  LearnCoreText
//
//  Created by Objective-C on 2017/1/14.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "ARComposingUtils.h"
#import "ARPageParser.h"

@interface ARComposingUtils ()

@property (nonatomic, strong) ARPageParser *pageParser;

@end

@implementation ARComposingUtils

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ARComposingUtils *utils = nil;
    dispatch_once(&onceToken, ^{
        utils = [[ARComposingUtils alloc] init];
    });
    return utils;
}

- (NSValue *)touchLineInView:(UIView *)view atPoint:(CGPoint)point lineArray:(NSArray<NSValue *> *)lineArray data:(ARPageData *)data textFrame:(CTFrameRef)textFrame
{
    CFIndex idx = [self touchContentOffsetInView:view atPoint:point data:data textFrame:textFrame];
    if (idx == -1) {
        return nil;
    }
    NSValue *lineData = [self lineAtIndex:idx lineArray:lineArray];
    return lineData;
}


// 将点击的位置转换成字符串的偏移量，如果没有找到，则返回-1
- (CFIndex)touchContentOffsetInView:(UIView *)view atPoint:(CGPoint)point data:(ARPageData *)data textFrame:(CTFrameRef)tFrame{
    if (point.y > self.pageParser.pageSize.height && point.x > self.pageParser.pageSize.width) {
        return data.pageContent.length;
    } else if (point.y < 0 && point.x < 0) {
        return 0;
    }
    if (point.x < 0) {
        point.x = 0;
    } else if (point.x > self.pageParser.pageSize.width) {
        point.x = self.pageParser.pageSize.width;
    } else if (point.y > self.pageParser.pageSize.height) {
        point.y = self.pageParser.pageSize.height;
    } else if (point.y < 0) {
        point.y = 0;
    }
    CTFrameRef textFrame = tFrame;
    CFArrayRef lines = CTFrameGetLines(textFrame);
    if (!lines) {
        return -1;
    }
    CFIndex count = CFArrayGetCount(lines);
    
    // 获得每一行的origin坐标
    CGPoint origins[count];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0,0), origins);
    
    // 翻转坐标系
    CGAffineTransform transform =  CGAffineTransformMakeTranslation(0, view.bounds.size.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);
    
    CFIndex idx = -1;
    for (int i = 0; i < count; i++) {
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        // 获得每一行的CGRect信息
        CGRect flippedRect = [self getLineBounds:line point:linePoint];
        CGRect rect = CGRectApplyAffineTransform(flippedRect, transform);
        rect.origin.y -= 10;
        rect.size.height += 20;
        if (CGRectContainsPoint(rect, point)) {
            // 将点击的坐标转换成相对于当前行的坐标
            CGPoint relativePoint = CGPointMake(point.x-CGRectGetMinX(rect),
                                                point.y-CGRectGetMinY(rect));
            // 获得当前点击坐标对应的字符串偏移
            idx = CTLineGetStringIndexForPosition(line, relativePoint);
        }
    }
    return idx;
}

- (CGRect)selectContentRectInView:(UIView *)view fromStartPosition:(NSInteger)startPosition toEndPosition:(NSInteger)endPosition data:(ARPageData *)data textFrame:(CTFrameRef)tFrame
{
    if (startPosition < 0 || endPosition > data.pageContent.length) {
        return CGRectZero;
    }
    
    CTFrameRef textFrame = tFrame;
    CFArrayRef lines = CTFrameGetLines(textFrame);
    if (!lines) {
        return CGRectZero;
    }
    CFIndex count = CFArrayGetCount(lines);
    
    CGPoint origins[count];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
    
    CGAffineTransform transform =  CGAffineTransformMakeTranslation(0, view.bounds.size.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);
    
    CGRect selectRect = CGRectZero;
    for (int i = 0; i < count; i++) {
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CFRange range = CTLineGetStringRange(line);
        
        NSInteger location = range.location;
        NSInteger length = range.length;
        NSString *lineString = [data.pageDisplayContent substringWithRange:NSMakeRange(location, length)];
        if ([lineString isEqualToString:@"\n"]) {
            continue;
        }
        if ([self isPosition:startPosition inRange:range] && [self isPosition:endPosition inRange:range]) {
            CGFloat ascent, descent, leading, offset, offset2;
            offset = CTLineGetOffsetForStringIndex(line, startPosition, NULL);
            offset2 = CTLineGetOffsetForStringIndex(line, endPosition, NULL);
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x + offset, linePoint.y - descent, offset2 - offset, ascent + descent);
            selectRect = lineRect;
            break;
        }
        
        if ([self isPosition:startPosition inRange:range]) {
            CGFloat ascent, descent, leading, width, offset;
            offset = CTLineGetOffsetForStringIndex(line, startPosition, NULL);
            width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x + offset, linePoint.y - descent, width - offset, ascent + descent);
            selectRect = lineRect;
        }
        else if (startPosition < range.location && endPosition >= range.location + range.length) {
            CGFloat ascent, descent, leading, width;
            width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x, linePoint.y - descent, width, ascent + descent);
            selectRect = CGRectUnion(selectRect, lineRect);
        }
        else if (startPosition < range.location && [self isPosition:endPosition inRange:range]) {
            CGFloat ascent, descent, leading,offset;
            offset = CTLineGetOffsetForStringIndex(line, endPosition, NULL);
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x, linePoint.y - descent, offset, ascent + descent);
            selectRect = CGRectUnion(selectRect, lineRect);
        }
    }
    return CGRectApplyAffineTransform(selectRect, transform);
}

- (CGRect)selectContentRectInView:(UIView *)view withRange:(NSRange)range data:(ARPageData *)data textFrame:(CTFrameRef)textFrame
{
    return [self selectContentRectInView:view fromStartPosition:range.location toEndPosition:(range.location + range.length) data:data textFrame:textFrame];
}

- (NSRange)touchRangeInView:(UIView *)view atPoint:(CGPoint)point data:(ARPageData *)data textFrame:(CTFrameRef)tFrame
{
    CFIndex index = [self touchContentOffsetInView:view atPoint:point data:data textFrame:tFrame];
    if (index == -1) {
        return NSMakeRange(0, 0);
    }
    NSRange doubleTouchRange = NSMakeRange(0, 0);
    CTFrameRef textFrame = tFrame;
    CFArrayRef lines = CTFrameGetLines(textFrame);
    if (!lines) {
        return NSMakeRange(0, 0);
    }
        
    CFIndex count = CFArrayGetCount(lines);
    CGPoint origins[count];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
    
    BOOL isContainPoint = NO;
    for (int i = 0; i < count; i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CFRange range = CTLineGetStringRange(line);
        
        NSInteger location = range.location;
        NSInteger length = range.length;
        NSString *lineString = [data.pageDisplayContent substringWithRange:NSMakeRange(location, length)];
        if ([self isPosition:index inRange:range]) {
            isContainPoint = YES;
        }
        if ([lineString hasSuffix:@"\n"]) {
            if (isContainPoint) {
                doubleTouchRange.length += range.length;
                break;
            }
            doubleTouchRange.location = location + range.length;
            doubleTouchRange.length = 0;
            continue;
        }
        doubleTouchRange.length += range.length;
    }
    return doubleTouchRange;
}

- (BOOL)isPosition:(NSInteger)position inRange:(CFRange)range {
    if (position >= range.location && position < range.location + range.length) {
        return YES;
    } else {
        return NO;
    }
}

- (CGRect)getLineBounds:(CTLineRef)line point:(CGPoint)point {
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    return CGRectMake(point.x, point.y - descent, width, height);
}

- (NSValue *)lineAtIndex:(CFIndex)i lineArray:(NSArray *)lineArray {
    NSValue *value = nil;
    for (NSValue *data in lineArray) {
        if (NSLocationInRange(i, data.rangeValue)) {
            value = data;
            break;
        }
    }
    return value;
}

- (ARPageParser *)pageParser
{
    if (!_pageParser) {
        _pageParser = [ARPageParser sharedInstance];
    }
    return _pageParser;
}

@end

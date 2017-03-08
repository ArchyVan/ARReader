//
//  ARTextLine.m
//  ARReader
//
//  Created by Objective-C on 2017/2/13.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "ARTextLine.h"

@implementation ARTextLine
{
    CGFloat _firstGlyphPos;
}

+ (instancetype)lineWithCTLine:(CTLineRef)CTLine position:(CGPoint)position
{
    if (!CTLine) {
        return nil;
    }
    ARTextLine *line = [self new];
    line->_position = position;
    [line setCTLine:CTLine];
    return line;
}

- (void)dealloc
{
    if (_CTLine) {
        CFRelease(_CTLine);
    }
}

- (void)setCTLine:(CTLineRef _Nonnull)CTLine
{
    if (_CTLine != CTLine) {
        if (CTLine) {
            CFRetain(CTLine);
        }
        if (_CTLine) {
            CFRelease(_CTLine);
        }
        _CTLine = CTLine;
        if (_CTLine) {
            _lineWidth = CTLineGetTypographicBounds(_CTLine, &_ascent, &_descent, &_leading);
            CFRange range = CTLineGetStringRange(_CTLine);
            _range = NSMakeRange(range.location, range.length);
            if (CTLineGetGlyphCount(_CTLine) > 0) {
                CFArrayRef runs = CTLineGetGlyphRuns(_CTLine);
                CTRunRef run = CFArrayGetValueAtIndex(runs, 0);
                NSDictionary *attributes = (__bridge id)CTRunGetAttributes(run);
                UIFont *firstGlyphFont = [attributes objectForKey:@"NSFont"];
                _firstGlyphFontSize = firstGlyphFont.pointSize;
                CGPoint pos;
                CTRunGetPositions(run, CFRangeMake(0, 1), &pos);
                _firstGlyphPos = pos.x;
            } else {
                _firstGlyphPos = 0;
            }
            _trailingWhitspaceWidth = CTLineGetTrailingWhitespaceWidth(_CTLine);
        } else {
            _lineWidth = _ascent = _descent = _leading = _firstGlyphPos = _trailingWhitspaceWidth = 0;
            _firstGlyphFontSize = 0;
            _range = NSMakeRange(0, 0);
        }
        [self reloadBounds];
    }
}

- (void)setPosition:(CGPoint)position
{
    _position = position;
    [self reloadBounds];
}

- (void)reloadBounds
{
    _bounds = CGRectMake(_position.x, _position.y - _ascent, _lineWidth, _ascent + _descent);
    _bounds.origin.x += _firstGlyphPos;
}

- (CGSize)size
{
    return _bounds.size;
}

- (CGFloat)width {
    return CGRectGetWidth(_bounds);
}

- (CGFloat)height {
    return CGRectGetHeight(_bounds);
}

- (CGFloat)top {
    return CGRectGetMinY(_bounds);
}

- (CGFloat)bottom {
    return CGRectGetMaxY(_bounds);
}

- (CGFloat)left {
    return CGRectGetMinX(_bounds);
}

- (CGFloat)right {
    return CGRectGetMaxX(_bounds);
}

- (NSString *)description {
    NSMutableString *desc = @"".mutableCopy;
    NSRange range = self.range;
    [desc appendFormat:@"<ARTextLine: %p> row:%zd range:%tu,%tu",self, self.row, range.location, range.length];
    [desc appendFormat:@" position:%@",NSStringFromCGPoint(self.position)];
    [desc appendFormat:@" bounds:%@",NSStringFromCGRect(self.bounds)];
    return desc;
}

@end

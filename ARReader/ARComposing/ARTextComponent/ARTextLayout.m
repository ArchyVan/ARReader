//
//  ARTextLayout.m
//  ARReader
//
//  Created by Objective-C on 2017/2/13.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "ARTextLayout.h"

@implementation ARTextLayout

+ (instancetype)layoutWithCTFrame:(CTFrameRef)CTFrame size:(CGSize)size fontSize:(CGFloat)fontSize
{
    if (!CTFrame) {
        return nil;
    }
    ARTextLayout *layout = [self new];
    layout->_layoutSize = size;
    layout->_fontSize = fontSize;
    [layout setCTFrame:CTFrame];
    return layout;
}

- (void)dealloc
{
    if (_CTFrame) {
        CFRelease(_CTFrame);
    }
}

- (void)setCTFrame:(CTFrameRef)CTFrame
{
    if (_CTFrame != CTFrame) {
        if (CTFrame) {
            CFRetain(CTFrame);
        }
        if (_CTFrame) {
            CFRelease(_CTFrame);
        }
        _CTFrame = CTFrame;
        if (_CTFrame) {
            CFArrayRef ctlines = CTFrameGetLines(_CTFrame);
            _rowCount = CFArrayGetCount(ctlines);
            CGPoint origins[_rowCount];
            CTFrameGetLineOrigins(_CTFrame, CFRangeMake(0, 0), origins);
            NSMutableArray *lines = [NSMutableArray array];
            for (NSUInteger i = 0; i < _rowCount; i++) {
                CTLineRef ctLine = CFArrayGetValueAtIndex(ctlines, i);
                CGPoint linePosition = origins[i];
                ARTextLine *line = [ARTextLine lineWithCTLine:ctLine position:linePosition];
                [lines addObject:line];
            }
            _lines = lines;
            _wordCount = CTFrameGetVisibleStringRange(_CTFrame).length;
            [self resetLineOriginWithLines:lines];
        } else {
            _rowCount = _wordCount = _fontSize =0;
            _lines = nil;
            _layoutSize = CGSizeZero;
        }
    }
}

- (void)resetLineOriginWithLines:(NSArray <ARTextLine *>*)lines
{
    NSUInteger realCount = floor(([UIScreen mainScreen].bounds.size.height - 80) / ([UIFont systemFontOfSize:21].lineHeight + 11.0));
    NSUInteger linesCount = lines.count;
    UIFont *font = [UIFont systemFontOfSize:_fontSize];
    CGFloat lineHeight = (_layoutSize.height - realCount * (10 + 1)) / realCount;
    NSInteger deviation = realCount - linesCount;
    for (int i = 0 ; i < linesCount; i++) {
        ARTextLine *line = [lines objectAtIndex:i];
        if (line.firstGlyphFontSize > font.pointSize) {
            continue;
        }
        CGFloat newPositionY = (lineHeight - font.lineHeight) / 2.0 + (font.lineHeight + 11) * (linesCount - i + deviation) - font.ascender;
        line.position = CGPointMake(line.position.x, newPositionY);
    }
    _lines = lines;
}

@end

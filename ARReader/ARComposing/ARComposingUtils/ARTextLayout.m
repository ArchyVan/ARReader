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
    return [self layoutWithCTFrame:CTFrame size:size fontSize:fontSize needReLayout:NO];
}

+ (instancetype)layoutWithCTFrame:(CTFrameRef)CTFrame size:(CGSize)size fontSize:(CGFloat)fontSize needReLayout:(BOOL)needReLayout
{
    if (!CTFrame) {
        return nil;
    }
    ARTextLayout *layout = [ARTextLayout new];
    layout->_isReLayout = needReLayout;
    layout->_layoutSize = size;
    layout->_fontSize = fontSize;
    [layout setCTFrame:CTFrame];
    return layout;
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
            [self resetLineOriginWithLines:_lines];
        }
    }
}

- (void)resetLineOriginWithLines:(NSArray <ARTextLine *>*)lines
{
    NSUInteger realCount = floor(([UIScreen mainScreen].bounds.size.height - 80) / ([UIFont systemFontOfSize:21].lineHeight + 11.0));
    NSUInteger linesCount = lines.count;
    if (_isReLayout) {
        
    } else {
        UIFont *font = [UIFont systemFontOfSize:_fontSize];
        CGFloat height = (_layoutSize.height - linesCount * 11) / linesCount;
        
    }
}

@end

//
//  ARTextLayout.m
//  ARReader
//
//  Created by Objective-C on 2017/2/13.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "ARTextLayout.h"

@interface ARTextLayout ()

@property (nonatomic, readwrite) NSString *content;

@end

@implementation ARTextLayout

+ (instancetype)layoutWithCTFrame:(CTFrameRef)CTFrame content:(NSString *)content;
{
    if (!CTFrame) {
        return nil;
    }
    ARTextLayout *layout = [ARTextLayout new];
//    layout->c = content;
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
            NSLog(@"\n lines:%@",lines);
        }
    }
}

/**
 TODO

 @param lines 当前所有行
 */
- (void)reLayoutLine:(NSMutableArray *)lines
{
    NSMutableArray *reverseLines = [[[lines reverseObjectEnumerator] allObjects] mutableCopy];
    CGFloat lineSpacing = 10;
    [reverseLines enumerateObjectsUsingBlock:^(ARTextLine *line, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat padding = line.bounds.origin.y - 10;
        CGPoint oringin = line.position;
        oringin.y -= padding;
    }];
}



@end

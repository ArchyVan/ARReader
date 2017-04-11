//
//  ARLineManager.m
//  ARReader
//
//  Created by Objective-C on 2017/1/27.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "ARLineManager.h"

@implementation ARLineManager

- (NSArray *)addLineWithRange:(NSRange)range
{
    NSMutableArray *newLineArray = [NSMutableArray array];
    if (!self.lineArray || self.lineArray.count == 0) {
        [newLineArray addObject:[NSValue valueWithRange:range]];
        self.lineArray = [newLineArray copy];
        return newLineArray;
    }
    newLineArray = [self.lineArray mutableCopy];
    BOOL isAddRange = NO;
    NSRange compareRange = range;
    NSRange unionRange = NSMakeRange(0, 0);
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    for (int i = 0; i < self.lineArray.count; i++) {
        NSRange lineRange = ((NSValue *)self.lineArray[i]).rangeValue;
        NSRange intersectionRange = NSIntersectionRange(compareRange, lineRange);
        if (intersectionRange.location == 0 && intersectionRange.length == 0) {
            continue;
        }
        if (intersectionRange.location != NSNotFound) {
            isAddRange = YES;
            [indexSet addIndex:i];
            unionRange = NSUnionRange(lineRange, compareRange);
            compareRange = unionRange;
        }
    }
    if (!isAddRange) {
        [newLineArray addObject:[NSValue valueWithRange:range]];
    } else {
        [newLineArray removeObjectsAtIndexes:indexSet];
        [newLineArray addObject:[NSValue valueWithRange:unionRange]];
    }
    self.lineArray = [newLineArray copy];
    return newLineArray;
}

- (NSArray *)removeLineWithRange:(NSRange)range
{
    if (!self.lineArray || self.lineArray.count == 0) {
        return nil;
    }
    if (range.length == range.location && range.length == 0) {
        return self.lineArray;
    }
    NSMutableArray *newLineArray = [self.lineArray mutableCopy];
    for (NSValue *lineRange in self.lineArray) {
        NSRange intersectionRange = NSIntersectionRange(range, lineRange.rangeValue);
        if (intersectionRange.length == 0 && intersectionRange.location == 0) {
            continue;
        }
        if (NSEqualRanges(range, lineRange.rangeValue)) {
            [newLineArray removeObject:lineRange];
            break;
        } else if (intersectionRange.location != NSNotFound) {
            [newLineArray removeObject:lineRange];
            break;
        }
    }
    if (newLineArray.count == 0) {
        self.lineArray = nil;
        return nil;
    }
    self.lineArray = [newLineArray copy];
    return newLineArray;
}

@end

//
//  ARTextLine.h
//  ARReader
//
//  Created by Objective-C on 2017/2/13.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

NS_ASSUME_NONNULL_BEGIN

@interface ARTextLine : NSObject

+ (instancetype)lineWithCTLine:(CTLineRef)CTLine position:(CGPoint)position;

@property (nonatomic) NSUInteger index;
@property (nonatomic) NSUInteger row;

@property (nonatomic, readonly) CTLineRef CTLine;
@property (nonatomic, readonly) NSRange   range;

@property (nonatomic, readonly) CGRect    bounds;
@property (nonatomic, readonly) CGSize    size;
@property (nonatomic, readonly) CGFloat   width;
@property (nonatomic, readonly) CGFloat   height;
@property (nonatomic, readonly) CGFloat   top;
@property (nonatomic, readonly) CGFloat   bottom;
@property (nonatomic, readonly) CGFloat   left;
@property (nonatomic, readonly) CGFloat   right;

@property (nonatomic) CGPoint position;
@property (nonatomic, readonly) CGFloat ascent;
@property (nonatomic, readonly) CGFloat descent;
@property (nonatomic, readonly) CGFloat leading;
@property (nonatomic, readonly) CGFloat lineWidth;
@property (nonatomic, readonly) CGFloat trailingWhitspaceWidth;

@property (nonatomic, readonly) CGFloat firstGlyphFontSize;

@end

NS_ASSUME_NONNULL_END

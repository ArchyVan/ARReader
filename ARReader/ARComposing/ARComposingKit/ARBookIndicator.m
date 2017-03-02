//
//  ARBookIndicator.m
//  ARReader
//
//  Created by Objective-C on 2017/2/27.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ARBookIndicator.h"

#define AnimationDuration 1.5

#ifdef IOS10_SDK_ALLOWED
@interface ARBookIndicator ()<CAAnimationDelegate>
#else
@interface ARBookIndicator ()
#endif

@end

@implementation ARBookIndicator
{
    CALayer *_line1;
    CALayer *_line2;
    CALayer *_line3;
    CALayer *_line4;
    CALayer *_line5;
    CALayer *_line6;
    NSArray *_lines;
    CAAnimationGroup *_lineAnimation;
    NSTimeInterval _currentOffsetTime;
    BOOL _isStartAnimating;;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [self initWithStyle:ARBookIndicatorStyleNormal]) {
        self.frame = frame;
    }
    return self;
}

- (instancetype)init {
    return [self initWithStyle:ARBookIndicatorStyleNormal];
}

- (instancetype)initWithStyle:(ARBookIndicatorStyle)style {
    if (self = [super initWithFrame:CGRectZero]) {
        _style = style;
        
        _hidesWhenStopped = YES;
        _isStartAnimating = NO;
        
        [self sizeToFit];
        
        _line1 = [CALayer layer];
        _line2 = [CALayer layer];
        _line3 = [CALayer layer];
        _line4 = [CALayer layer];
        _line5 = [CALayer layer];
        _line6 = [CALayer layer];
        _lines = @[_line1, _line2, _line3, _line4, _line5, _line6,];
        
        for (CALayer *line in _lines) {
            [self.layer addSublayer:line];
        }
        
        self.backgroundColor = [UIColor clearColor];
        self.tintColor = [UIColor grayColor];
        
    }
    return self;
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    for (CALayer *line in _lines) {
        line.backgroundColor = tintColor.CGColor;
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

#pragma mark - <QMUIEmptyViewLoadingViewProtocol>

- (void)startAnimating {
    _isStartAnimating = YES;
    for (NSInteger i = 0, l = _lines.count; i < l; i++) {
        CALayer *line = _lines[i];
        line.speed = 1.0;
        [line removeAnimationForKey:@"lineAnimations"];
        [line addAnimation:[self groupAnimationWithIndex:i] forKey:@"lineAnimations"];
    }
}

- (CAAnimationGroup *)groupAnimationWithIndex:(NSInteger)index {
    
    if (self.hidesWhenStopped) {
        self.hidden = NO;
    }
    
    CGFloat lineBaseY;      // 第一条线的顶部y值
    CGFloat lineSpacing;    // 线与线在垂直方向上的间距
    CGFloat lineWidth;      // 横线的宽度
    CGFloat lineHeight;     // 横线的高度
    
    if (self.style == ARBookIndicatorStyleNormal) {
        lineBaseY = 12;
        lineSpacing = 7;
        lineWidth = 15;
        lineHeight = 1 + 1 / [[UIScreen mainScreen] scale];
    } else {
        lineBaseY = 9;
        lineSpacing = 5;
        lineWidth = 11;
        lineHeight = 1;
    }
    
    // 关键帧对应的时间点（0.0-1.0），分别是从无到有、从有到完整显示、完整显示状态hold住、开始往右边缩小、缩小到0、0hold住
    NSArray *keyTimesForLines = @[@[@0.0f, @0.0f, @(15.0f / 90.0f), @((54.0f) / 90.0f), @(70.0f / 90.0f), @1.0f],
                                  @[@0.0f, @(7.0f / 90.0f), @(21.0f / 90.0f), @((50.0f) / 90.0f), @(65.0f / 90.0f), @1.0f],
                                  @[@0.0f, @(10.0f / 90.0f), @(25.0f / 90.0f), @((45.0f) / 90.0f), @(60.0f / 90.0f), @1.0f],
                                  @[@0.0f, @(10.0f / 90.0f), @(25.0f / 90.0f), @((65.0f) / 90.0f), @(80.0f / 90.0f), @1.0f],
                                  @[@0.0f, @(15.0f / 90.0f), @(30.0f / 90.0f), @((58.0f) / 90.0f), @(75.0f / 90.0f), @1.0f],
                                  @[@0.0f, @(20.0f / 90.0f), @(35.0f / 90.0f), @((54.0f) / 90.0f), @(70.0f / 90.0f), @1.0f]];
    
    CALayer *line = _lines[index];
    CGFloat x = floorf((CGRectGetWidth(self.bounds) / 2 - lineWidth) / 2 + CGRectGetWidth(self.bounds) / 2 * (index / 3) + (index / 3 > 0 ? 0 : 1));
    CGFloat y = floorf(lineBaseY + (lineHeight + lineSpacing) * (index % 3));
    line.frame = CGRectMake(x, y, 0, lineHeight);
    
    NSArray *keyTimes = keyTimesForLines[index];
    
    CAKeyframeAnimation *widthAnimation = [CAKeyframeAnimation animationWithKeyPath:@"bounds"];
    widthAnimation.values = @[[NSValue valueWithCGRect:CGRectMake(0, 0, 0, lineHeight)],
                              [NSValue valueWithCGRect:CGRectMake(0, 0, 0, lineHeight)],
                              [NSValue valueWithCGRect:CGRectMake(0, 0, lineWidth, lineHeight)],
                              [NSValue valueWithCGRect:CGRectMake(0, 0, lineWidth, lineHeight)],
                              [NSValue valueWithCGRect:CGRectMake(0, 0, 0, lineHeight)],
                              [NSValue valueWithCGRect:CGRectMake(0, 0, 0, lineHeight)],];
    widthAnimation.keyTimes = keyTimes;
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.values = @[[NSValue valueWithCGPoint:CGPointMake(x, y)],
                                 [NSValue valueWithCGPoint:CGPointMake(x, y)],
                                 [NSValue valueWithCGPoint:CGPointMake(x + lineWidth / 2, y)],
                                 [NSValue valueWithCGPoint:CGPointMake(x + lineWidth / 2, y)],
                                 [NSValue valueWithCGPoint:CGPointMake(x + lineWidth, y)],
                                 [NSValue valueWithCGPoint:CGPointMake(x + lineWidth, y)],];
    positionAnimation.keyTimes = keyTimes;
    
    CAAnimationGroup *groupAnimation = [[CAAnimationGroup alloc] init];
    groupAnimation.animations = @[widthAnimation, positionAnimation];
    groupAnimation.duration = AnimationDuration;
    groupAnimation.repeatCount = HUGE_VALF;
    if (_currentOffsetTime && _currentOffsetTime > 0) {
        groupAnimation.timeOffset = _currentOffsetTime;
    }
    groupAnimation.delegate = self;
    
    return groupAnimation;
}

- (void)manualAnimationWithCurrentOffsetY:(CGFloat)currentOffsetY
                  distanceForStartRefresh:(CGFloat)distanceForStartRefresh
             distanceForCompleteAnimation:(CGFloat)distanceForCompleteAnimation {
    if (_isStartAnimating) {
        return;
    }
    CGFloat beginAnimationOffset = -(distanceForStartRefresh - distanceForCompleteAnimation);
    
    if (currentOffsetY > beginAnimationOffset || currentOffsetY < -distanceForStartRefresh) {
        // 还没到开始动画的临界点，或者已经超过完整走完动画的距离，则什么都不用做
        return;
    }
    
    for (NSInteger i = 0, l = _lines.count; i < l; i++) {
        CALayer *line = _lines[i];
        line.speed = 0.0;
        if (![line animationForKey:@"lineAnimations"]) {
            [line addAnimation:[self groupAnimationWithIndex:i] forKey:@"lineAnimations"];
        }
        _currentOffsetTime = ((-currentOffsetY + beginAnimationOffset) / distanceForCompleteAnimation) * AnimationDuration * 0.4;// timeOffset为0.6时loading刚好走完一轮，所以这里按总时间 * 0.4，从而保证loading停靠在顶部时，timeOffset刚好为0.6
        line.timeOffset = _currentOffsetTime;
    }
}

- (void)stopAnimating {
    _isStartAnimating = NO;
    for (CALayer *line in _lines) {
        _currentOffsetTime = 0;
        [line removeAnimationForKey:@"lineAnimations"];
    }
    if (self.hidesWhenStopped) {
        self.hidden = YES;
    }
}

- (BOOL)isAnimating {
    //这里偶然会返回NO，打印_line1.animationKeys会为nil，动画确实能出现，具体原因找不到,暂且先返回_isStartAnimating
    //return [_line1 animationForKey:QDActivityIndicatorAnimationKey] != nil;
    return _isStartAnimating;
}

@end

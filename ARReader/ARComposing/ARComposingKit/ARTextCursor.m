//
//  ARTextCursor.m
//  LearnCoreText
//
//  Created by Objective-C on 2017/1/14.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "ARTextCursor.h"
#import "UIView+Reader.h"
#import "UIColor+Reader.h"

@implementation ARTextCursor

- (instancetype)init
{
    return [self initWithHeight:0];
}

- (instancetype)initWithHeight:(CGFloat)height
{
    self = [super initWithFrame:CGRectMake(0, 0, 8, height + 6)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        self.cursorHeight = height;
        self.cursorColor = [UIColor colorWithHexString:@"2e9fff"];
        self.cursorType = ARTextCursorTop;
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(cursorPan:)];
        panGesture.delegate = self;
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cursorLongPress:)];
        longPressGesture.delegate = self;
        longPressGesture.minimumPressDuration = 0.01;
        [self addGestureRecognizer:panGesture];
        [self addGestureRecognizer:longPressGesture];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (self.cursorHeight == 0) {
        return;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    // draw point
    if (self.cursorType == ARTextCursorTop) {
        CGContextAddEllipseInRect(context, CGRectMake(19, 14, 10, 10));
    } else {
        CGContextAddEllipseInRect(context, CGRectMake(19, self.cursorHeight + 16, 10, 10));
    }
    CGContextSetFillColorWithColor(context, self.cursorColor.CGColor);
    CGContextFillPath(context);
    // draw line
    [self.cursorColor set];
    CGContextSetLineWidth(context, 1.5);
    CGContextMoveToPoint(context, 24, 21);
    CGContextAddLineToPoint(context, 24, self.cursorHeight + 20);
    CGContextStrokePath(context);
}

- (void)setCursorHeight:(CGFloat)cursorHeight
{
    _cursorHeight = cursorHeight + 6;
    CGRect rect = self.frame;
    rect.size.height = cursorHeight + 6 + 40;
    self.frame = rect;
    [self setNeedsDisplay];
}

- (void)setCursorColor:(UIColor *)cursorColor
{
    _cursorColor = cursorColor;
    [self setNeedsDisplay];
}

- (void)setAr_origin:(CGPoint)ar_origin
{
    ar_origin.x -= 20;
    ar_origin.y -= 20;
    [super setAr_origin:ar_origin];
    self.ar_width = 48;
}

- (void)setCursorType:(ARTextCursorType)cursorType
{
    _cursorType = cursorType;
    [self setNeedsDisplay];
}

- (void)cursorLongPress:(UILongPressGestureRecognizer *)longProssGesture
{
    if (longProssGesture.state == UIGestureRecognizerStateBegan) {
        [self.panDelegate cursorView:self didBeginPan:longProssGesture];
    }
    else if (longProssGesture.state == UIGestureRecognizerStateChanged) {
        [self.panDelegate cursorView:self didChangePan:longProssGesture];
    }
    else if (longProssGesture.state == UIGestureRecognizerStateEnded) {
        [self.panDelegate cursorView:self didEndPan:longProssGesture];
    }
    else if (longProssGesture.state == UIGestureRecognizerStateCancelled) {
        [self.panDelegate cursorView:self didCancelPan:longProssGesture];
    }
}

- (void)cursorPan:(UIPanGestureRecognizer *)panGesture
{
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        [self.panDelegate cursorView:self didBeginPan:panGesture];
    }
    else if (panGesture.state == UIGestureRecognizerStateChanged) {
        [self.panDelegate cursorView:self didChangePan:panGesture];
    }
    else if (panGesture.state == UIGestureRecognizerStateEnded) {
        [self.panDelegate cursorView:self didEndPan:panGesture];
    }
    else if (panGesture.state == UIGestureRecognizerStateCancelled) {
        [self.panDelegate cursorView:self didCancelPan:panGesture];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        if (![otherGestureRecognizer.view isEqual:self]) {
            return NO;
        }
    }
    return NO;
}

@end

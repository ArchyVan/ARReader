//
//  ARTextView.m
//  LearnCoreText
//
//  Created by Objective-C on 2017/1/14.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "ARTextView.h"

#import <CoreText/CoreText.h>

#import "ARComposingUtils.h"
#import "ARAsyncLayer.h"
#import "ARTransaction.h"
#import "ARLineManager.h"
#import "ARLineLayerDelegate.h"

#import "UIView+Reader.h"
#import "CALayer+Reader.h"

#import "ARTextCursor.h"
#import "ARTextMagnifier.h"
#import "ARTextEffectWindow.h"

#import "ARTextLayout.h"

typedef NS_ENUM(NSInteger, ARTextViewState){
    ARTextViewStateNormal,
    ARTextViewStateTouching,
    ARTextViewStateSelecting,
    ARTextViewStateTouchLine
};

struct ARCursor {
    CGPoint origin;
    CGFloat height;
};

typedef struct ARCursor ARCursor;

CG_INLINE ARCursor
ARCursorMake(CGPoint origin, CGFloat height)
{
    ARCursor a; a.origin = origin; a.height = height; return a;
}

static void ARTextDrawText(ARTextLayout *layout,CGContextRef context) {
    for (int i = 0; i < layout.lines.count; i++) {
        ARTextLine *line = [layout.lines objectAtIndex:i];
        
        CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
        for (NSUInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, r);
            CGContextSetTextPosition(context, line.position.x, line.position.y);
            CTRunDraw(run, context, CFRangeMake(0, 0));
        }
    }
}

@interface ARTextView () <ARCursorViewPanDelegate,ARAsyncLayerDelegate,UIGestureRecognizerDelegate>
/**
 页面相关参数
 */
@property (nonatomic, assign) NSInteger selectionStartPosition;
@property (nonatomic, assign) NSInteger selectionEndPosition;
@property (nonatomic, assign) NSInteger storeStartPosition;
@property (nonatomic, assign) NSInteger storeEndPosition;
@property (nonatomic, assign) ARTextViewState textViewState;
@property (nonatomic, assign) CGPoint         lastPoint;
/**
 页面相关组件
 */
@property (nonatomic, strong) ARTextCursor *topCursorView;
@property (nonatomic, strong) ARTextCursor *bottomCursorView;
@property (nonatomic, strong) ARComposingUtils *composingUtils;
@property (nonatomic, strong) ARTextMagnifier *magnifierCaret;
@property (nonatomic, strong) ARTextMagnifier *magnifierRange;
/**
 摘录图层
 */
@property (nonatomic, strong) ARAsyncLayer        *textExcerptlayer;
/**
 摘录绘制代理
 */
@property (nonatomic, strong) ARLineLayerDelegate *excerptDelegate;
/**
 当前划线数据
 */
@property (nonatomic, strong) NSValue             *currentLineValue;
/**
 摘录管理器
 */
@property (nonatomic, strong) ARLineManager       *excerptManager;
/**
 弹出菜单栏
 */
@property (nonatomic, strong) UIMenuController *textMenuController;
@property (nonatomic, strong) UIMenuItem *menuExcerptItem;
@property (nonatomic, strong) UIMenuItem *menuCreateItem;
@property (nonatomic, strong) UIMenuItem *menuCopyItem;
@property (nonatomic, strong) UIMenuItem *menuDeleteExcerptItem;
@property (nonatomic, strong) UIMenuItem *menuSelectAllItem;
/**
 !!!核心绘制数据！！！
 */
@property (nonatomic, assign) CTFrameRef            textFrame;
@property (nonatomic, strong) ARTextLayout         *textLayout;

@property (nonatomic, copy) NSDictionary *defaultAttributes;
@property (nonatomic, copy) NSDictionary *indentAttributes;
@property (nonatomic, copy) NSDictionary *boldAttributes;

@property (nonatomic, assign, getter=isNeedUpdate) BOOL needUpdate;

@end

@implementation ARTextView

#pragma mark - Life Cycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self defaultConfiguration];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultConfiguration];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self defaultConfiguration];
    }
    return self;
}

+ (Class)layerClass
{
    return [ARAsyncLayer class];
}

- (void)setPageData:(ARPageData *)pageData
{
    _pageData = pageData;
    [self commitUpdate];
}

- (void)setExcerptArray:(NSArray *)excerptArray
{
    _excerptArray = excerptArray;
    if (self.pageData) {
        self.excerptManager.lineArray = excerptArray;
        self.excerptDelegate.underLineArray = excerptArray;
        [self.textExcerptlayer setNeedsDisplay];
    }
}

- (void)setTextViewState:(ARTextViewState)textViewState
{
    _textViewState = textViewState;
    if (_textViewState == ARTextViewStateNormal) {
        _selectionStartPosition = -1;
        _selectionEndPosition = -1;
        [self removeCursorView];
    }
    else if (_textViewState == ARTextViewStateTouching) {
        
    }
    else if (_textViewState == ARTextViewStateSelecting) {
        
    }
    else if (_textViewState == ARTextViewStateTouchLine) {
        
    }
    [self setNeedsDisplay];
}

- (void)setTextFrame:(CTFrameRef)textFrame
{
    if (_textFrame != textFrame) {
        if (_textFrame != nil) {
            CFRelease(_textFrame);
        }
        CFRetain(textFrame);
        _textFrame = textFrame;
    }
}

- (void)setTextColor:(UIColor *)textColor
{
    if (_textColor == textColor || [_textColor isEqual:textColor]) return;
    if (_textColor == textColor) return;
    if (_textColor && textColor) {
        if (CFGetTypeID(_textColor.CGColor) == CFGetTypeID(textColor.CGColor) &&
            CFGetTypeID(_textColor.CGColor) == CGColorGetTypeID()) {
            if ([_textColor isEqual:textColor]) {
                return;
            }
        }
    }
    _textColor = textColor;
    [self commitUpdate];
}

- (void)setFont:(UIFont *)font
{
    if (_font == font || [_font isEqual:font]) return;
    _font = font;
    [self commitUpdate];
}

- (void)setTitleFont:(UIFont *)titleFont
{
    if (_titleFont == titleFont || [_titleFont isEqual:titleFont]) return;
    _titleFont = titleFont;
    [self commitUpdate];
}

- (void)setIndent:(BOOL)indent
{
    if (_indent == indent) return;
    _indent = indent;
    [self commitUpdate];
}

- (void)setEditable:(BOOL)editable
{
    if (_editable == editable) {
        return;
    }
    _editable = editable;
}

- (void)setLineSpacing:(CGFloat)lineSpacing
{
    if (_lineSpacing == lineSpacing) return;
    _lineSpacing = lineSpacing;
    [self commitUpdate];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    if (_textAlignment == textAlignment) {
        return;
    }
    _textAlignment = textAlignment;
    [self commitUpdate];
}
- (void)dealloc
{
    self.magnifierCaret = nil;
    self.magnifierRange = nil;
    if (_textFrame != nil) {
        CFRelease(_textFrame);
        _textFrame = nil;
    }
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    [[ARTextEffectWindow sharedWindow] hideMagnifier:self.magnifierCaret];
    [[ARTextEffectWindow sharedWindow] hideMagnifier:self.magnifierRange];
    self.magnifierCaret = nil;
    self.magnifierRange = nil;
}

- (void)defaultConfiguration
{
    /**
     点击手势（用于将页面状态重置，或者点击摘录事件）
     */
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapGestureDetected:)];
    tapGesture.cancelsTouchesInView = YES;
    tapGesture.delegate = self; // 注意代理事件
    [self addGestureRecognizer:tapGesture];
    
    /**
     长按手势（用于选取文本）
     */
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(userLongPressedGuestureDetected:)];
    longPressGesture.minimumPressDuration = 0.25;
    [self addGestureRecognizer:longPressGesture];
    /**
     设置当前页面图层异步绘制开启
     */
    ((ARAsyncLayer *)self.layer).displaysAsynchronously = YES;
    /**
     添加摘录图层
     */
    UIWindow *testWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0,self.bounds.size.width, self.bounds.size.height)];
    testWindow.hidden = NO;
    testWindow.backgroundColor = [UIColor blackColor];
    testWindow.windowLevel = UIWindowLevelStatusBar;
    [testWindow makeKeyAndVisible];
    [self.layer addSublayer:self.textExcerptlayer];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self];
    if (self.textViewState == ARTextViewStateNormal) {
        NSValue *lineValue = [self.composingUtils touchLineInView:self atPoint:point lineArray:self.excerptDelegate.underLineArray data:self.pageData textFrame:self.textFrame];
        if (lineValue) {
            self.textViewState = ARTextViewStateTouchLine;
        } else {
            self.textViewState = ARTextViewStateNormal;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        if (![otherGestureRecognizer.view isEqual:self]) {
            self.textViewState = ARTextViewStateNormal;
            [self.textMenuController setMenuVisible:NO];
        }
    }
    if (self.textViewState == ARTextViewStateNormal) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Override Super

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(textViewDidExcerpt:) || action == @selector(textViewDidCopy:) || action == @selector(textViewDidDeleteExcerpt:) || action == @selector(textViewDidCreate:) || action == @selector(textViewDidSelectAll:)) {
        return YES;
    }
    return NO;
}

#pragma mark - CoreText && CoreGraphics
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
}
/**
 用来计算光标位置
 */
- (void)drawAnchors {
    if (_selectionStartPosition < 0 || _selectionEndPosition > self.pageData.pageContent.length) {
        return;
    }
    
    // 翻转坐标系
    CGAffineTransform transform =  CGAffineTransformMakeTranslation(0, self.bounds.size.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);
    
    NSUInteger count = self.textLayout.lines.count;
    // 获得每一行的origin坐标
    for (int i = 0; i < count; i++) {
//        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        ARTextLine *line = [self.textLayout.lines objectAtIndex:i];
        CFRange range = CTLineGetStringRange(line.CTLine);
        
        if ([self.composingUtils isPosition:self.selectionStartPosition inRange:range]) {
            ARCursor startCursor = [self getLineOrigin:line.CTLine position:self.selectionStartPosition point:line.position transform:transform];
            self.topCursorView.cursorHeight = startCursor.height;
            self.topCursorView.ar_origin = startCursor.origin;
        }
        if ([self.composingUtils isPosition:self.selectionEndPosition-1 inRange:range]) {
            ARCursor endCursor = [self getLineOrigin:line.CTLine position:self.selectionEndPosition point:line.position transform:transform];
            self.bottomCursorView.cursorHeight = endCursor.height;
            self.bottomCursorView.ar_origin = endCursor.origin;
            break;
        }
    }
}

/**
 用来绘制选中区域
 */
- (void)drawSelectionArea
{
    if (_selectionStartPosition < 0 || _selectionEndPosition > self.pageData.pageContent.length) {
        return;
    }
    
    NSUInteger count = self.textLayout.lines.count;
    for (int i = 0; i < count; i++) {
        ARTextLine *line = [self.textLayout.lines objectAtIndex:i];
        CFRange range = CTLineGetStringRange(line.CTLine);
        
        NSInteger location = range.location;
        NSInteger length = range.length;
        NSString *lineString = [self.pageData.pageDisplayContent substringWithRange:NSMakeRange(location, length)];
        if ([lineString isEqualToString:@"\n"]) {
            continue;
        }
        
        if ([self.composingUtils isPosition:self.selectionStartPosition inRange:range] && [self.composingUtils isPosition:self.selectionEndPosition inRange:range]) {
            CGFloat offset, offset2;
            offset = CTLineGetOffsetForStringIndex(line.CTLine, self.selectionStartPosition, NULL);
            offset2 = CTLineGetOffsetForStringIndex(line.CTLine, self.selectionEndPosition, NULL);
            CGRect lineRect = CGRectMake(line.position.x + offset, line.position.y - line.descent, offset2 - offset, line.ascent + line.descent);
            [self fillSelectionAreaInRect:lineRect];
            break;
        }
        
        if ([self.composingUtils isPosition:_selectionStartPosition inRange:range]) {
            CGFloat width, offset;
            offset = CTLineGetOffsetForStringIndex(line.CTLine, _selectionStartPosition, NULL);
            width = line.width;
            CGRect lineRect = CGRectMake(line.position.x + offset, line.position.y - line.descent, width - offset, line.ascent + line.descent);
            [self fillSelectionAreaInRect:lineRect];
        } // 2.2 如果 start在line前，end在line后，则填充整个区域
        else if (_selectionStartPosition < range.location && _selectionEndPosition >= range.location + range.length) {
            CGFloat ascent, descent, width;
            ascent = line.ascent;
            descent = line.descent;
            width = line.width;
            CGRect lineRect = CGRectMake(line.position.x, line.position.y - descent, width, ascent + descent);
            [self fillSelectionAreaInRect:lineRect];
        } // 2.3 如果start在line前，end在line中，则填充end前面的区域,break
        else if (_selectionStartPosition < range.location && [self.composingUtils isPosition:_selectionEndPosition inRange:range]) {
            CGFloat ascent, descent, offset;
            offset = CTLineGetOffsetForStringIndex(line.CTLine, _selectionEndPosition, NULL);
            ascent = line.ascent;
            descent = line.descent;
            CGRect lineRect = CGRectMake(line.position.x, line.position.y - descent, offset, ascent + descent);
            [self fillSelectionAreaInRect:lineRect];
        }
    }
}

#pragma mark - Private Core Methods
/**
 获取光标相关参数
 
 @param line 当前行
 @param position 当前位置
 @param point 点击位置
 @param transform 转换系数
 @return 光标参数
 */
- (ARCursor)getLineOrigin:(CTLineRef)line position:(NSInteger)position point:(CGPoint)point transform:(CGAffineTransform)transform
{
    CGFloat ascent, descent, leading, offset;
    offset = CTLineGetOffsetForStringIndex(line, position, NULL);
    CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGPoint origin = CGPointMake(point.x + offset - 5, point.y - descent / 2.0 + ascent + descent);
    origin = CGPointApplyAffineTransform(origin, transform);
    ARCursor cursor = ARCursorMake(CGPointMake(origin.x, origin.y - 3), ascent + descent * 2);
    return cursor;
}

- (void)fillSelectionAreaInRect:(CGRect)rect {
    UIColor *selectionBackgroundColor = [UIColor colorWithRed:46/255.0 green:159/255.0 blue:255/255.0 alpha:0.2];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, selectionBackgroundColor.CGColor);
    CGContextFillRect(context, rect);
}

#pragma mark - ARCursorViewPanDelegate
- (void)cursorView:(ARTextCursor *)cursorView didBeginPan:(UIGestureRecognizer *)panGesture
{
    if (self.delegate && [self.delegate  respondsToSelector:@selector(textViewDidSelectBegin:)]) {
        [self.delegate textViewDidSelectBegin:self];
    }
    [self.textMenuController setMenuVisible:NO];
    _storeStartPosition = _selectionStartPosition;
    _storeEndPosition = _selectionEndPosition;
    CGPoint point = [panGesture locationInView:self];
    self.magnifierRange.hostCaptureCenter = point;
    self.magnifierRange.hostPopoverCenter = point;
    [[ARTextEffectWindow sharedWindow] showMagnifier:self.magnifierRange];
    [self becomeFirstResponder];
}

- (void)cursorView:(ARTextCursor *)cursorView didChangePan:(UIGestureRecognizer *)panGesture
{
    CGPoint point = [panGesture locationInView:self];
    CFIndex index = [self.composingUtils touchContentOffsetInView:self atPoint:point data:self.pageData textFrame:self.textFrame];
    if (index != -1 && index <= self.pageData.pageContent.length ) {
        if (cursorView == self.topCursorView) {
            if (index < _storeEndPosition) {
                _selectionEndPosition = _storeEndPosition;
                _selectionStartPosition = index;
            } else {
                _selectionStartPosition = _storeEndPosition;
                _selectionEndPosition = index;
            }
        }
        else if (cursorView == self.bottomCursorView) {
            if (index > _storeStartPosition) {
                _selectionStartPosition = _storeStartPosition;
                _selectionEndPosition = index;
            } else {
                _selectionEndPosition = _storeStartPosition;
                _selectionStartPosition = index;
            }
        }
    }
    self.textViewState = ARTextViewStateTouching;
    self.magnifierRange.hostCaptureCenter = point;
    self.magnifierRange.hostPopoverCenter = point;
    [[ARTextEffectWindow sharedWindow] moveMagnifier:self.magnifierRange];
    [self setNeedsDisplay];
}

- (void)cursorView:(ARTextCursor *)cursorView didEndPan:(UIGestureRecognizer *)panGesture
{
    if (self.delegate && [self.delegate  respondsToSelector:@selector(textViewDidSelectEnd:)]) {
        [self.delegate textViewDidSelectEnd:self];
    }
    [[ARTextEffectWindow sharedWindow] hideMagnifier:self.magnifierRange];
    [self becomeFirstResponder];
    CGRect selectRect = [self.composingUtils selectContentRectInView:self fromStartPosition:_selectionStartPosition toEndPosition:_selectionEndPosition data:self.pageData textFrame:self.textFrame];
    self.lastPoint =  [panGesture locationInView:self];
    if (_selectionStartPosition == _selectionEndPosition && _selectionStartPosition != -1) {
        [self.textMenuController setMenuItems:@[self.menuSelectAllItem]];
    } else {
        [self.textMenuController setMenuItems:@[self.menuExcerptItem,self.menuCreateItem,self.menuCopyItem]];
    }
    if (!self.textMenuController.menuVisible) {
        [self.textMenuController setTargetRect:selectRect inView:self];
        [self.textMenuController update];
        [self.textMenuController setMenuVisible:YES animated:YES];
    }
}

- (void)cursorView:(ARTextCursor *)cursorView didCancelPan:(UIGestureRecognizer *)panGesture
{
    if (self.delegate && [self.delegate  respondsToSelector:@selector(textViewDidSelectCancel:)]) {
        [self.delegate textViewDidSelectCancel:self];
    }
    [[ARTextEffectWindow sharedWindow] hideMagnifier:self.magnifierRange];
}

#pragma mark - Private Methods
- (void)commitUpdate
{
    self.needUpdate = YES;
    [[ARTransaction transactionWithTarget:self selector:@selector(updateIfNeeded)] commit];
}

- (void)updateIfNeeded
{
    if (self.isNeedUpdate) {
        [self update];
    }
}

- (void)update {
    self.needUpdate = NO;
    [self configAttributes];
    [self composingFrame];
    self.textViewState = ARTextViewStateNormal;
    if (self.excerptArray.count > 0) {
        [self.textExcerptlayer setNeedsDisplay];
    }
}

- (void)configAttributes
{
    self.defaultAttributes = nil;
    self.indentAttributes = nil;
    self.boldAttributes = nil;
    if (!self.font) {
        return;
    }
    NSMutableParagraphStyle *indentParaStyle = [[NSMutableParagraphStyle alloc] init];
    UIFontDescriptor *ctfFont = self.font.fontDescriptor;
    NSNumber *fontString = [ctfFont objectForKey:@"NSFontSizeAttribute"];

    NSMutableDictionary *defaultDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *indentDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *boldDic = [NSMutableDictionary dictionary];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    if (self.lineSpacing > 0) {
        paragraphStyle.lineSpacing = self.lineSpacing;
    }
    paragraphStyle.alignment = self.textAlignment;
    paragraphStyle.maximumLineHeight = self.font.lineHeight;
    paragraphStyle.minimumLineHeight = self.font.lineHeight;
    [defaultDic setObject:self.font forKey:NSFontAttributeName];
    [defaultDic setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [boldDic setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    
    if (self.lineSpacing > 0) {
        indentParaStyle.lineSpacing = self.lineSpacing;
    }
    indentParaStyle.maximumLineHeight = self.font.lineHeight;
    indentParaStyle.minimumLineHeight = self.font.lineHeight;
    indentParaStyle.alignment = self.textAlignment;
    if (self.indent) {
        indentParaStyle.firstLineHeadIndent = fontString.floatValue * 2.0;
    }
    [indentDic setObject:indentParaStyle forKey:NSParagraphStyleAttributeName];
    [indentDic setObject:self.font forKey:NSFontAttributeName];
    
    if (self.titleFont) {
        [boldDic setObject:self.titleFont forKey:NSFontAttributeName];
    } else {
        [boldDic setObject:[UIFont systemFontOfSize:fontString.floatValue + 5] forKey:NSFontAttributeName];
    }
    if (self.textColor) {
        [defaultDic setObject:self.textColor forKey:NSForegroundColorAttributeName];
        [indentDic setObject:self.textColor forKey:NSForegroundColorAttributeName];
        [boldDic setObject:self.textColor forKey:NSForegroundColorAttributeName];
    }
    self.defaultAttributes = [defaultDic copy];
    self.indentAttributes = [indentDic copy];
    self.boldAttributes = [boldDic copy];
}

- (void)composingFrame
{
    if (!self.pageData) {
        return;
    }
    if (!self.defaultAttributes || !self.indentAttributes) {
        return;
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.pageData.pageContent attributes:self.defaultAttributes];
    if (self.pageData.pageIndex == 0) {
        if (self.boldAttributes && self.pageData.pageTitleLength > 0) {
            [attributedString setAttributes:self.boldAttributes range:NSMakeRange(0, self.pageData.pageTitleLength)];
        }
    }
    if (self.pageData.pageIndentLocation != NSNotFound) {
        [attributedString setAttributes:self.indentAttributes range:NSMakeRange(self.pageData.pageIndentLocation, self.pageData.pageContent.length - self.pageData.pageIndentLocation)];
    }
    
    CGRect rect = self.bounds;
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    CFRange range = CTFrameGetVisibleStringRange(frame);
    if (range.length == self.pageData.pageDisplayContent.length) {
    } else {
        CFRelease(framesetter);
        framesetter  = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)[attributedString attributedSubstringFromRange:NSMakeRange(0, self.pageData.pageDisplayContent.length)]);
        frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    }
    self.textFrame = frame;
    self.excerptDelegate.pageContent = self.pageData.pageDisplayContent;
    self.textLayout = [ARTextLayout layoutWithCTFrame:frame size:rect.size fontSize:self.font.pointSize];
    self.excerptDelegate.pageLayout = self.textLayout;
    CFRelease(frame);
    CFRelease(framesetter);
    CFRelease(path);
}

- (void)showCursorView {
    [self addSubview:self.topCursorView];
    [self addSubview:self.bottomCursorView];
}

- (void)removeCursorView
{
    [self.topCursorView removeFromSuperview];
    [self.bottomCursorView removeFromSuperview];
}

#pragma mark - Gesture Action

- (void)userTapGestureDetected:(UITapGestureRecognizer *)tapGesture
{
    [self resignFirstResponder];
    CGPoint point = [tapGesture locationInView:self];
    [self removeCursorView];
    [self.textMenuController setMenuVisible:NO animated:YES];
    if (_textViewState == ARTextViewStateNormal) {
        self.currentLineValue = [self.composingUtils touchLineInView:self atPoint:point lineArray:self.excerptDelegate.underLineArray data:self.pageData textFrame:self.textFrame];
        if (self.currentLineValue) {
            /* Fix of bug
             issue 1
             When the reader center controller add tap gesture to scroll page.
             Quick tap the view will cause uicollectionviewcell disappear.
             Because of last tap location ARTextView becomeFirstResponder.
             closed by ArchyVan
             */
            [self becomeFirstResponder];
            self.textViewState = ARTextViewStateTouchLine;
            CGRect rect = [self.composingUtils selectContentRectInView:self withRange:self.currentLineValue.rangeValue data:self.pageData textFrame:self.textFrame];
            [self.textMenuController setMenuItems:@[self.menuDeleteExcerptItem,self.menuCreateItem, self.menuCopyItem]];
            [self.textMenuController setTargetRect:rect inView:self];
            [self.textMenuController setMenuVisible:YES animated:YES];
            NSLog(@"\n Hint Line!");
        }
    } else {
        self.textViewState = ARTextViewStateNormal;
    }
}

- (void)userLongPressedGuestureDetected:(UILongPressGestureRecognizer *)longPressGesture
{
    if (!self.isEditable) {
        NSLog(@"\n Can't Edit!");
        return;
    }
    [self resignFirstResponder];
    CGPoint point = [longPressGesture locationInView:self];
    if (longPressGesture.state == UIGestureRecognizerStateBegan)
    {
        [self removeCursorView];
        [self.textMenuController setMenuVisible:NO];
        CFIndex index = [self.composingUtils touchContentOffsetInView:self atPoint:point data:self.pageData textFrame:self.textFrame];
        if (index != -1 && index < self.pageData.pageContent.length) {
            _selectionStartPosition = index - 1;
            _selectionEndPosition = index + 1;
        } else {
            _selectionStartPosition = -1;
            _selectionEndPosition = -1;
            _storeStartPosition = -1;
            _storeEndPosition = -1;
        }
        _storeStartPosition = _selectionStartPosition;
        _storeEndPosition = _selectionEndPosition;
        self.magnifierCaret.hostPopoverCenter = point;
        self.magnifierCaret.hostCaptureCenter = point;
        [[ARTextEffectWindow sharedWindow] showMagnifier:self.magnifierCaret];
    }
    else if (longPressGesture.state == UIGestureRecognizerStateChanged) {
        CFIndex index = [self.composingUtils touchContentOffsetInView:self atPoint:point data:self.pageData textFrame:self.textFrame];
        if (index != -1 && index <= self.pageData.pageContent.length ) {
            if (_storeStartPosition != -1 && _storeEndPosition != -1) {
                if (index > _storeStartPosition) {
                    _selectionStartPosition = _storeStartPosition;
                    _selectionEndPosition = index;
                } else {
                    _selectionEndPosition = _storeStartPosition;
                    _selectionStartPosition = index;
                }
            } else {
                _selectionStartPosition = index - 1;
                _selectionEndPosition = index + 1;
            }
            [self showCursorView];
        }
        self.textViewState = ARTextViewStateTouching;
        self.magnifierCaret.hostPopoverCenter = point;
        self.magnifierCaret.hostCaptureCenter = point;
        [[ARTextEffectWindow sharedWindow] moveMagnifier:self.magnifierCaret];
    }
    else {
        [[ARTextEffectWindow sharedWindow] hideMagnifier:self.magnifierCaret];
        self.lastPoint = point;
        if (_selectionStartPosition >= 0 && _selectionEndPosition <= self.pageData.pageContent.length) {
            [self showCursorView];
            CGRect rect = [self.composingUtils selectContentRectInView:self fromStartPosition:_selectionStartPosition toEndPosition:_selectionEndPosition data:self.pageData textFrame:self.textFrame];
            if (_selectionStartPosition == _selectionEndPosition && _selectionStartPosition != -1) {
                [self.textMenuController setMenuItems:@[self.menuSelectAllItem]];
            } else {
                [self.textMenuController setMenuItems:@[self.menuExcerptItem,self.menuCreateItem,self.menuCopyItem]];
            }
            [self becomeFirstResponder];
            if (!self.textMenuController.menuVisible) {
                [self.textMenuController setTargetRect:rect inView:self];
                [self.textMenuController update];
                [self.textMenuController setMenuVisible:YES animated:YES];
            }
            self.textViewState = ARTextViewStateSelecting;
        } else {
            self.textViewState = ARTextViewStateNormal;
        }
    }
}

#pragma mark - UIMenuItemAction

- (void)textViewDidExcerpt:(UIMenuItem *)item
{
    if (self.pageData) {
        NSRange range = NSMakeRange(_selectionStartPosition, _selectionEndPosition - _selectionStartPosition);
        NSArray *lineArray =  [self.excerptManager addLineWithRange:range];
        if (!lineArray || lineArray.count == 0) {
            NSLog(@"\n None Excerpt");
            self.textViewState = ARTextViewStateNormal;
            return;
        }
        self.currentLineValue = [NSValue valueWithRange:range];
        if (self.delegate && [self.delegate respondsToSelector:@selector(textView:didDrawUnderline:)]) {
            [self.delegate textView:self didDrawUnderline:range];
        }
        self.excerptDelegate.underLineArray = lineArray;
        [self.textExcerptlayer setNeedsDisplay];
        self.textMenuController.menuItems = @[self.menuDeleteExcerptItem,self.menuCreateItem,self.menuCopyItem];
        [self.textMenuController update];
        [self.textMenuController setMenuVisible:YES animated:YES];
    }
    self.textViewState = ARTextViewStateNormal;
}

- (void)textViewDidCopy:(UIMenuItem *)item
{
    self.textViewState = ARTextViewStateNormal;
}

- (void)textViewDidDeleteExcerpt:(UIMenuItem *)item
{
    if (self.pageData) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(textView:didRemoveUnderline:)]){
            [self.delegate textView:self didRemoveUnderline:self.currentLineValue.rangeValue];
        }
        NSArray *array = [self.excerptDelegate underLineArray];
        NSArray *lineArray =  [self.excerptManager removeLineWithRange:self.currentLineValue.rangeValue];
        if (!array || array.count == 0) {
            self.textViewState = ARTextViewStateNormal;
            return;
        }
        self.excerptDelegate.underLineArray = lineArray;
        self.currentLineValue = nil;
        [self.textExcerptlayer setNeedsDisplay];
    }
    self.textViewState = ARTextViewStateNormal;
}

- (void)textViewDidCreate:(UIMenuItem *)item
{
    self.textViewState = ARTextViewStateNormal;
}

- (void)textViewDidSelectAll:(UIMenuItem *)item
{
    NSRange range = [self.composingUtils touchRangeInView:self atPoint:self.lastPoint data:self.pageData textFrame:self.textFrame];
    _selectionStartPosition = range.location;
    _selectionEndPosition = range.location + range.length;
    if (_selectionEndPosition == NSNotFound || _selectionStartPosition == NSNotFound || _selectionStartPosition == _selectionEndPosition || !_selectionEndPosition || !_selectionStartPosition) {
        _selectionStartPosition = -1;
        _selectionEndPosition = -1;
        self.textViewState = ARTextViewStateNormal;
        return;
    }
    CGRect rect = [self.composingUtils selectContentRectInView:self fromStartPosition:_selectionStartPosition toEndPosition:_selectionEndPosition data:self.pageData textFrame:self.textFrame];
    if (_selectionStartPosition == _selectionEndPosition && _selectionStartPosition != -1) {
        [self.textMenuController setMenuItems:@[self.menuSelectAllItem]];
    } else {
        [self.textMenuController setMenuItems:@[self.menuExcerptItem,self.menuCreateItem,self.menuCopyItem]];
    }
    [self.textMenuController setTargetRect:rect inView:self];
    [self.textMenuController update];
    [self.textMenuController setMenuVisible:YES animated:YES];
    self.textViewState = ARTextViewStateSelecting;
}

#pragma mark - ARAsyncLayerDelegate
- (ARAsyncLayerDisplayTask *)newAsyncDisplayTask
{
    ARAsyncLayerDisplayTask *task = [ARAsyncLayerDisplayTask new];
    task.willDisplay = ^(CALayer *layer) {
        layer.backgroundColor = self.backgroundColor.CGColor;
        layer.contentsScale = [UIScreen mainScreen].scale;
    };
    task.display = ^(CGContextRef ctx, CGSize size, BOOL(^isCancelled)(void)) {
        if (isCancelled()) {
            return;
        }
        if (!self.pageData) {
            return;
        }
        if (self.textFrame != nil) {
            CGContextRef context = ctx;
            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
            CGContextTranslateCTM(context, 0, self.bounds.size.height);
            CGContextScaleCTM(context, 1.0, -1.0);
            
            if (self.textViewState == ARTextViewStateSelecting || self.textViewState == ARTextViewStateTouching) {
                [self drawSelectionArea];
            }
            
            ARTextDrawText(self.textLayout, context);
        }
    };
    task.didDisplay = ^(CALayer *layer, BOOL finished) {
        layer.backgroundColor = self.backgroundColor.CGColor;
        if (self.textViewState == ARTextViewStateSelecting || self.textViewState == ARTextViewStateTouching) {
            [self drawAnchors];
        }
    };
    return task;
}

#pragma mark - Lazy Init
- (ARComposingUtils *)composingUtils
{
    if (!_composingUtils) {
        _composingUtils = [ARComposingUtils sharedInstance];
    }
    return _composingUtils;
}

- (ARTextCursor *)topCursorView
{
    if (!_topCursorView) {
        _topCursorView = [[ARTextCursor alloc] init];
        _topCursorView.cursorType = ARTextCursorTop;
        _topCursorView.panDelegate = self;
        [self addSubview:_topCursorView];
    }
    return _topCursorView;
}

- (ARTextCursor *)bottomCursorView
{
    if (!_bottomCursorView) {
        _bottomCursorView = [[ARTextCursor alloc] init];
        _bottomCursorView.cursorType = ARTextCursorBottom;
        _bottomCursorView.panDelegate = self;
        [self addSubview:_bottomCursorView];
    }
    return _bottomCursorView;
}

- (ARAsyncLayer *)textExcerptlayer
{
    if (!_textExcerptlayer) {
        _textExcerptlayer = [ARAsyncLayer layer];
        _textExcerptlayer.displaysAsynchronously = YES;
        _textExcerptlayer.frame = self.bounds;
        _textExcerptlayer.delegate = self.excerptDelegate;
        _textExcerptlayer.contentsScale = [UIScreen mainScreen].scale;
    }
    return _textExcerptlayer;
}

- (ARLineLayerDelegate *)excerptDelegate
{
    if (!_excerptDelegate) {
        _excerptDelegate = [[ARLineLayerDelegate alloc] init];
        _excerptDelegate.underLineSpacing = 5;
    }
    return _excerptDelegate;
}

- (ARLineManager *)excerptManager
{
    if (!_excerptManager) {
        _excerptManager = [[ARLineManager alloc] init];
    }
    return _excerptManager;
}

- (UIMenuController *)textMenuController
{
    if (!_textMenuController) {
        _textMenuController = [UIMenuController sharedMenuController];
    }
    return _textMenuController;
}

- (UIMenuItem *)menuCopyItem
{
    if (!_menuCopyItem) {
        _menuCopyItem = [[UIMenuItem alloc] initWithTitle:@"复制此段" action:@selector(textViewDidCopy:)];
    }
    return _menuCopyItem;
}

- (UIMenuItem *)menuExcerptItem
{
    if (!_menuExcerptItem) {
        _menuExcerptItem = [[UIMenuItem alloc] initWithTitle:@"摘录此段" action:@selector(textViewDidExcerpt:)];
    }
    return _menuExcerptItem;
}

- (UIMenuItem *)menuDeleteExcerptItem
{
    if (!_menuDeleteExcerptItem) {
        _menuDeleteExcerptItem = [[UIMenuItem alloc] initWithTitle:@"删除摘录" action:@selector(textViewDidDeleteExcerpt:)];
    }
    return _menuDeleteExcerptItem;
}

- (UIMenuItem *)menuCreateItem
{
    if (!_menuCreateItem) {
        _menuCreateItem = [[UIMenuItem alloc] initWithTitle:@"生成图片" action:@selector(textViewDidCreate:)];
    }
    return _menuCreateItem;
}

- (UIMenuItem *)menuSelectAllItem
{
    if (!_menuSelectAllItem) {
        _menuSelectAllItem = [[UIMenuItem alloc] initWithTitle:@"全选此段" action:@selector(textViewDidSelectAll:)];
    }
    return _menuSelectAllItem;
}

- (ARTextMagnifier *)magnifierCaret
{
    if (!_magnifierCaret) {
        _magnifierCaret = [ARTextMagnifier magnifierWithType:ARTextMagnifierTypeCaret];
        _magnifierCaret.hostView = self;
    }
    return _magnifierCaret;
}

- (ARTextMagnifier *)magnifierRange
{
    if (!_magnifierRange) {
        _magnifierRange = [ARTextMagnifier magnifierWithType:ARTextMagnifierTypeRanged];
        _magnifierRange.hostView = self;
    }
    return _magnifierRange;
}

@end

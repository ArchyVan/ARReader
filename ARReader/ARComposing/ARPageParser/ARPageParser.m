//
//  ARPageParser.m
//  LearnCoreText
//
//  Created by Objective-C on 2017/1/14.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "ARPageParser.h"
#import "ARPageData.h"
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
@interface ARPageParser ()

@property (nonatomic, copy) NSDictionary *defaultAttributes;
@property (nonatomic, copy) NSDictionary *indentAttributes;
@property (nonatomic, copy) NSDictionary *boldAttributes;

@end

@implementation ARPageParser

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ARPageParser *parser = nil;
    dispatch_once(&onceToken, ^{
        parser = [[ARPageParser alloc] init];
    });
    return parser;
}

- (void)setFontSize:(CGFloat)fontSize
{
    _fontSize = fontSize;
    [self configAttributes];
}

- (void)setLineSpacing:(CGFloat)lineSpacing
{
    _lineSpacing = lineSpacing;
    [self configAttributes];
}

- (void)setIndent:(BOOL)indent
{
    _indent = indent;
    [self configAttributes];
}

- (NSArray *)parseContent:(NSString *)content
{
    return [self parseContent:content cacheEnabled:NO];
}

- (NSArray *)parseContent:(NSString *)content cacheEnabled:(BOOL)cacheEnabled
{
    NSDate *date = [NSDate date];
    NSLog(@"\n Parsering Start");
    if (!content || content.length == 0) {
        NSLog(@"\n Content is nil");
        return nil;
    }
    if (!self.defaultAttributes || !self.indentAttributes) {
        NSLog(@"\n Parameters is not enough");
        return nil;
    }
    if (CGSizeEqualToSize(CGSizeZero, self.pageSize)) {
        NSLog(@"\n Must Set PageSize");
        return nil;
    }
    NSMutableArray *cacheImageArray = nil;
    if (cacheEnabled) {
        cacheImageArray = [NSMutableArray array];
    }
    NSMutableString *logString = [NSMutableString stringWithFormat:@"\n Parse Parameters:\n------------Parser------------\n  PageSize      -- %@\n  FontSize      -- %f\n  LineSpacing   -- %f\n  Indent        -- %@\n  ContentLength -- %lu",NSStringFromCGSize(self.pageSize),self.fontSize,self.lineSpacing,self.indent?@"YES":@"NO",(unsigned long)content.length];
    NSInteger maxCount = (self.pageSize.width / self.fontSize )+ 10.0;
    NSMutableArray *pageArray = [NSMutableArray array];
    NSDictionary *defaultAttributes = self.defaultAttributes;
    NSDictionary *firstLineHeadIndentAttributes = self.indentAttributes;
    //    if (self.customAttributes) {
    //        [self.customAttributes enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
    //            NSRange range = [key rangeValue];
    //            if ([obj isKindOfClass:[UIFont class]]) {
    //            } else if ([UIColor class]) {
    //            }
    //        }];
    //    }
    
    if (self.titleLength > 0) {
        [logString appendFormat:@"\n  TitleLength   -- %lu",(unsigned long)self.titleLength];
    }
    
    CGRect rect = CGRectMake(0, 0, self.pageSize.width, self.pageSize.height);
    [logString appendFormat:@"\n------------Parser------------"];
    NSLog(@"%@",logString);
    NSInteger rangeIndex = 0;
    NSInteger firstIndentLocation = self.titleLength;
    BOOL isPageParagraphEnd = NO;
    NSInteger maxLength = [self forecastMaxStringLength];
    for (NSInteger i = 0; rangeIndex < content.length && content.length > 0; i++) {
        NSUInteger length = MIN(maxLength, content.length - rangeIndex);
        NSMutableAttributedString *childString;
        childString = [[NSMutableAttributedString alloc] initWithString:[content substringWithRange:NSMakeRange(rangeIndex, length)] attributes:defaultAttributes];
        if (i == 0) {
            [childString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:22],NSParagraphStyleAttributeName:self.defaultAttributes[NSParagraphStyleAttributeName]} range:NSMakeRange(0, self.titleLength)];
        }
        if (!isPageParagraphEnd) {
            if (i != 0) {
                NSRange returnRange = [childString.string rangeOfString:@"\n"];
                if (returnRange.location != NSNotFound) {
                    firstIndentLocation = returnRange.location;
                    [childString setAttributes:firstLineHeadIndentAttributes range:NSMakeRange(returnRange.location, childString.length - returnRange.location)];
                } else {
                    firstIndentLocation = NSNotFound;
                }
            } else {
                [childString setAttributes:firstLineHeadIndentAttributes range:NSMakeRange(firstIndentLocation, childString.length - firstIndentLocation)];
            }
        } else {
            firstIndentLocation = 0;
            [childString setAttributes:firstLineHeadIndentAttributes range:NSMakeRange(0, childString.length)];
            isPageParagraphEnd = NO;
        }
        CTFramesetterRef childFramesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)childString);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, rect);
        
        CTFrameRef frame = CTFramesetterCreateFrame(childFramesetter, CFRangeMake(0, 0), path, NULL);
        
        CFRange cRange = CTFrameGetVisibleStringRange(frame);
        NSRange nRange = {rangeIndex, cRange.length};
        if (nRange.length > 0) {
            ARPageData *data = [[ARPageData alloc] init];
            data.pageStart = nRange.location;
            data.pageEnd = nRange.location + nRange.length;
            data.pageDisplayContent = [content substringWithRange:nRange];
            if (data.pageEnd + maxCount < content.length) {
                data.pageContent = [content substringWithRange:NSMakeRange(nRange.location, nRange.length + maxCount)];
            } else {
                data.pageContent = [content substringWithRange:NSMakeRange(nRange.location, content.length - nRange.location)];
            }
            if (i == 0) {
                data.pageTitleLength = self.titleLength;
            } else {
                data.pageTitleLength = 0;
            }
            data.pageIndex = i;
            CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(childFramesetter, CFRangeMake(0,0), nil,self.pageSize , nil);
            CGFloat textHeight = coreTextSize.height;
            data.pageHeight = textHeight;
            if (firstIndentLocation > data.pageDisplayContent.length) {
                firstIndentLocation = NSNotFound;
            }
            data.pageIndentLocation = firstIndentLocation;
            if ([data.pageDisplayContent hasSuffix:@"\n"]) {
                firstIndentLocation = 0;
                isPageParagraphEnd = YES;
            }
            [pageArray addObject:data];
            if (cacheEnabled) {
                [cacheImageArray addObject:[self pageImageWithFrame:frame]];
            }
        }
        rangeIndex += nRange.length;
        CFRelease(frame);
        CFRelease(childFramesetter);
        CFRelease(path);
    }
    if (cacheEnabled) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self cacheZipWithImageArray:cacheImageArray];
        });
    }
    NSLog(@"\n Parsering End,Page Count %lu,Cost %fs",(unsigned long)pageArray.count,[[NSDate date] timeIntervalSinceDate:date]);
    return pageArray;
}

- (ARPageData *)parseWholeContent:(NSString *)content
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content];
    NSDictionary *defaultAttributes = self.defaultAttributes;
    NSDictionary *firstLineHeadIndentAttributes = self.indentAttributes;
    [attributedString setAttributes:defaultAttributes range:NSMakeRange(0, content.length)];
    [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:22]} range:NSMakeRange(0, self.titleLength)];
    [attributedString setAttributes:firstLineHeadIndentAttributes range:NSMakeRange(11, attributedString.length - self.titleLength)];
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CGRect rect = CGRectMake(0, 0, self.pageSize.width, MAXFLOAT);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,0), nil, rect.size, nil);
    CGFloat textHeight = coreTextSize.height;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0,self.pageSize.width, textHeight));
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    ARPageData *pageData = [[ARPageData alloc] init];
    pageData.pageContent = content;
    pageData.pageDisplayContent = content;
    pageData.pageIndentLocation = 0;
    pageData.pageStart = 0;
    pageData.pageEnd = content.length;
    pageData.pageHeight = textHeight;
    pageData.pageIndex = 0;
    CFRelease(path);
    CFRelease(frame);
    CFRelease(framesetter);
    return pageData;
}

- (UIImage *)pageImageWithFrame:(CTFrameRef)frame
{
    UIGraphicsBeginImageContextWithOptions(self.pageSize, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.pageSize.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, self.pageSize.width, self.pageSize.height));
    CTFrameDraw(frame, context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)cacheZipWithImageArray:(NSArray *)imageArray
{
    [imageArray enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL * _Nonnull stop) {
        //这里可以做本地保存图片处理，用于进行比对下面是简单实例
//        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
//        NSString *imgPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"page_%lu.png",(unsigned long)idx]];
//        NSData *data = UIImagePNGRepresentation(image);
//        [data writeToFile:imgPath atomically:YES];
    }];
}

- (void)configAttributes
{
    self.defaultAttributes = nil;
    self.indentAttributes = nil;
    if (self.fontSize == 0) {
        return;
    }
    NSMutableDictionary *defaultDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *indentDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *boldDic = [NSMutableDictionary dictionary];
    UIFont *font = [UIFont systemFontOfSize:self.fontSize];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    if (self.lineSpacing > 0) {
        paragraphStyle.lineSpacing = 10;
    }
    paragraphStyle.maximumLineHeight = font.lineHeight;
    paragraphStyle.minimumLineHeight = font.lineHeight;
    paragraphStyle.alignment = self.textAlignment;
    [defaultDic setObject:font forKey:NSFontAttributeName];
    [defaultDic setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [boldDic setObject:[UIFont boldSystemFontOfSize:self.fontSize + 5] forKey:NSFontAttributeName];
    [boldDic setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    NSMutableParagraphStyle *indentParaStyle = [[NSMutableParagraphStyle alloc] init];
    if (self.lineSpacing > 0) {
        indentParaStyle.lineSpacing = 10;
    }
    indentParaStyle.maximumLineHeight = font.lineHeight;
    indentParaStyle.minimumLineHeight = font.lineHeight;
    indentParaStyle.alignment = self.textAlignment;
    if (self.isIndent) {
        indentParaStyle.firstLineHeadIndent = self.fontSize * 2.0;
    }
    [indentDic setObject:indentParaStyle forKey:NSParagraphStyleAttributeName];
    [indentDic setObject:font forKey:NSFontAttributeName];
    
    self.boldAttributes = [boldDic copy];
    self.defaultAttributes = [defaultDic copy];
    self.indentAttributes = [indentDic copy];
}

- (NSInteger)forecastMaxStringLength
{
    CGFloat maxLength = (self.pageSize.width/(self.fontSize / 4))*(self.pageSize.height / (self.fontSize + 10.5));
    NSLog(@"\n Page Forecast Max Length:%f",maxLength / 2.0);
    //汉字情况，英文情况不除以2;
    return maxLength / 2.0;
}

@end

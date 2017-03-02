//
//  ARReaderTest.m
//  ARReader
//
//  Created by Objective-C on 2017/2/10.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "ARReaderTest.h"

@interface ARReaderTest ()

@property (nonatomic, readwrite) NSString *readerContent;
@property (nonatomic, readwrite) ARPageParser *readerParser;

@end

@implementation ARReaderTest

- (NSString *)readerContent
{
    if (!_readerContent) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"sishen" ofType:@"txt"];
        unsigned long encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSData *responseData = [NSData dataWithContentsOfFile:path];
        NSString *content = [[NSString alloc] initWithData:responseData encoding:encode];
        //        NSString *newPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"txt"];
        //        NSString *content = [[NSString alloc] initWithContentsOfFile:newPath encoding:NSUTF8StringEncoding error:nil];
        _readerContent = content;
    }
    return _readerContent;
}

- (ARPageParser *)readerParser
{
    if (!_readerParser) {
        _readerParser = [ARPageParser sharedInstance];
        _readerParser.fontSize = 21;
        _readerParser.titleLength = 2;
        _readerParser.indent = YES;
        _readerParser.pageSize = CGSizeMake(ScreenWidth - 30, ScreenHeight - 80);
        _readerParser.lineSpacing = 10;
        _readerParser.textAlignment = NSTextAlignmentJustified;
    }
    return _readerParser;
}

@end

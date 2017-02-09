//
//  ARReaderParserTest.m
//  ARReader
//
//  Created by Objective-C on 2017/1/24.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ARPageParser.h"

@interface ARReaderParserTest : XCTestCase

@end

@implementation ARReaderParserTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testParserTime {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    ARPageParser *parser = [ARPageParser sharedInstance];
    parser.titleLength = 11;
    parser.fontSize = 21;
    parser.indent = YES;
    parser.textAlignment = NSTextAlignmentJustified;
    parser.lineSpacing = 10;
    [self measureBlock:^{
        [parser parserContent:content];
    }];
}

- (void)testParseContent {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    ARPageParser *parser = [ARPageParser sharedInstance];
    parser.titleLength = 11;
    parser.fontSize = 21;
    parser.indent = YES;
    parser.textAlignment = NSTextAlignmentJustified;
    parser.lineSpacing = 10;
    NSArray *array = [parser parserContent:content];
    NSMutableString *newContent = [NSMutableString string];
    for (ARPageData *pageData in array) {
        NSRange range = NSMakeRange(pageData.pageStart, pageData.pageEnd - pageData.pageStart);
        NSString *subContent = [content substringWithRange:range];
        BOOL stringEqual = [subContent isEqualToString:pageData.pageDisplayContent];
        XCTAssertTrue(stringEqual, @"The String is not Equal");
        [newContent appendString:pageData.pageDisplayContent];
    }
    BOOL contentEqual = [newContent isEqualToString:content];
    XCTAssertTrue(contentEqual, @"The Content is not Equal");
}


@end

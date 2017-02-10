//
//  ARReaderParserTest.m
//  ARReader
//
//  Created by Objective-C on 2017/2/10.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ARReaderTest.h"

@interface ARReaderParserTest : ARReaderTest

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
    [self measureBlock:^{
        [self.readerParser parseContent:self.readerContent];
    }];
}

- (void)testParseContent {
    NSArray *array = [self.readerParser parseContent:self.readerContent];
    NSMutableString *newContent = [NSMutableString string];
    for (ARPageData *pageData in array) {
        NSRange range = NSMakeRange(pageData.pageStart, pageData.pageEnd - pageData.pageStart);
        NSString *subContent = [self.readerContent substringWithRange:range];
        BOOL stringEqual = [subContent isEqualToString:pageData.pageDisplayContent];
        XCTAssertTrue(stringEqual, @"The String is not Equal");
        [newContent appendString:pageData.pageDisplayContent];
    }
    BOOL contentEqual = [newContent isEqualToString:self.readerContent];
    XCTAssertTrue(contentEqual, @"The Content is not Equal");
}


@end

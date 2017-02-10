//
//  ARReaderTest.h
//  ARReader
//
//  Created by Objective-C on 2017/2/10.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ARPageParser.h"

#define WAIT                                                                \
do {                                                                        \
[self expectationForNotification:@"ARUnitTest" object:nil handler:nil]; \
[self waitForExpectationsWithTimeout:60 handler:nil];                   \
} while(0);

#define NOTIFY                                                                            \
do {                                                                                      \
[[NSNotificationCenter defaultCenter] postNotificationName:@"ARUnitTest" object:nil]; \
} while(0);

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ARReaderTest : XCTestCase

@property (nonatomic, copy, readonly) NSString *readerContent;
@property (nonatomic, strong, readonly) ARPageParser *readerParser;

@end

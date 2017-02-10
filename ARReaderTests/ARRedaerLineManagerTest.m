//
//  ARRedaerLineManagerTest.m
//  ARReader
//
//  Created by Objective-C on 2017/2/10.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ARReaderTest.h"
#import "ARLineManager.h"

static inline NSValue *NSRangeValue(NSInteger location,NSInteger length){
    return [NSValue valueWithRange:NSMakeRange(location, length)];
}

@interface ARRedaerLineManagerTest : ARReaderTest

@property (nonatomic, strong) ARLineManager *lineManager;

@end

@implementation ARRedaerLineManagerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAddLine
{
    self.lineManager = [[ARLineManager alloc] init];
    self.lineManager.lineArray = @[NSRangeValue(0, 1),NSRangeValue(2, 10),NSRangeValue(30, 20)];
    [self.lineManager addLineWithRange:NSMakeRange(60, 5)];
    XCTAssertEqual(self.lineManager.lineArray.count, 4,"ADD Failed.");
    
    BOOL isCompleteEqual = YES;
    NSLog(@"\n %@",self.lineManager.lineArray);
    for (int i = 0; i < self.lineManager.lineArray.count; i++) {
        NSValue *range = self.lineManager.lineArray[i];
        NSRange aRange = range.rangeValue;
        if (i == 0) {
            if (!NSEqualRanges(aRange, NSMakeRange(0, 1))) {
                isCompleteEqual = NO;
                break;
            }
        }
        else if (i == 1) {
            if (!NSEqualRanges(aRange, NSMakeRange(2, 10))) {
                isCompleteEqual = NO;
                break;
            }
        }
        else if (i == 2) {
            if (!NSEqualRanges(aRange, NSMakeRange(30, 20))) {
                isCompleteEqual = NO;
                break;
            }
        }
        else if (i == 3) {
            if (!NSEqualRanges(aRange, NSMakeRange(60, 5))) {
                isCompleteEqual = NO;
                break;
            }
        }
    }
    XCTAssertTrue(isCompleteEqual,"The Result is't complete equal.");
}

- (void)testAddIntersectionLine
{
    NSRange testRange;
    self.lineManager = [[ARLineManager alloc] init];
    self.lineManager.lineArray = @[NSRangeValue(0, 1),NSRangeValue(2, 10),NSRangeValue(30, 20)];
    [self.lineManager addLineWithRange:NSMakeRange(3, 10)];
    NSLog(@"\n %@",self.lineManager.lineArray);
    XCTAssertEqual(self.lineManager.lineArray.count, 3,"ADD Failed.");
    testRange = ((NSValue *)self.lineManager.lineArray[2]).rangeValue;
    XCTAssertTrue(NSEqualRanges(NSMakeRange(2, 11), testRange),"Range is Not Equal");
    
    self.lineManager = [[ARLineManager alloc] init];
    self.lineManager.lineArray = @[NSRangeValue(0, 1),NSRangeValue(2, 10),NSRangeValue(30, 20)];
    [self.lineManager addLineWithRange:NSMakeRange(3, 30)];
    NSLog(@"\n %@",self.lineManager.lineArray);
    XCTAssertEqual(self.lineManager.lineArray.count, 2,"ADD Failed.");
    testRange = ((NSValue *)self.lineManager.lineArray[1]).rangeValue;
    XCTAssertTrue(NSEqualRanges(NSMakeRange(2, 48), testRange),"Range is Not Equal");
    

    self.lineManager = [[ARLineManager alloc] init];
    self.lineManager.lineArray = @[NSRangeValue(0, 1),NSRangeValue(2, 10),NSRangeValue(30, 20)];
    [self.lineManager addLineWithRange:NSMakeRange(0, 60)];
    NSLog(@"\n %@",self.lineManager.lineArray);
    XCTAssertEqual(self.lineManager.lineArray.count, 1,"ADD Failed.");
    testRange = ((NSValue *)self.lineManager.lineArray[0]).rangeValue;
    XCTAssertTrue(NSEqualRanges(NSMakeRange(0, 60), testRange),"Range is Not Equal");
}

- (void)testRemoveLine
{
    self.lineManager = [[ARLineManager alloc] init];
    self.lineManager.lineArray = @[NSRangeValue(0, 1),NSRangeValue(2, 10),NSRangeValue(30, 20)];
    [self.lineManager removeLineWithRange:NSMakeRange(30, 20)];
    NSLog(@"\n %@",self.lineManager.lineArray);
    XCTAssertEqual(self.lineManager.lineArray.count, 2,"Remove Failed.");
    BOOL isCompleteEqual = YES;
    for (int i = 0; i < self.lineManager.lineArray.count; i++) {
        NSValue *range = self.lineManager.lineArray[i];
        NSRange aRange = range.rangeValue;
        if (i == 0) {
            if (!NSEqualRanges(aRange, NSMakeRange(0, 1))) {
                isCompleteEqual = NO;
                break;
            }
        }
        else if (i == 1) {
            if (!NSEqualRanges(aRange, NSMakeRange(2, 10))) {
                isCompleteEqual = NO;
                break;
            }
        }
    }
    XCTAssertTrue(isCompleteEqual,"The Result is't complete equal.");
}

- (void)testRemoveIntersectionLine
{
    self.lineManager = [[ARLineManager alloc] init];
    self.lineManager.lineArray = @[NSRangeValue(0, 1),NSRangeValue(3, 10),NSRangeValue(30, 20)];
    [self.lineManager removeLineWithRange:NSMakeRange(4, 15)];
    NSLog(@"\n %@",self.lineManager.lineArray);
    XCTAssertEqual(self.lineManager.lineArray.count, 2,"Remove Failed.");
    BOOL isCompleteEqual = YES;
    for (int i = 0; i < self.lineManager.lineArray.count; i++) {
        NSValue *range = self.lineManager.lineArray[i];
        NSRange aRange = range.rangeValue;
        if (i == 0) {
            if (!NSEqualRanges(aRange, NSMakeRange(0, 1))) {
                isCompleteEqual = NO;
                break;
            }
        }
        else if (i == 1) {
            if (!NSEqualRanges(aRange, NSMakeRange(30, 20))) {
                isCompleteEqual = NO;
                break;
            }
        }
    }
    XCTAssertTrue(isCompleteEqual,"The Result is't complete equal.");
}

@end

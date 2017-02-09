//
//  ARPageData.m
//  LearnCoreText
//
//  Created by Objective-C on 2017/1/13.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "ARPageData.h"

@implementation ARPageData

- (NSDictionary *)convertToDictionary
{
    NSMutableDictionary *pageDic = [NSMutableDictionary dictionary];
    if (self.pageContent && self.pageContent.length > 0) {
        [pageDic setObject:self.pageContent forKey:@"content"];
    }
    if (self.pageDisplayContent && self.pageDisplayContent.length > 0) {
        [pageDic setObject:self.pageDisplayContent forKey:@"displayContent"];
    }
    if (self.pageStart) {
        [pageDic setObject:@(self.pageStart) forKey:@"start"];
    }
    if (self.pageEnd) {
        [pageDic setObject:@(self.pageEnd) forKey:@"end"];
    }
    if (self.pageIndentLocation) {
        [pageDic setObject:@(self.pageIndentLocation) forKey:@"indentLocation"];
    }
    if (self.pageIndex) {
        [pageDic setObject:@(self.pageIndex) forKey:@"index"];
    }
    if (self.pageHeight) {
        [pageDic setObject:@(self.pageHeight) forKey:@"height"];
    }
    if ([pageDic allKeys].count == 0) {
        return nil;
    }
    return pageDic;
}

+ (ARPageData *)pageDataWithDictionary:(NSDictionary *)dictionary
{
    ARPageData *pageData = [[ARPageData alloc] init];
    pageData.pageStart = [dictionary[@"start"] integerValue];
    pageData.pageEnd = [dictionary[@"end"] integerValue];
    pageData.pageHeight = [dictionary[@"height"] floatValue];
    pageData.pageContent = dictionary[@"content"];
    pageData.pageDisplayContent = dictionary[@"displayContent"];
    pageData.pageIndentLocation = [dictionary[@"indentLocation"] integerValue];
    pageData.pageIndex = [dictionary[@"index"] integerValue];
    return pageData;
}

@end

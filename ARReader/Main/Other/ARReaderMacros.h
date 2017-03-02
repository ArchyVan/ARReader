//
//  ARReaderMacros.h
//  ARReader
//
//  Created by Objective-C on 2017/2/15.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#ifndef ARReaderMacros_h
#define ARReaderMacros_h

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height


#define AR_UNAVAILABLE_INSTEAD(s) __attribute__((unavailable(s)))
#define AR_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))

#ifndef DUMMY_CLASS
#define DUMMY_CLASS(name) \
@interface DUMMY_CLASS_ ## name : NSObject @end \
@implementation DUMMY_CLASS_ ## name @end
#endif

#endif /* ARReaderMacros_h */

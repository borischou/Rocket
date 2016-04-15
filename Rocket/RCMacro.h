//
//  RCMacro.h
//  Rocket
//
//  Created by Zhouboli on 16/4/15.
//  Copyright © 2016年 Bankwel. All rights reserved.
//

#ifndef RCMacro_h
#define RCMacro_h

#pragma mark - Measurement

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kNavigationBarHeight 64
#define kTabBarHeight 49

#pragma mark - Thread

#define dispatch_async_main_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

#pragma mark - ARC

#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) NSAutoreleasePool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) NSAutoreleasePool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

#endif /* RCMacro_h */

//
//  RCUberData.m
//  Rocket
//
//  Created by Zhouboli on 16/4/15.
//  Copyright © 2016年 Bankwel. All rights reserved.
//

#import "RCUberData.h"

@implementation RCUberData

-(RCUberData *)sharedInstance
{
    static dispatch_once_t onceToken;
    static RCUberData *_instance;
    dispatch_once(&onceToken, ^{
        _instance = [[RCUberData alloc] init];
    });
    return _instance;
}

@end

//
//  UberSurgeConfirmation.m
//  hack
//
//  Created by Zhouboli on 15/7/22.
//  Copyright (c) 2015年 Bankwel. All rights reserved.
//

#import "UberSurgeConfirmation.h"

@implementation UberSurgeConfirmation

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _href = [dictionary objectForKey:@"href"];
        _surge_confirmation_id = [dictionary objectForKey:@"surge_confirmation_id"];
    }
    return self;
}

@end

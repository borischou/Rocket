//
//  UberSurgeError.m
//  hack
//
//  Created by Zhouboli on 15/7/23.
//  Copyright (c) 2015年 Bankwel. All rights reserved.
//

#import "UberSurgeError.h"

@implementation UberSurgeError

- (instancetype) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _status = [dictionary objectForKey:@"status"];
        _code = [dictionary objectForKey:@"code"];
        _title = [dictionary objectForKey:@"title"];
    }
    return self;
}

@end

//
//  UberActivity.m
//  UberKitDemo
//
//  Created by Sachin Kesiraju on 9/21/14.
//  Copyright (c) 2014 Sachin Kesiraju. All rights reserved.
//

#import "UberActivity.h"

@implementation UberActivity

- (instancetype) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if(self)
    {
        _uuid = [dictionary objectForKey:@"uuid"];
        _product_id = [dictionary objectForKey:@"product_id"];
        _status = [dictionary objectForKey:@"status"];
        if (![dictionary[@"distance"] isEqual:[NSNull null]]) {
            _distance = [dictionary[@"distance"] floatValue];
        }
        if (![dictionary[@"request_time"] isEqual:[NSNull null]]) {
            _request_time = [dictionary[@"request_time"] intValue];
        }
        if (![dictionary[@"start_time"] isEqual:[NSNull null]]) {
            _start_time = [dictionary[@"start_time"] intValue];
        }
        if (![dictionary[@"end_time"] isEqual:[NSNull null]]) {
            _end_time = [dictionary[@"end_time"] intValue];
        }
    }
    return self;
}

@end

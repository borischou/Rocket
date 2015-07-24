//
//  UberRequest.m
//  Pods
//
//  Created by Zhouboli on 15/7/10.
//
//

#import "UberRequest.h"

@implementation UberRequest

- (instancetype) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _request_id = dictionary[@"request_id"];
        _status = dictionary[@"status"];
        if (![dictionary[@"driver"] isEqual:[NSNull null]]) {
            _driver = [[UberDriver alloc] initWithDictionary:dictionary[@"driver"]];
        }
        if (![dictionary[@"vehicle"] isEqual:[NSNull null]]) {
            _vehicle = [[UberVehicle alloc] initWithDictionary:dictionary[@"vehicle"]];
        }
        if (![dictionary[@"location"] isEqual:[NSNull null]]) {
            _location = [[UberLocation alloc] initWithDictionary:dictionary[@"location"]];
        }
        if (![dictionary[@"eta"] isEqual:[NSNull null]]) {
            _eta = [dictionary[@"eta"] integerValue];
        }
        if (![dictionary[@"surge_multiplier"] isEqual:[NSNull null]]) {
            _surge_multiplier = [dictionary[@"surge_multiplier"] floatValue];
        }
    }
    return self;
}

@end

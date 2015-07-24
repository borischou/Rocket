//
//  UberLocation.m
//  Pods
//
//  Created by Zhouboli on 15/7/10.
//
//

#import "UberLocation.h"

@implementation UberLocation

- (instancetype) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        if (![[dictionary objectForKey:@"latitude"] isEqual:[NSNull null]]) {
            _latitude = [[dictionary objectForKey:@"latitude"] floatValue];
        }
        if (![[dictionary objectForKey:@"longitude"] isEqual:[NSNull null]]) {
            _longitude = [[dictionary objectForKey:@"longitude"] floatValue];
        }
        if (![[dictionary objectForKey:@"bearing"] isEqual:[NSNull null]]) {
            _bearing = [[dictionary objectForKey:@"bearing"] integerValue];
        }
    }
    return self;
}

@end

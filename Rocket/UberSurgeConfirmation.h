//
//  UberSurgeConfirmation.h
//  hack
//
//  Created by Zhouboli on 15/7/22.
//  Copyright (c) 2015年 Bankwel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UberSurgeConfirmation : NSObject

@property (strong, nonatomic) NSString *href;
@property (strong, nonatomic) NSString *surge_confirmation_id;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

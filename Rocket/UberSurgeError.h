//
//  UberSurgeError.h
//  hack
//
//  Created by Zhouboli on 15/7/23.
//  Copyright (c) 2015年 Bankwel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UberSurgeError : NSObject

@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *title;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;

@end

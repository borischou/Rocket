//
//  Utils.h
//  BankwelLiuxue
//
//  Created by Zhouboli on 15/12/11.
//  Copyright © 2015年 bankwel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utils : NSObject

+(void)presentNotificationWithText:(NSString *)text;
+(void)presentNotificationOnMainThreadWithText:(NSString *)text;

@end

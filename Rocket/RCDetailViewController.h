//
//  HKDetailViewController.h
//  hack
//
//  Created by Zhouboli on 15/7/21.
//  Copyright (c) 2015年 Bankwel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UberKit.h"

@interface RCDetailViewController : UIViewController

@property (strong, nonatomic) NSDictionary *startLocation;
@property (strong, nonatomic) NSDictionary *destLocation;

-(void)rideRequestWithProductId:(NSString *)productid startLocation:(CLLocation *)start destLocation:(CLLocation *)dest surgeConfirmationId:(id)surge_confirmation_id;

@end

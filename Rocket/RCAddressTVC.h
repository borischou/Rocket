//
//  HKAddressTVC.h
//  hack
//
//  Created by Zhouboli on 15/7/15.
//  Copyright (c) 2015年 Bankwel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapSearchAPI.h>

@protocol RCAddressTVDelegate <NSObject>

@required

-(void)selectedPoiObject:(id)poiObj;

@end

@interface RCAddressTVC : UIViewController

@property (weak, nonatomic) id <RCAddressTVDelegate> delegate;

@property (strong, nonatomic) NSArray *pois;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (nonatomic) BOOL isForPickup;

@end

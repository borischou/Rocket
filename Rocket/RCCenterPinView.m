//
//  HKCenterPinView.m
//  hack
//
//  Created by Zhouboli on 15/7/19.
//  Copyright (c) 2015年 Bankwel. All rights reserved.
//

#import "HKCenterPinView.h"

@implementation HKCenterPinView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.image = [UIImage imageNamed:@"hk_center_3"];
    }
    return self;
}

@end

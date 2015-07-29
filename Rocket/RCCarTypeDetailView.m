//
//  RCCarTypeDetailView.m
//  Rocket
//
//  Created by Zhouboli on 15/7/29.
//  Copyright (c) 2015年 Bankwel. All rights reserved.
//

#import "RCCarTypeDetailView.h"

@implementation RCCarTypeDetailView

-(id)init
{
    self = [super init];
    if (self) {
        [self initViewSettings];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViewSettings];
    }
    return self;
}

-(void)initViewSettings
{
    self.backgroundColor = [UIColor purpleColor];
}

@end

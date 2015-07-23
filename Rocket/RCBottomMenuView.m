//
//  HKBottomMenuView.m
//  hack
//
//  Created by Zhouboli on 15/7/16.
//  Copyright (c) 2015年 Bankwel. All rights reserved.
//

#import "HKBottomMenuView.h"
#import "UIButton+Bobtn.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define bMenuHeight bHeight/10
#define bBigGap 5
#define bBtnWidth (bWidth-10-10)/5
#define bBtnHeight (bMenuHeight - 4*bBigGap)
#define bBtnColor [UIColor colorWithRed:0.f green:187/255.f blue:156/255.f alpha:1]

@implementation HKBottomMenuView

-(id)init
{
    self = [super initWithFrame:CGRectMake(0, bHeight - bMenuHeight, bWidth, bMenuHeight)];
    if (self) {
        [self initMenuLayout];
    }
    return self;
}

-(void)initMenuLayout
{
    self.backgroundColor = [UIColor whiteColor];

    _compareBtn = [[UIButton alloc] initWithFrame:CGRectMake(bBigGap, bBigGap, bBtnWidth, bBtnHeight) andTitle:@"比一比" withBackgroundColor:[UIColor colorWithRed:61/255.f green:134/255.f blue:198/255.f alpha:1] andTintColor:[UIColor purpleColor]];
    _compareBtn.layer.cornerRadius = 5;
    [self addSubview:_compareBtn];
    
    _requestBtn = [[UIButton alloc] initWithFrame:CGRectMake(bBtnWidth*4+bBigGap*3, bBigGap, bBtnWidth, bBtnHeight) andTitle:@"立即叫车" withBackgroundColor:bBtnColor andTintColor:[UIColor lightTextColor]];
    _requestBtn.layer.cornerRadius = 5;
    [self addSubview:_requestBtn];
    
    _destLbl = [[UILabel alloc] initWithFrame:CGRectMake(bBtnWidth+bBigGap*2, bBigGap, bBtnWidth*3, bBtnHeight)];
    _destLbl.backgroundColor = [UIColor whiteColor];
    _destLbl.textColor = [UIColor darkGrayColor];
    _destLbl.layer.borderWidth = 1.f;
    _destLbl.layer.borderColor = bBtnColor.CGColor;
    _destLbl.text = @"请输入目的地";
    _destLbl.textAlignment = NSTextAlignmentCenter;
    _destLbl.userInteractionEnabled = YES;
    [self addSubview:_destLbl];
}

@end

//
//  HKBottomMenuView.m
//  hack
//
//  Created by Zhouboli on 15/7/16.
//  Copyright (c) 2015年 Bankwel. All rights reserved.
//

#import "RCBottomMenuView.h"
#import "UIButton+Bobtn.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define bMenuHeight bHeight/10
#define bBigGap 10
#define bSmallGap 5
#define bBtnWidth (bWidth-20-4*5)/5
#define bBtnHeight (bMenuHeight - 4*bSmallGap)
#define bBtnColor [UIColor colorWithRed:0.f green:187/255.f blue:156/255.f alpha:1]

@implementation RCBottomMenuView

-(id)init
{
    self = [super initWithFrame:CGRectMake(0, bHeight - bMenuHeight, bWidth, bMenuHeight)];
    if (self)
    {
        [self initMenuLayout];
    }
    return self;
}

-(void)initMenuLayout
{
    self.backgroundColor = [UIColor whiteColor];
    
    _requestBtn = [[UIButton alloc] initWithFrame:CGRectMake(bBtnWidth*3+bBigGap+bSmallGap*3, bBigGap+bSmallGap, bBtnWidth*2+bSmallGap, bBtnHeight) andTitle:@"立即叫车" withBackgroundColor:bBtnColor andTintColor:[UIColor lightTextColor]];
    [_requestBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    _requestBtn.layer.cornerRadius = 5;
    [self addSubview:_requestBtn];
    
    _destLbl = [[UILabel alloc] initWithFrame:CGRectMake(bBigGap, bBigGap+bSmallGap, bBtnWidth*3+bSmallGap*2, bBtnHeight)];
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

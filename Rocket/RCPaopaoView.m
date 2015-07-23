//
//  HKPaopaoView.m
//  hack
//
//  Created by Zhouboli on 15/7/16.
//  Copyright (c) 2015年 Bankwel. All rights reserved.
//

#import "HKPaopaoView.h"
#import "UIButton+Bobtn.h"

#define bBtnColor [UIColor colorWithRed:0.f green:187/255.f blue:156/255.f alpha:1]

@implementation HKPaopaoView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initLayoutWithFrame:frame];
    }
    return self;
}

-(void)initLayoutWithFrame:(CGRect)frame
{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 8;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1.f;
    self.layer.borderColor = bBtnColor.CGColor;
    
    _addrLbl = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, frame.size.width - 10, frame.size.height - 10)];
    _addrLbl.numberOfLines = 1;
    _addrLbl.lineBreakMode = NSLineBreakByWordWrapping;
    _addrLbl.textColor = [UIColor darkGrayColor];
    _addrLbl.userInteractionEnabled = YES;
    
    [self addSubview:_addrLbl];
}

@end

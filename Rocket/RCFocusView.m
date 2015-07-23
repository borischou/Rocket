//
//  HKFocusView.m
//  hack
//
//  Created by Zhouboli on 15/7/20.
//  Copyright (c) 2015年 Bankwel. All rights reserved.
//

#import "HKFocusView.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

#define bMenuHeight bHeight/5
#define bScaleBarHeight 30
#define bFocusBtnHeight 40
#define bPaopaoViewHeight 40
#define bBtnColor [UIColor colorWithRed:0.f green:187/255.f blue:156/255.f alpha:1]

@interface HKFocusView ()

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation HKFocusView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, frame.size.width - 6, frame.size.height - 6)];
        _imageView.image = [UIImage imageNamed:@"hk_focus_8"];
        [self addSubview:_imageView];
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
        self.layer.cornerRadius = 8;
        self.layer.borderWidth = 1;
        self.layer.borderColor = bBtnColor.CGColor;
    }
    return self;
}

@end

//
//  BBNotificationView.m
//  Bobo
//
//  Created by Boris Chow on 8/31/15.
//  Copyright (c) 2015 Zhouboli. All rights reserved.
//

#import "BLNotificationView.h"
#import "RCMacro.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height

@interface BLNotificationView ()

@end

@implementation BLNotificationView

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self setFrame:CGRectMake(0, -statusBarHeight*2, bWidth, statusBarHeight*2)];
        //[self addSwipeGesture];
        [self setupShadow];
        [self setupNotificationView];
    }
    return self;
}

-(instancetype)initWithNotification:(NSString *)text
{
    self = [super init];
    if (self) {
        [self setFrame:CGRectMake(0, -statusBarHeight*2, bWidth, statusBarHeight*2)];
        //[self addSwipeGesture];
        [self setupShadow];
        [self setupNotificationViewWithText:text];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationClicked) name:@"removeNotificationAnimations" object:nil];
    }
    return self;
}

-(void)setupShadow
{
    self.alpha = 0.75;
    self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 1.0);
    self.layer.shadowRadius = 2.0;
    self.layer.shadowOpacity = 0.9;
}

-(void)setupNotificationView
{
    self.backgroundColor = [UIColor blueColor];
    
    _notificationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, statusBarHeight, bWidth, statusBarHeight)];
    _notificationLabel.textAlignment = NSTextAlignmentCenter;
    _notificationLabel.numberOfLines = 1;
    _notificationLabel.font = [UIFont systemFontOfSize:12.0];
    _notificationLabel.textColor = [UIColor whiteColor];
    _notificationLabel.userInteractionEnabled=YES;
    [self addSubview:_notificationLabel];
}

-(void)setupNotificationViewWithText:(NSString *)text
{
    [self setupNotificationView];
    _notificationLabel.text = text;
}
-(void)notificationClicked
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
         self.frame = CGRectMake(0, -2*statusBarHeight, kScreenWidth, 0);
         _notificationLabel.frame = CGRectMake(0, -2*statusBarHeight, kScreenWidth, 0);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
@end

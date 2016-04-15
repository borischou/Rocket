//
//  Utils.m
//  BankwelLiuxue
//
//  Created by Zhouboli on 15/12/11.
//  Copyright © 2015年 bankwel. All rights reserved.
//

#import "Utils.h"
#import "BLNotificationView.h"
#import "AppDelegate.h"
#import "RCMacro.h"

@implementation Utils

+(void)presentNotificationOnMainThreadWithText:(NSString *)text
{
    dispatch_async_main_safe(^{
        [self presentNotificationWithText:text];
    });
}

+(void)presentNotificationWithText:(NSString *)text
{
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    BLNotificationView *notificationView = [[BLNotificationView alloc] initWithNotification:text];
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.window addSubview:notificationView];
    [delegate.window bringSubviewToFront:notificationView];
  
    UIView *gestureReceiveView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kNavigationBarHeight+20)];
    gestureReceiveView.backgroundColor = [UIColor clearColor];
    [delegate.window addSubview:gestureReceiveView];
    [delegate.window bringSubviewToFront:gestureReceiveView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(notificationClicked)];
    [gestureReceiveView addGestureRecognizer:tap];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [notificationView setFrame:CGRectMake(0, 0, kScreenWidth, 2*statusBarHeight)];
    }
    completion:^(BOOL finished)
    {
        [UIView animateWithDuration:0.2 delay:2.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [notificationView setFrame:CGRectMake(0, -2*statusBarHeight, kScreenWidth, 2*statusBarHeight)];
        }
        completion:^(BOOL finished)
        {
            [notificationView removeFromSuperview];
            [gestureReceiveView removeFromSuperview];
        }];
    }];
  
}

+(void)notificationClicked
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"removeNotificationAnimations" object:nil];
}

@end

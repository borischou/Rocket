//
//  AppDelegate.m
//  Rocket
//
//  Created by Zhouboli on 15/7/23.
//  Copyright (c) 2015年 Bankwel. All rights reserved.
//

#import "AppDelegate.h"
#import "RCMainViewController.h"
#import "UberKit.h"
#import "SWRevealViewController.h"
#import "RCProfileTableViewController.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

@interface AppDelegate ()

@property (strong, nonatomic) SWRevealViewController *swrevealVC;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    RCMainViewController *rcmvc = [[RCMainViewController alloc] init];
    rcmvc.title = @"打车神器";
    rcmvc.view.backgroundColor = [UIColor whiteColor];
    
    UINavigationController *front_uinvc = [[UINavigationController alloc] initWithRootViewController:rcmvc];

    RCProfileTableViewController *profileTVC = [[RCProfileTableViewController alloc] init];
    profileTVC.title = @"Profile";
    profileTVC.tableView.backgroundColor = [UIColor whiteColor];
        
    _swrevealVC = [[SWRevealViewController alloc] initWithRearViewController:profileTVC frontViewController:front_uinvc];
    
    self.window.rootViewController = _swrevealVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSLog(@"handleOpenURL");
    return YES;
}

-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
    NSLog(@"openURL");
    return YES;
}

@end

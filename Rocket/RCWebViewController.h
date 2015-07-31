//
//  RCWebViewController.h
//  Rocket
//
//  Created by Zhouboli on 15/7/27.
//  Copyright (c) 2015年 Bankwel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RCWebViewControllerDelegate <NSObject>

@optional
-(void)didReceivedSurgeConfirmationId:(NSString *)idstr;

@end

@interface RCWebViewController : UIViewController

@property (weak, nonatomic) id <RCWebViewControllerDelegate> delegate;

@property (strong, nonatomic) UIWebView *webView;
@property (copy, nonatomic) NSString *url;
 
@end

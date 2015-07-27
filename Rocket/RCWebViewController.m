//
//  RCWebViewController.m
//  Rocket
//
//  Created by Zhouboli on 15/7/27.
//  Copyright (c) 2015年 Bankwel. All rights reserved.
//

#import "RCWebViewController.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

@interface RCWebViewController () <UIWebViewDelegate>

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation RCWebViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, bWidth, bHeight-[UIApplication sharedApplication].statusBarFrame.size.height)];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(17, [UIApplication sharedApplication].statusBarFrame.size.height+10, 23, 23)];
    _imageView.image = [UIImage imageNamed:@"rc_cha_2"];
    _imageView.userInteractionEnabled = YES;
    [_imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chaImageViewTapped:)]];
    [self.view addSubview:_imageView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self openWebViewWithURL:_url];
}

#pragma mark - Gesture

-(void)chaImageViewTapped:(UITapGestureRecognizer *)tap
{
    NSLog(@"Hello");
    [self dismissViewControllerAnimated:YES completion:^{
        //do something
    }];
}

#pragma mark - UIWebViewDelegate & Helpers

-(void)openWebViewWithURL:(NSString *)url
{
    NSURLRequest *request = nil;
    if (url) {
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    } else {
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.zuiyoudai.com"]];
    }
    [_webView loadRequest:request];
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    _activityIndicator.center = webView.center;
    _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:_activityIndicator];
    [_activityIndicator startAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_activityIndicator stopAnimating];
    [_activityIndicator removeFromSuperview];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_activityIndicator stopAnimating];
    [_activityIndicator removeFromSuperview];
    [[[UIAlertView alloc] initWithTitle:@"出错了" message:[NSString stringWithFormat:@"错误信息: %@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

@end

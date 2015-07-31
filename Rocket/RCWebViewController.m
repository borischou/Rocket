//
//  RCWebViewController.m
//  Rocket
//
//  Created by Zhouboli on 15/7/27.
//  Copyright (c) 2015年 Bankwel. All rights reserved.
//

#import "RCWebViewController.h"
#import "UberKit.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

#define bSurgeRedirectUrl @"https://www.uber.com"

@interface RCWebViewController () <UIWebViewDelegate>

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation RCWebViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self loadWebView];
    [self loadCrossView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self openWebViewWithURL:_url];
}

#pragma mark - Helpers

-(void)loadWebView
{
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, bWidth, bHeight-[UIApplication sharedApplication].statusBarFrame.size.height)];
    _webView.delegate = self;
    [self.view addSubview:_webView];
}

-(void)loadCrossView
{
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(17, [UIApplication sharedApplication].statusBarFrame.size.height+10, 23, 23)];
    _imageView.image = [UIImage imageNamed:@"rc_cha_2"];
    _imageView.userInteractionEnabled = YES;
    [_imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chaImageViewTapped:)]];
    [self.view addSubview:_imageView];
}

#pragma mark - Gesture

-(void)chaImageViewTapped:(UITapGestureRecognizer *)tap
{
    [self dismissViewControllerAnimated:YES completion:^{
        //用户拒绝加价后续动作
    }];
}

#pragma mark - UIWebViewDelegate & Helpers

-(void)openWebViewWithURL:(NSString *)url
{
    NSURLRequest *request = nil;
    if (url) {
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [_webView loadRequest:request];
        
//        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"surge_confirmation_page" ofType:@"html"];
//        NSString *htmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
//        [_webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:filePath]];
    } else {
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.zuiyoudai.com"]];
        [_webView loadRequest:request];
    }
}

-(void)resolveAuthRequest:(NSURLRequest *)request
{
    NSString *code = nil;
    NSArray *urlParams = [[request.URL query] componentsSeparatedByString:@"&"];
    for (NSString *param in urlParams) {
        NSArray *keyValue = [param componentsSeparatedByString:@"="];
        NSString *key = [keyValue objectAtIndex:0];
        if ([key isEqualToString:@"code"])
        {
            code = [keyValue objectAtIndex:1]; //retrieving the code
        }
        if (code)
        {
            //Got the code, now retrieving the auth token
            [[UberKit sharedInstance] getAuthTokenForCode:code];
            [self dismissViewControllerAnimated:YES completion:^{
                [[[UIAlertView alloc] initWithTitle:@"授权成功" message:@"您已经成功授权并登录您的优步账号，欢迎使用打车神器。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }];
        }
        else
        {
            NSLog(@"There was an error returning from mobile safari");
        }
    }
}

-(NSString *)resolveSurgeConfirmationIdForRequest:(NSURLRequest *)request
{
    NSString *surge_confirmation_id = nil;
    NSArray *urlParams = [request.URL.query componentsSeparatedByString:@"&"];
    for (NSString *param in urlParams) {
        NSArray *keyValue = [param componentsSeparatedByString:@"="];
        NSString *key = [keyValue objectAtIndex:0];
        if ([key isEqualToString:@"surge_confirmation_id"]) {
            surge_confirmation_id = [keyValue objectAtIndex:1];
        }
    }
    return surge_confirmation_id;
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
    NSLog(@"web view didFailLoadWithError: %@", error);
    [_activityIndicator stopAnimating];
    [_activityIndicator removeFromSuperview];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"request url: %@", request.description);
    if (navigationType == UIWebViewNavigationTypeOther || navigationType == UIWebViewNavigationTypeLinkClicked) { //Surge Confirmation
        
//        if ([request.URL.absoluteString hasSuffix:@"#"]) {
//            NSString *lastPart = [[request.URL.absoluteString pathComponents] lastObject];
//            NSString *idStr = [lastPart substringToIndex:[lastPart length]-1];
//            NSLog(@"idstr: %@", idStr);
//            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/?surge_confirmation_id=%@", bSurgeRedirectUrl, idStr]];
//            
//            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//            NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
//            
//            [[session dataTaskWithURL:url completionHandler:nil] resume];
//            if (idStr != nil) {
//                [self dismissViewControllerAnimated:YES completion:^{
//                    //增加参数surge confirmation id再次发送打车请求
//                    [self.delegate didReceivedSurgeConfirmationId:idStr];
//                }];
//            }
//        }
        
        if ([request.URL.absoluteString hasPrefix:@"https://www.uber.com"]) { //若发现回调URL匹配则解析参数获得id
            NSString *surge_confirmation_id = [self resolveSurgeConfirmationIdForRequest:request];
            NSLog(@"surge confirmation id: %@", surge_confirmation_id);
            if (surge_confirmation_id != nil) {
                [self dismissViewControllerAnimated:YES completion:^{
                    //增加参数surge confirmation id再次发送打车请求
                    [self.delegate didReceivedSurgeConfirmationId:surge_confirmation_id];
                }];
            }
        }
        
    }
    if (navigationType == UIWebViewNavigationTypeFormSubmitted) { //OAuth2.0
        NSLog(@"UIWebViewNavigationTypeFormSubmitted");
        if ([request.URL.absoluteString hasPrefix:@"rocket://redirect/auth"]) {
            //从回调url中解析出code并交换token
            [self resolveAuthRequest:request];
        }
    }
    return YES;
}

@end

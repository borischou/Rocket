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

#define bSurgeRedirectUrl @"https://www.uber.com.cn"
#define bAuthRedirectUrl @"rocket://redirect/auth"
#define ERROR_DESCRIPTION @"NSLocalizedDescription" //打印错误日志的键名

@interface RCWebViewController () <UIWebViewDelegate>

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIView *mask;

@end

@implementation RCWebViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self loadWebView];
    [self loadBarButtons];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self openWebViewWithURL:_url];
}

#pragma mark - Helpers

-(void)loadWebView
{
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, bWidth, bHeight)];
    _webView.delegate = self;
    [self.view addSubview:_webView];
}

-(void)loadBarButtons
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBarButtonPressed:)];
}

#pragma mark - Gesture

-(void)doneBarButtonPressed:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        //用户拒绝加价后续动作
    }];
}

#pragma mark - Helpers

-(void)openWebViewWithURL:(NSString *)url
{
    NSURLRequest *request = nil;
    if (url)
    {
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [_webView loadRequest:request];
    }
    else
    {
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.zuiyoudai.com"]];
        [_webView loadRequest:request];
    }
}

-(void)resolveAuthRequest:(NSURLRequest *)request
{
    NSString *code = nil;
    NSArray *urlParams = [request.URL.query componentsSeparatedByString:@"&"];
    for (NSString *param in urlParams)
    {
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
    for (NSString *param in urlParams)
    {
        NSArray *keyValue = [param componentsSeparatedByString:@"="];
        NSString *key = [keyValue objectAtIndex:0];
        if ([key isEqualToString:@"surge_confirmation_id"])
        {
            surge_confirmation_id = [keyValue objectAtIndex:1];
        }
    }
    return surge_confirmation_id;
}

/*
-(void)injectJavaScript
{
    [_webView stringByEvaluatingJavaScriptFromString:@"var script = document.createElement('script');"
     "script.type = 'text/javascript';"
     "script.src = \"//code.jquery.com/jquery-2.1.4.min.js\";"
     "document.head.appendChild(script);"];
}
*/

/*
-(void)checkHTMLDocument:(NSTimer *)timer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *domHead = [_webView stringByEvaluatingJavaScriptFromString:@"document.head.innerHTML"];
        if (domHead.length > 0)
        {
            [timer invalidate];
            [self injectJavaScript];
            [_mask removeFromSuperview];
            NSLog(@"注入代码后的DOM %@", [_webView stringByEvaluatingJavaScriptFromString:@"document.head.innerHTML"]);
        }
    });
    
}
*/

#pragma mark - UIWebViewDelegate

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
    NSLog(@"web view didFailLoadWithError: %@", error.userInfo[ERROR_DESCRIPTION]);
    [_activityIndicator stopAnimating];
    [_activityIndicator removeFromSuperview];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    /*
    if ([request.URL.absoluteString hasPrefix:@"https://login.uber.com.cn/login"] || [request.URL.absoluteString hasPrefix:@"https://"])
    {
        NSLog(@"URL: %@", request.URL.absoluteString);
        //开子线程定时判断是否取得DOM的head 若取得则插入引用了本地脚本的标签
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkHTMLDocument:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] run];
        });
    }
     */
    
    //Surge confirmation
    if (navigationType == UIWebViewNavigationTypeOther || navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        if ([request.URL.absoluteString hasPrefix:bSurgeRedirectUrl])
        { //若发现回调URL匹配则解析参数获得id
            NSString *surge_confirmation_id = [self resolveSurgeConfirmationIdForRequest:request];
            NSLog(@"surge confirmation id: %@", surge_confirmation_id);
            if (surge_confirmation_id != nil)
            {
                [self dismissViewControllerAnimated:YES completion:^{
                    //增加参数surge confirmation id再次发送打车请求
                    [self.delegate didReceivedSurgeConfirmationId:surge_confirmation_id];
                }];
            }
        }
    }
    
    //用户登录
    if (navigationType == UIWebViewNavigationTypeFormSubmitted)
    { //OAuth2.0
        NSLog(@"登入按钮被按下，URL: %@", request.URL.absoluteString);
        if ([request.URL.absoluteString hasPrefix:bAuthRedirectUrl])
        {
            //从回调url中解析出code并交换token
            [self resolveAuthRequest:request];
        }
    }
    return YES;
}

@end

//
//  HKDetailViewController.m
//  hack
//
//  Created by Zhouboli on 15/7/21.
//  Copyright (c) 2015年 Bankwel. All rights reserved.
//
#import <AMapSearchKit/AMapSearchAPI.h>

#import "RCDetailViewController.h"
#import "UIButton+Bobtn.h"
#import "RCRideViewController.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

static NSString *peopleUberId = @"6bf8dc3b-c8b0-4f37-9b61-579e64016f7a";

@interface RCDetailViewController ()

@property (strong, nonatomic) UILabel *startAddressLabel;
@property (strong, nonatomic) UILabel *destAddressLabel;
@property (strong, nonatomic) UILabel *estimateLabel;
@property (strong, nonatomic) UIButton *confirmButton;

@property (strong, nonatomic) UberRequest *request;

@property (strong, nonatomic) CLLocation *start;
@property (strong, nonatomic) CLLocation *dest;

@end

@implementation RCDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"确认页";
    
    _startAddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, bHeight*1/8, bWidth-100, bHeight/8)];
    _startAddressLabel.textColor = [UIColor blackColor];
    _startAddressLabel.numberOfLines = 0;
    [self.view addSubview:_startAddressLabel];
    
    _destAddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, bHeight*2/8, bWidth-100, bHeight/8)];
    _destAddressLabel.textColor = [UIColor blackColor];
    _destAddressLabel.numberOfLines = 0;
    [self.view addSubview:_destAddressLabel];
    
    _estimateLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, bHeight*3/8, bWidth-100, bHeight/8)];
    _estimateLabel.textColor = [UIColor blackColor];
    _estimateLabel.numberOfLines = 0;
    [self.view addSubview:_estimateLabel];
    
    _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(50, bHeight*10/20, bWidth-100, bHeight/20) andTitle:@"确认打车" withBackgroundColor:[UIColor blueColor] andTintColor:[UIColor whiteColor]];
    [_confirmButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_confirmButton];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"uber token: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"uber_token"]);
    CLLocation *start, *dest;
    
    if (![[_startLocation objectForKey:[_startLocation.allKeys firstObject]] isEqual:[NSNull null]]) {
        if ([[_startLocation objectForKey:[_startLocation.allKeys firstObject]] isKindOfClass:[AMapPOI class]]) {
            AMapPOI *poi = [_startLocation objectForKey:[_startLocation.allKeys firstObject]];
            start = [[CLLocation alloc] initWithLatitude:poi.location.latitude longitude:poi.location.longitude];
            _startAddressLabel.text = [NSString stringWithFormat:@"上车：%@附近 %@\n%f %f", [_startLocation.allKeys firstObject], poi.address, poi.location.latitude, poi.location.longitude];
        }
    } else {
        //object为空 利用name进行POI查询
    }

    if (![[_destLocation objectForKey:[_destLocation.allKeys firstObject]] isEqual:[NSNull null]]) {
        if ([[_destLocation objectForKey:[_destLocation.allKeys firstObject]] isKindOfClass:[AMapPOI class]]) {
            AMapPOI *poi = [_destLocation objectForKey:[_destLocation.allKeys firstObject]];
            dest = [[CLLocation alloc] initWithLatitude:poi.location.latitude longitude:poi.location.longitude];
            _destAddressLabel.text = [NSString stringWithFormat:@"下车：%@附近 %@\n%f %f", [_destLocation.allKeys firstObject], poi.address, poi.location.latitude, poi.location.longitude];
        }
    } else {
        //object为空 利用name进行POI查询
    }
    
    _start = start; _dest = dest;
    NSLog(@"start: %f %f, end: %f %f", start.coordinate.latitude, start.coordinate.longitude, dest.coordinate.latitude, dest.coordinate.longitude);
    _estimateLabel.text = @"计算中";
    [self estimateRequestWithStartLoc:start destLoc:dest productId:peopleUberId];
}

#pragma mark - UBER

-(void)estimateRequestWithStartLoc:(CLLocation *)start destLoc:(CLLocation *)dest productId:(NSString *)productid
{
    [[UberKit sharedInstance] setAuthTokenWith:[[NSUserDefaults standardUserDefaults] objectForKey:@"uber_token"]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[UberKit sharedInstance] getRequestEstimateWithProductId:productid andStartLocation:start endLocation:dest withCompletionHandler:^(UberEstimate *estimateResult, NSURLResponse *response, NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _estimateLabel.text = [NSString stringWithFormat:@"预估信息：优步车型：人民优步，%ld分钟后可接驾；费用：%@%@，倍率：%.1f；行程耗时：%.1f分钟，里程：%.1f公里", estimateResult.pickup_estimate, estimateResult.price.display, estimateResult.price.currency_code, estimateResult.price.surge_multiplier, @(estimateResult.trip.duration_estimate).floatValue/60, estimateResult.trip.distance_estimate*1.609344];
                });
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"出错了" message:[NSString stringWithFormat:@"错误信息: %@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
            
        }];
    });
}

-(void)rideRequestWithProductId:(NSString *)productid startLocation:(CLLocation *)start destLocation:(CLLocation *)dest
{
    [[UberKit sharedInstance] setAuthTokenWith:[[NSUserDefaults standardUserDefaults] objectForKey:@"uber_token"]];

    NSDictionary *parameters = @{@"product_id": productid, @"start_latitude": @(start.coordinate.latitude), @"start_longitude": @(start.coordinate.longitude), @"end_latitude": @(dest.coordinate.latitude), @"end_longitude": @(dest.coordinate.longitude), @"surge_confirmation_id": [NSNull null]};
        
    [[UberKit sharedInstance] getResponseForRequestWithParameters:parameters withCompletionHandler:^(UberRequest *requestResult, UberSurgeErrorResponse *surgeErrorResponse, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                NSLog(@"HTTP: %ld", httpResponse.statusCode);
                if (409 == httpResponse.statusCode) {
                    //处理倍率授权
                    [self openWebViewWithURL:surgeErrorResponse.surge_confirmation.href];
                }
                if (200 <= httpResponse.statusCode && 300 >= httpResponse.statusCode) { //无倍率确认
                    _request = requestResult;
                    RCRideViewController *rideVC = [[RCRideViewController alloc] init];
                    rideVC.view.backgroundColor = [UIColor whiteColor];
                    rideVC.title = @"请求详情";
                    rideVC.request = _request;
                    [self.navigationController pushViewController:rideVC animated:YES];
                }
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"出错了" message:[NSString stringWithFormat:@"错误信息: %@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        });
    }];
}

#pragma mark - UIButtons

-(void)buttonPressed:(UIButton *)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        if ([button.titleLabel.text isEqualToString:@"确认打车"]) {
            [self rideRequestWithProductId:peopleUberId startLocation:_start destLocation:_dest];
        }
    }
}

#pragma mark - Helpers

-(void)openWebViewWithURL:(NSString *)url
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height, bWidth, bHeight)];
    //NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]];
    [self.view addSubview:webView];
    [webView loadRequest:request];
}

@end
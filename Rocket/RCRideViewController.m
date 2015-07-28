//
//  HKRideViewController.m
//  hack
//
//  Created by Zhouboli on 15/7/22.
//  Copyright (c) 2015年 Bankwel. All rights reserved.
//

#import "RCRideViewController.h"
#import "UIButton+Bobtn.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define bBtnColor [UIColor colorWithRed:0.f green:187/255.f blue:156/255.f alpha:1]

@interface RCRideViewController ()

@property (strong, nonatomic) UIImageView *driverAvatarView;
@property (strong, nonatomic) UIImageView *vehicleView;
@property (strong, nonatomic) UILabel *driverInfoLabel;
@property (strong, nonatomic) UILabel *vehicleInfoLabel;
@property (strong, nonatomic) UILabel *locationInfoLabel;

@property (strong, nonatomic) UIButton *statusButton;
@property (strong, nonatomic) UIButton *cancelButton;

@end

@implementation RCRideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    _driverAvatarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bWidth/5, bWidth/5)];
    _driverAvatarView.center = CGPointMake(bWidth/2, bHeight*2/10);
    _driverAvatarView.backgroundColor = bBtnColor;
    [self.view addSubview:_driverAvatarView];
    
    _driverInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, bHeight*2/10/2+bWidth/5+5, bWidth-100, bWidth/4)];
    _driverInfoLabel.textColor = [UIColor blackColor];
    _driverInfoLabel.text = @"司机信息..";
    _driverInfoLabel.numberOfLines = 0;
    [self.view addSubview:_driverInfoLabel];
    
    _vehicleView = [[UIImageView alloc] initWithFrame:CGRectMake(50, bHeight*2/10+bWidth/5+5+bWidth/4+5, bWidth/5, bWidth/5)];
    _vehicleView.backgroundColor = bBtnColor;
    [self.view addSubview:_vehicleView];
    
    _vehicleInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(50+bWidth/5+5, bHeight*2/10+bWidth/5+5+bWidth/4+5, bWidth-100, bWidth/3)];
    _vehicleInfoLabel.textColor = [UIColor blackColor];
    _vehicleInfoLabel.text = @"车辆信息..";
    _vehicleInfoLabel.numberOfLines = 0;
    [self.view addSubview:_vehicleInfoLabel];
    
    _locationInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, bHeight*2/10+bWidth/5+5+bWidth/4+5+bWidth/3+5, bWidth-100, bWidth/3)];
    _locationInfoLabel.textColor = [UIColor blackColor];
    _locationInfoLabel.text = @"位置信息..";
    _locationInfoLabel.numberOfLines = 0;
    [self.view addSubview:_locationInfoLabel];
    
    _statusButton = [[UIButton alloc] initWithFrame:CGRectMake(50, bHeight*2/10+bWidth/5+5+bWidth/4+5+bWidth/3+5+bWidth/3+5, bWidth-100, bHeight/20) andTitle:@"查询状态" withBackgroundColor:bBtnColor andTintColor:[UIColor whiteColor]];
    [_statusButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_statusButton];
    
    _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(50, bHeight*2/10+bWidth/5+5+bWidth/4+5+bWidth/3+5+bWidth/3+5+bHeight/20+5, bWidth-100, bHeight/20) andTitle:@"取消请求" withBackgroundColor:[UIColor redColor] andTintColor:[UIColor whiteColor]];
    [_cancelButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cancelButton];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshStatusWithRequest:_request];
}

#pragma mark - UIButtons

-(void)buttonPressed:(UIButton *)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        if ([button.titleLabel.text isEqualToString:@"查询状态"]) {
            [self requestStatusWithRequestId:_request.request_id];
        }
        if ([button.titleLabel.text isEqualToString:@"取消请求"]) {
            [self cancelRequestWithId:_request.request_id];
        }
    }
}

#pragma mark - Helpers

-(void)refreshStatusWithRequest:(UberRequest *)request
{
    NSString *driverAvatarUrl = request.driver.picture_url;
    if (driverAvatarUrl) {
        [_driverAvatarView sd_setImageWithURL:[NSURL URLWithString:driverAvatarUrl] placeholderImage:[UIImage imageNamed:@"hk_driver_avatar"]];
    }
    NSString *vehicleImageUrl = request.vehicle.picture_url;
    if (vehicleImageUrl) {
        [_vehicleView sd_setImageWithURL:[NSURL URLWithString:vehicleImageUrl] placeholderImage:[UIImage imageNamed:@"hk_vehicle_avatar"]];
    }
    if ([request.status isEqualToString:@"accepted"]) {
        _driverInfoLabel.text = [NSString stringWithFormat:@"司机信息：\n请求状态：%@，名称：%@，电话：%@，评分：%.1f，%ld后可接驾", request.status, request.driver.name, request.driver.phone_number, request.driver.rating, request.eta];
        _vehicleInfoLabel.text = [NSString stringWithFormat:@"车辆信息：\n品牌：%@，型号：%@，车牌号：%@", request.vehicle.make, request.vehicle.model, request.vehicle.license_plate];
    }
    if ([request.status isEqualToString:@"processing"]) {
        _driverInfoLabel.text = [NSString stringWithFormat:@"司机信息：\n请求状态：%@", request.status];
    }
}

#pragma mark - Uber Requests

-(void)cancelRequestWithId:(NSString *)requestid
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[UberKit sharedInstance] cancelRequestForId:_request.request_id withCompletionHandler:^(NSURLResponse *response, NSError *error) {
            if (!error) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"Cancel" message:[NSString stringWithFormat:@"Response: %ld\n(204为取消成功)", httpResponse.statusCode] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                });
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"出错了" message:[NSString stringWithFormat:@"错误信息: %@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }];
    });
}

-(void)requestStatusWithRequestId:(NSString *)requestid
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[UberKit sharedInstance] getDetailsForRequestId:requestid withCompletionHandler:^(UberRequest *requestResult, UberSurgeErrorResponse *surgeErrorResponse, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _request = requestResult;
                [self refreshStatusWithRequest:requestResult];
                [[[UIAlertView alloc] initWithTitle:@"Uber Response" message:[NSString stringWithFormat:@"UberResponse:\nrequest_id: %@\nstatus: %@\neta: %ld\nsurge_multiplier: %f\nvehicle:\nmake: %@\nmodel: %@\nlicense_plate: %@\ndriver:\nphone_number: %@\nname: %@\nrating: %f\nlocation:\nlat: %f lon: %f bearing: %ld\nresponse: %@\nerror: %@", requestResult.request_id, requestResult.status, requestResult.eta, requestResult.surge_multiplier, requestResult.vehicle.make, requestResult.vehicle.model, requestResult.vehicle.license_plate, requestResult.driver.phone_number, requestResult.driver.name, requestResult.driver.rating, requestResult.location.latitude, requestResult.location.longitude, requestResult.location.bearing, response, error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            });
        }];
    });
    
//    NSLog(@"request_id: %@", requestid);
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [[UberKit sharedInstance] setAuthTokenWith:[[NSUserDefaults standardUserDefaults] objectForKey:@"uber_token"]];
//        NSDictionary *params = @{@"status": @"processing"};
//        [[UberKit sharedInstance] getStatusForRequestWithParameters:params requestId:requestid withCompletionHandler:^(UberRequest *requestResult, UberSurgeErrorResponse *surgeErrorResponse, NSURLResponse *response, NSError *error) {
//            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//            NSLog(@"Http code: %ld", httpResponse.statusCode);
//        }];
//    });
}

@end

//
//  RCMainViewController.m
//  Rocket
//
//  Created by Zhouboli on 15/7/23.
//  Copyright (c) 2015年 Bankwel. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import <MBProgressHUD.h>
#import "UberKit.h"
#import "SWRevealViewController.h"
#import "UIButton+Bobtn.h"

#import "RCMainViewController.h"
#import "RCBottomMenuView.h"
#import "RCCenterPinView.h"
#import "RCCarTypeCollectionView.h"
#import "RCCarTypeCollectionViewCell.h"
#import "RCPaopaoView.h"
#import "RCFocusView.h"
#import "RCAddressTVC.h"
#import "RCDetailViewController.h"
#import "RCRideViewController.h"
#import "RCWebViewController.h"
#import "RCConfirmTableView.h"
#import "RCConfirmTableViewCell.h"
#import "RCWebViewController.h"

#define uClientId @"ymecnlUOQL0oGz5n01-Y062Fee568Vsq"
#define uServerToken @"yWKJiJmVB1ytIwm1FO3dXBIP2pRZxNsNffvL64OE"
#define uSecret @"FbIVnFs9Pqsxu4Y-MUrkS6-eAFX30DrNhVC8Bo0A"
#define uAppName @"Rocket4BorisAgain"

#define uAuthUrl @"https://login.uber.com/oauth/authorize"
#define uAccessTokenUrl @"https://login.uber.com/oauth/token"
#define uRedirectUrl @"rocket://redirect/auth"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

#define bMenuHeight bHeight/5
#define bScaleBarHeight 30
#define bFocusBtnHeight 40
#define bPaopaoViewHeight 40

static NSString *gaodeMapAPIKey = @"9f692108300515ec3819e362d6389159";
static NSString *peopleUberId = @"6bf8dc3b-c8b0-4f37-9b61-579e64016f7a";

@interface RCMainViewController () <RCAddressTVDelegate, RCWebViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, UberKitDelegate, MAMapViewDelegate, AMapSearchDelegate>
//Cocoa
@property (copy, nonatomic) NSString *uberWaitingMins;
@property (copy, nonatomic) NSString *curAddress;
@property (copy, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSArray *centerPois;
@property (strong, nonatomic) UIAlertView *alertView;
@property (strong, nonatomic) UIView *maskView;
@property (nonatomic) CLLocationCoordinate2D currentCoords;
@property (strong, nonatomic) NSMutableDictionary *startDict;
@property (strong, nonatomic) NSMutableDictionary *destDict;
//Custom
@property (strong, nonatomic) RCPaopaoView *paopaoView;
@property (strong, nonatomic) RCFocusView *focusView;
@property (strong, nonatomic) RCBottomMenuView *menuView;
@property (strong, nonatomic) RCCenterPinView *centerPinView;
@property (strong, nonatomic) RCCarTypeCollectionView *carTypeCollectionView;
@property (strong, nonatomic) RCConfirmTableView *confirmTableView;
//GaoDe
@property (strong, nonatomic) MAMapView *mapView;
@property (strong, nonatomic) MAPinAnnotationView *curPinView;
@property (strong, nonatomic) AMapSearchAPI *search;
@property (strong, nonatomic) AMapPOI *centerPOI;
//Uber
@property (strong, nonatomic) UberProfile *profile;
@property (strong, nonatomic) UberEstimate *estimate;
@property (strong, nonatomic) UberRequest *request;

@property (nonatomic) BOOL isInitLoad;
@property (nonatomic) BOOL isCentered;

@end

@implementation RCMainViewController

#pragma mark - View Controller Life Cycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self loadUberParameters];
    [self loadMenuView];
    [self detectAvailableBrandAcount];
    [self loadBarbuttonItems];
    [self loadGaodeMapView];
    [self loadCollectionView];
    [self detectSavedRequestStatus];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self detectAvailableBrandAcount];
}

#pragma mark - Load View

-(void)detectAvailableBrandAcount
{
    if ([self isUberTokenAvailable]) {
        _menuView.requestBtn.enabled = YES;
    } else {
        _menuView.requestBtn.enabled = NO;
    }
}

-(void)loadUberParameters
{
    UberKit *uberKit = [UberKit sharedInstance];

    [uberKit setClientID:uClientId];
    [uberKit setClientSecret:uSecret];
    [uberKit setRedirectURL:uRedirectUrl];
    [uberKit setApplicationName:uAppName];
    [uberKit setServerToken:uServerToken];
    
    uberKit.delegate = self;
    [uberKit setupOAuth2AccountStore];
}

-(void)loadMenuView
{
    _isInitLoad = YES;
    _menuView = [[RCBottomMenuView alloc] init];
    _menuView.userInteractionEnabled = YES;
    [self.view addSubview:_menuView];
    
    [_menuView.destLbl addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuViewDestinationLabelTapped:)]];
    [_menuView.requestBtn addTarget:self action:@selector(requestButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)loadFloatViews
{
    _centerPinView = [[RCCenterPinView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    _centerPinView.center = CGPointMake(_mapView.center.x, _mapView.center.y-20);
    [self.view addSubview:_centerPinView];
    
    _paopaoView = [[RCPaopaoView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    _paopaoView.center = CGPointMake(_centerPinView.center.x, _centerPinView.center.y - 30);
    _paopaoView.addrLbl.text = _curAddress;
    [_paopaoView.addrLbl addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(paopaoViewPickupLabelTapped:)]];
    [self.view addSubview:_paopaoView];
    
    _focusView = [[RCFocusView alloc] initWithFrame:CGRectMake(10, bHeight - bMenuHeight - bScaleBarHeight - 10 - bFocusBtnHeight, 40, bFocusBtnHeight)];
    [_focusView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusViewTapped:)]];
    [self.view addSubview:_focusView];
}

-(void)loadBarbuttonItems
{
    SWRevealViewController *revealController = [self revealViewController];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 23, 23);
    [button setImage:[UIImage imageNamed:@"hk_profile_4"] forState:UIControlStateNormal];
    [button addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *profileBarbutton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    UIImageView *settingsView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 23, 23)];
    [settingsView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(settingsBarbuttonPressed)]];
    settingsView.userInteractionEnabled = YES;
    settingsView.image = [UIImage imageNamed:@"hk_settings"];
    UIBarButtonItem *settingsBarbutton = [[UIBarButtonItem alloc] initWithCustomView:settingsView];
    
    self.navigationItem.rightBarButtonItem = settingsBarbutton;
    self.navigationItem.leftBarButtonItem = profileBarbutton;
}

-(void)loadCollectionView
{
    _carTypeCollectionView = [[RCCarTypeCollectionView alloc] initWithFrame:CGRectMake(0, bHeight - bMenuHeight, bWidth, bMenuHeight/2) collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    [_carTypeCollectionView registerClass:[RCCarTypeCollectionViewCell class] forCellWithReuseIdentifier:@"reuseCell"];
    _carTypeCollectionView.dataSource = self;
    _carTypeCollectionView.delegate = self;
    [self.view addSubview:_carTypeCollectionView];
}

-(void)loadGaodeMapView
{
    [MAMapServices sharedServices].apiKey = gaodeMapAPIKey;
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, bWidth, bHeight-bMenuHeight)];
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
    _mapView.showsScale = YES;
    _mapView.scaleOrigin = CGPointMake(5, bHeight-bMenuHeight-40);
    _isCentered = NO;
    [self.view addSubview:_mapView];
    
    _search = [[AMapSearchAPI alloc] initWithSearchKey:gaodeMapAPIKey Delegate:self];
}

#pragma mark - Uber

-(void)loginUber
{
    [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:uAppName withPreparedAuthorizationURLHandler:^(NSURL *preparedURL)
    {
        //open it in a webview
        RCWebViewController *webViewController = [[RCWebViewController alloc] init];
        webViewController.url = [NSString stringWithFormat:@"%@", preparedURL];
        [self.navigationController presentViewController:webViewController animated:YES completion:^{}];
    }];
}

-(void)uberRequestProfile
{
    [[UberKit sharedInstance] setAuthTokenWith:[[NSUserDefaults standardUserDefaults] objectForKey:@"uber_token"]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[UberKit sharedInstance] getUserProfileWithCompletionHandler:^(UberProfile *profile, NSURLResponse *response, NSError *error) {
            if (!error) {
                self.profile = profile;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"My Profile" message:[NSString stringWithFormat:@"response: %@\nProfile object: %@\nFirst name: %@\nLast name: %@\nEmail: %@\nPicture URL: %@\nPromotion code: %@\nUUID: %@", response, profile, profile.first_name, profile.last_name, profile.email, profile.picture, profile.promo_code, profile.uuid] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                });
            } else NSLog(@"error: %@", error);
        }];
    });
}

-(void)calculateUberEstimatePickupTime:(CLLocationCoordinate2D)gd_coords
{
    _uberWaitingMins = @"计算中..";
    [_carTypeCollectionView reloadData];
    
    CLLocation *pickupLocation = [[CLLocation alloc] initWithLatitude:gd_coords.latitude longitude:gd_coords.longitude];
    
    if ([self isUberTokenAvailable]) {
        [self estimateRequestWithStartLoc:[[CLLocation alloc] initWithLatitude:gd_coords.latitude longitude:gd_coords.longitude] destLoc:nil productId:peopleUberId];
    } else {
        [[UberKit sharedInstance] getTimeForProductArrivalWithLocation:pickupLocation withCompletionHandler:^(NSArray *times, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSLog(@"TIME RESPONSE: %ld", httpResponse.statusCode);
            if(!error)
            {
                if ([times count]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        for (UberTime *time in times) {
                            if ([time.productID isEqualToString:peopleUberId]) {
                                _uberWaitingMins = [NSString stringWithFormat:@"%.1f分后可接驾", time.estimate/60];
                            }
                        }
                        [_carTypeCollectionView reloadData];
                    });
                }
            }
            else
            {
                NSLog(@"Error %@", error);
                [[[UIAlertView alloc] initWithTitle:@"错误" message:[NSString stringWithFormat:@"错误信息：\n%@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }];
    }
}

-(void)estimateRequestWithStartLoc:(CLLocation *)start destLoc:(CLLocation *)dest productId:(NSString *)productid
{
    [[UberKit sharedInstance] setAuthTokenWith:[[NSUserDefaults standardUserDefaults] objectForKey:@"uber_token"]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[UberKit sharedInstance] getRequestEstimateWithProductId:productid andStartLocation:start endLocation:dest withCompletionHandler:^(UberEstimate *estimateResult, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSLog(@"RESPONSE: %ld", httpResponse.statusCode);
            if (!error) {
                _estimate = estimateResult;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (estimateResult.pickup_estimate == 0) {
                        _uberWaitingMins = @"暂无可接驾车辆";
                        _menuView.requestBtn.enabled = YES;
                    } else {
                        _menuView.requestBtn.enabled = YES;
                        _uberWaitingMins = [NSString stringWithFormat:@"%ld分钟后可接驾", estimateResult.pickup_estimate];
                    }
                    [_carTypeCollectionView reloadData];
                    [_confirmTableView reloadData];
                });
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"出错了" message:[NSString stringWithFormat:@"错误信息: %@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
            
        }];
    });
}

-(void)rideRequestWithProductId:(NSString *)productid startLocation:(CLLocation *)start destLocation:(CLLocation *)dest surgeConfirmationId:(id)surge_confirmation_id
{
    _request = nil; //先清空上一次请求信息
    [[UberKit sharedInstance] setAuthTokenWith:[[NSUserDefaults standardUserDefaults] objectForKey:@"uber_token"]];
    
    NSDictionary *parameters = @{@"product_id": productid, @"start_latitude": @(start.coordinate.latitude), @"start_longitude": @(start.coordinate.longitude), @"end_latitude": @(dest.coordinate.latitude), @"end_longitude": @(dest.coordinate.longitude), @"surge_confirmation_id": surge_confirmation_id};
    
    [[UberKit sharedInstance] getResponseForRequestWithParameters:parameters withCompletionHandler:^(UberRequest *requestResult, UberSurgeErrorResponse *surgeErrorResponse, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (!error) {
                [[NSUserDefaults standardUserDefaults] setObject:requestResult.request_id forKey:@"saved_request_id"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                NSLog(@"HTTP status code: %ld", httpResponse.statusCode);
                if (409 == httpResponse.statusCode) { //处理倍率授权
                    //打开WebView查看授权web页面
                    RCWebViewController *webVC = [[RCWebViewController alloc] init];
                    webVC.delegate = self;
                    webVC.url = surgeErrorResponse.surge_confirmation.href;
                    [self.navigationController presentViewController:webVC animated:YES completion:^{
                    }];
                }
                if (200 <= httpResponse.statusCode && 300 >= httpResponse.statusCode) { //无倍率确认
                    if (!_request) {
                        _request = requestResult;
                        RCRideViewController *rideVC = [[RCRideViewController alloc] init];
                        rideVC.view.backgroundColor = [UIColor whiteColor];
                        rideVC.title = @"请求详情";
                        rideVC.request = _request;
                        [self.navigationController pushViewController:rideVC animated:YES];
                    }
                }
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"出错了" message:[NSString stringWithFormat:@"错误信息: %@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        });
    }];
}

#pragma mark - UberKitDelegate

-(void)uberKit:(UberKit *)uberKit didReceiveAccessToken:(NSString *)accessToken
{
    NSLog(@"Received access token: %@", accessToken);
    _accessToken = accessToken;
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"uber_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)uberKit:(UberKit *)uberKit loginFailedWithError:(NSError *)error
{
    NSLog(@"Failed with error: %@", error);
    [[[UIAlertView alloc] initWithTitle:@"错误" message:[NSString stringWithFormat:@"错误信息：\n%@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView isEqual:_alertView]) {
        if (1 == buttonIndex) {
            //login uber
            [self loginUber];
        }
    }
}

#pragma mark - AMapSearchDelegate & Helpers

-(void)startReGeoSearchWithCoordinate:(CLLocationCoordinate2D)coords
{
    AMapReGeocodeSearchRequest *reGeoRequest = [[AMapReGeocodeSearchRequest alloc] init];
    reGeoRequest.searchType = AMapSearchType_ReGeocode;
    reGeoRequest.location = [AMapGeoPoint locationWithLatitude:coords.latitude longitude:coords.longitude];
    reGeoRequest.requireExtension = YES;
    [_search AMapReGoecodeSearch:reGeoRequest];
}

-(void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode != nil) {
        AMapPOI *poi = [response.regeocode.pois firstObject];
        _centerPOI = poi;
        _centerPois = response.regeocode.pois;
        NSLog(@"poi: %@ location: %f %f", poi.name, poi.location.latitude, poi.location.longitude);
        if (poi.name) {
            _paopaoView.addrLbl.text = [NSString stringWithFormat:@"从%@上车", poi.name];
        } else {
            _paopaoView.addrLbl.text = @"坐标未知区域";
        }
        [_paopaoView.addrLbl sizeToFit];
        
        _startDict = nil;
        if (!_startDict) {
            _startDict = [[NSMutableDictionary alloc] init];
        }
        if (poi) {
            [_startDict setObject:poi forKey:poi.name];
        }
        
        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:10.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _paopaoView.frame = CGRectMake(0, 0, _paopaoView.addrLbl.frame.size.width + 10, _paopaoView.addrLbl.frame.size.height + 10);
            _paopaoView.center = CGPointMake(_centerPinView.center.x, _centerPinView.center.y - 37);
        } completion:^(BOOL finished) {
        }];
        
        [self calculateUberEstimatePickupTime:CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude)];
    }
}

-(AMapPOI *)getPoiWithDictionary:(NSDictionary *)dict
{
    AMapPOI *poi;
    if (![[dict objectForKey:[dict.allKeys firstObject]] isEqual:[NSNull null]]) {
        if ([[dict objectForKey:[dict.allKeys firstObject]] isKindOfClass:[AMapPOI class]]) {
            poi = [dict objectForKey:[dict.allKeys firstObject]];
        }
    } else {
        //object为空 利用name进行POI查询
    }
    return poi;
}

#pragma mark - UIButtons

-(void)confirmButtonPressed:(UIButton *)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    AMapPOI *start = [self getPoiWithDictionary:_startDict];
    AMapPOI *dest = [self getPoiWithDictionary:_destDict];
    [self rideRequestWithProductId:peopleUberId startLocation:[[CLLocation alloc] initWithLatitude:start.location.latitude longitude:start.location.longitude] destLocation:[[CLLocation alloc] initWithLatitude:dest.location.latitude longitude:dest.location.longitude] surgeConfirmationId:[NSNull null]];
}

-(void)cancelButtonPressed:(UIButton *)sender
{
    [[[sender superview] superview] removeFromSuperview];
    [_maskView removeFromSuperview];
}

-(void)requestButtonPressed:(UIButton *)sender
{
    if (_startDict && _destDict) {
        
        [self initConfirmTableViewSettings];
        
        AMapPOI *start = [self getPoiWithDictionary:_startDict];
        AMapPOI *dest = [self getPoiWithDictionary:_destDict];
        [self estimateRequestWithStartLoc:[[CLLocation alloc] initWithLatitude:start.location.latitude longitude:start.location.longitude] destLoc:[[CLLocation alloc] initWithLatitude:dest.location.latitude longitude:dest.location.longitude] productId:peopleUberId];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"信息不完整" message:@"请确认上车地点和目的地。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

-(void)settingsBarbuttonPressed
{
    
}

#pragma mark - Tap Actions

-(void)menuViewDestinationLabelTapped:(UITapGestureRecognizer *)tap
{
    RCAddressTVC *addressTVC = [[RCAddressTVC alloc] init];
    addressTVC.delegate = self;
    addressTVC.isForPickup = NO;
    addressTVC.pois = _centerPois;
    [self.navigationController pushViewController:addressTVC animated:YES];
}

-(void)paopaoViewPickupLabelTapped:(UITapGestureRecognizer *)tap
{
    RCAddressTVC *addressTVC = [[RCAddressTVC alloc] init];
    addressTVC.delegate = self;
    addressTVC.isForPickup = YES;
    addressTVC.pois = _centerPois;
    [self.navigationController pushViewController:addressTVC animated:YES];
}

-(void)focusViewTapped:(UITapGestureRecognizer *)tap
{
    [_mapView setCenterCoordinate:_currentCoords animated:YES];
}

#pragma mark - Helpers

-(NSAttributedString *)attributedStringForBrandLabel:(NSString *)string
{
    NSAttributedString *aString = [[NSAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13.f]}];
    return aString;
}

-(BOOL)isUberTokenAvailable
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"uber_token"]) {
        return NO;
    } else {
        return YES;
    }
}

-(void)detectSavedRequestStatus
{
    NSString *request_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"saved_request_id"];
    if (request_id) {
        //获取UberRequest实例并跳转RideView
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"uber_token"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[UberKit sharedInstance] setAuthTokenWith:token];
            [[UberKit sharedInstance] getDetailsForRequestId:request_id withCompletionHandler:^(UberRequest *requestResult, UberSurgeErrorResponse *surgeErrorResponse, NSURLResponse *response, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    RCRideViewController *rideVC = [[RCRideViewController alloc] init];
                    rideVC.view.backgroundColor = [UIColor whiteColor];
                    rideVC.request = requestResult;
                    [self.navigationController pushViewController:rideVC animated:YES];
                });
            }];
        });
    }
}

#pragma mark - MAMapViewDelegate

-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (updatingLocation) {
        _currentCoords = userLocation.location.coordinate;
        if (!_isCentered) { //如果刚初始化，则放大地图至以用户定位为中心的区域
            [_mapView setZoomLevel:17.1 animated:YES]; //17.1为适配Retina屏的缩放指数之一
            [_mapView setCenterCoordinate:_currentCoords animated:YES];
            _isCentered = YES;
        }
    }
}

-(void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:@"出错了" message:[NSString stringWithFormat:@"错误信息: %@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

-(void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (_isInitLoad) {
        [self loadFloatViews];
        _isInitLoad = NO;
    }
    [self startReGeoSearchWithCoordinate:_mapView.centerCoordinate];
}

#pragma mark - RCAddressTVCDelegate

-(void)selectedPoiObject:(id)poiObj forPickup:(BOOL)isForPickup
{
    if ([poiObj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *poiDict = (NSDictionary *)poiObj;
        if (isForPickup) {
            _startDict = poiDict.mutableCopy;
            if (![[poiDict objectForKey:[poiDict.allKeys firstObject]] isEqual:[NSNull null]]) {
                if ([[poiDict objectForKey:[poiDict.allKeys firstObject]] isKindOfClass:[AMapPOI class]]) {
                    AMapPOI *poi = [poiDict objectForKey:[poiDict.allKeys firstObject]];
                    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude)];
                }
            }
        }
        else
        {
            _destDict = poiDict.mutableCopy;
            _menuView.destLbl.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"您的目的地:%@", [poiDict.allKeys firstObject]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13.f]}];
        }
    }
}

#pragma mark - RCWebViewControllerDelegate

-(void)didReceivedSurgeConfirmationId:(NSString *)idstr
{
    if (idstr) {
        AMapPOI *start = [self getPoiWithDictionary:_startDict];
        AMapPOI *dest = [self getPoiWithDictionary:_destDict];
        [self rideRequestWithProductId:peopleUberId startLocation:[[CLLocation alloc] initWithLatitude:start.location.latitude longitude:start.location.longitude] destLocation:[[CLLocation alloc] initWithLatitude:dest.location.latitude longitude:dest.location.longitude] surgeConfirmationId:idstr];
    }
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 5;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RCCarTypeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"reuseCell" forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0: //Uber
            cell.brandTextLabel.attributedText = [self attributedStringForBrandLabel:@"优步"];
            cell.brandIconView.image = [UIImage imageNamed:@"hk_uber_icon"];
            if (_uberWaitingMins) {
                cell.waitingTimeLabel.attributedText = [[NSAttributedString alloc] initWithString:_uberWaitingMins attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10.f]}];
            } else {
                cell.waitingTimeLabel.text = @"";
            }
            break;
        case 1: //滴滴打车
            cell.brandTextLabel.attributedText = [self attributedStringForBrandLabel:@"滴滴打车"];
            cell.brandIconView.image = [UIImage imageNamed:@"hk_didi_icon"];
            cell.waitingTimeLabel.text = @"";
            break;
        case 2:
            cell.brandTextLabel.attributedText = [self attributedStringForBrandLabel:@"快的打车"];
            cell.brandIconView.image = [UIImage imageNamed:@"hk_kuaidi_icon"];
            cell.waitingTimeLabel.text = @"";
            break;
        case 3:
            cell.brandTextLabel.attributedText = [self attributedStringForBrandLabel:@"神州专车"];
            cell.brandIconView.image = [UIImage imageNamed:@"hk_shenzhou_icon"];
            cell.waitingTimeLabel.text = @"";
            break;
        case 4:
            cell.brandTextLabel.attributedText = [self attributedStringForBrandLabel:@"51用车"];
            cell.brandIconView.image = [UIImage imageNamed:@"hk_51_icon"];
            cell.waitingTimeLabel.text = @"";
            break;
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_isCentered) {
        cell.contentView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:2.0];
        cell.contentView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        [UIView commitAnimations];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{    
    if (0 == indexPath.row) { //UBER
        if (![self isUberTokenAvailable]) {
            _alertView = [[UIAlertView alloc] initWithTitle:@"授权登录" message:@"您尚未授权优步账号，请先登录授权后使用。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"登录优步", nil];
            [_alertView show];
        } else {
            //可跳转Uber 设置优步绿色标志位
            [[[UIAlertView alloc] initWithTitle:@"已授权" message:@"您已授权打车神器使用您的优步账号，请点击叫车按键进行叫车（暂时仅开放人民优步车型）。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
}

#pragma mark - UITableViewDelegate & DataSource & Helpers

-(void)initConfirmTableViewSettings
{
    _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bWidth, bHeight)];
    _maskView.backgroundColor = [UIColor blackColor];
    _maskView.alpha = 0.5;
    [self.view addSubview:_maskView];
    
    _confirmTableView = [[RCConfirmTableView alloc] initWithFrame:CGRectMake(0, 0, bWidth*3/4, (bHeight-bMenuHeight)*3/4) style:UITableViewStyleGrouped];
    _confirmTableView.center = _mapView.center;
    _confirmTableView.alpha = 0.0;
    _confirmTableView.delegate = self;
    _confirmTableView.dataSource = self;
    _confirmTableView.layer.cornerRadius = 3;
    [self.view addSubview:_confirmTableView];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _confirmTableView.alpha = 1.0;
    } completion:nil];
    
    _confirmTableView.tableHeaderView = [self setTableHeaderView];
    _confirmTableView.tableFooterView = [self setTableFooterView];
    
}

-(UIView *)setTableHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _confirmTableView.frame.size.width, _confirmTableView.frame.size.height/5)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UILabel *start = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, headerView.frame.size.width-10, (headerView.frame.size.height-15)/2)];
    start.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:start];
    
    UILabel *dest = [[UILabel alloc] initWithFrame:CGRectMake(5, 10+(headerView.frame.size.height-15)/2, headerView.frame.size.width-10, (headerView.frame.size.height-15)/2)];
    dest.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:dest];
    
    start.textColor = [UIColor darkGrayColor];
    dest.textColor = [UIColor darkGrayColor];
    
    AMapPOI *startPoi = [self getPoiWithDictionary:_startDict];
    AMapPOI *destPoi = [self getPoiWithDictionary:_destDict];
    start.attributedText = [self attributedStringForBrandLabel:[NSString stringWithFormat:@"上车：%@ %@附近", startPoi.name, startPoi.address]];
    dest.attributedText = [self attributedStringForBrandLabel:[NSString stringWithFormat:@"下车：%@ %@附近", destPoi.name, destPoi.address]];
    
    return headerView;
}

-(UIView *)setTableFooterView
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _confirmTableView.frame.size.width, _confirmTableView.frame.size.height/9)];
    
    UIButton *confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, (footerView.frame.size.width-15)*3/4, footerView.frame.size.height-10) andTitle:@"确认叫车" withBackgroundColor:[UIColor purpleColor] andTintColor:[UIColor whiteColor]];
    [confirmButton addTarget:self action:@selector(confirmButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:confirmButton];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10+(footerView.frame.size.width-15)*3/4, 5, (footerView.frame.size.width-15)*1/4, footerView.frame.size.height-10) andTitle:@"取消" withBackgroundColor:[UIColor greenColor] andTintColor:[UIColor whiteColor]];
    [cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:cancelButton];
    
    return footerView;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView registerClass:[RCConfirmTableViewCell class] forCellReuseIdentifier:@"reuse"];
    RCConfirmTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuse" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.carImageView.image = [UIImage imageNamed:@"rc_car_icon"];
    if (_estimate.price.display) {
        cell.priceLabel.attributedText = [self attributedStringForBrandLabel:_estimate.price.display];
    }
    if (_estimate.trip) {
        cell.distanceLabel.attributedText = [self attributedStringForBrandLabel:[NSString stringWithFormat:@"里程：%.1f公里", _estimate.trip.distance_estimate*1.609]];
        cell.timeLabel.attributedText = [self attributedStringForBrandLabel:[NSString stringWithFormat:@"时长：%ld分钟", _estimate.trip.duration_estimate/60]];
    }
    if (_estimate.pickup_estimate) {
        cell.etaLabel.attributedText = [self attributedStringForBrandLabel:[NSString stringWithFormat:@"%ld分钟后可接驾", _estimate.pickup_estimate]];
    }
    if (_estimate.price.surge_multiplier) {
        cell.formulaLabel.attributedText = [self attributedStringForBrandLabel:[NSString stringWithFormat:@"加价：%.1f", _estimate.price.surge_multiplier]];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"优步";
    }
    return nil;
}

@end

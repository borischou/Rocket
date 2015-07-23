//
//  RCMainViewController.m
//  Rocket
//
//  Created by Zhouboli on 15/7/23.
//  Copyright (c) 2015年 Bankwel. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "UberKit.h"

#import "RCMainViewController.h"
#import "RCBottomMenuView.h"
#import "RCCenterPinView.h"
#import "RCCarTypeCollectionView.h"
#import "RCCarTypeCollectionViewCell.h"
#import "RCPaopaoView.h"
#import "RCFocusView.h"
#import "RCAddressTVC.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

#define bMenuHeight bHeight/5
#define bScaleBarHeight 30
#define bFocusBtnHeight 40
#define bPaopaoViewHeight 40

static NSString *gaodeMapAPIKey = @"9f692108300515ec3819e362d6389159";

@interface RCMainViewController () <RCAddressTVDelegate, UICollectionViewDataSource, UICollectionViewDelegate, MAMapViewDelegate, AMapSearchDelegate>

@property (copy, nonatomic) NSString *uberWaitingMins;
@property (copy, nonatomic) NSString *curAddress;
@property (copy, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSArray *centerPois;
@property (strong, nonatomic) UIAlertView *alertView;
@property (strong, nonatomic) NSMutableDictionary *startLocation;
@property (strong, nonatomic) NSMutableDictionary *destLocation;
@property (nonatomic) CLLocationCoordinate2D currentCoords;

@property (strong, nonatomic) RCPaopaoView *paopaoView;
@property (strong, nonatomic) RCFocusView *focusView;
@property (strong, nonatomic) RCBottomMenuView *menuView;
@property (strong, nonatomic) RCCenterPinView *centerPinView;
@property (strong, nonatomic) RCCarTypeCollectionView *carTypeCollectionView;

@property (strong, nonatomic) MAMapView *mapView;
@property (strong, nonatomic) MAPinAnnotationView *curPinView;
@property (strong, nonatomic) AMapSearchAPI *search;
@property (strong, nonatomic) AMapPOI *centerPOI;

@property (strong, nonatomic) UberTime *estimateTime;
@property (strong, nonatomic) UberProfile *profile;

@property (nonatomic) BOOL isInitLoad;
@property (nonatomic) BOOL isCentered;

@end

@implementation RCMainViewController

#pragma mark - View Controller Life Cycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self loadMenuView];
    [self loadBarbuttonItems];
    [self loadGaodeMapView];
    [self loadCollectionView];
}

#pragma mark - Load View

-(void)loadMenuView
{
    _isInitLoad = YES;
    _menuView = [[RCBottomMenuView alloc] init];
    _menuView.userInteractionEnabled = YES;
    [self.view addSubview:_menuView];
    
    [_menuView.destLbl addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuViewDestinationLabelTapped:)]];
    [_menuView.requestBtn addTarget:self action:@selector(requestButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_menuView.compareBtn addTarget:self action:@selector(compareButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
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
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 23, 23)];
    [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileBarButtonPressed)]];
    imageView.userInteractionEnabled = YES;
    imageView.image = [UIImage imageNamed:@"hk_profile_4"];
    UIBarButtonItem *profileBarbutton = [[UIBarButtonItem alloc] initWithCustomView:imageView];
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
    _isCentered = NO;
    [self.view addSubview:_mapView];
    
    _search = [[AMapSearchAPI alloc] initWithSearchKey:gaodeMapAPIKey Delegate:self];
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
        
//        NSLog(@"ReGeo: %ld", [response.regeocode.addressComponent.businessAreas count]);
//        for (AMapBusinessArea *area in response.regeocode.addressComponent.businessAreas) {
//            NSLog(@"area name: %@, location: %f %f", area.name, area.location.latitude, area.location.longitude);
//        }
        
        AMapPOI *poi = [response.regeocode.pois firstObject];
        _centerPOI = poi;
        _centerPois = response.regeocode.pois;
        NSLog(@"poi: %@", poi.name);
        _paopaoView.addrLbl.text = [NSString stringWithFormat:@"从%@上车", poi.name];
        [_paopaoView.addrLbl sizeToFit];
        
        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:10.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _paopaoView.frame = CGRectMake(0, 0, _paopaoView.addrLbl.frame.size.width + 10, _paopaoView.addrLbl.frame.size.height + 10);
            _paopaoView.center = CGPointMake(_centerPinView.center.x, _centerPinView.center.y - 37);
        } completion:^(BOOL finished) {
        }];
    }
}

#pragma mark - UIButtons

-(void)requestButtonPressed:(UIButton *)sender
{

}

-(void)compareButtonPressed:(UIButton *)sender
{
    
}

-(void)profileBarButtonPressed
{
    
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

#pragma mark - MAMapViewDelegate

-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (updatingLocation) {
        _currentCoords = userLocation.location.coordinate;
        if (!_isCentered) { //如果刚初始化，则放大地图至以用户定位为中心的区域
            
            [_mapView setZoomLevel:18.0 animated:YES];
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
            _alertView = [[UIAlertView alloc] initWithTitle:@"登陆" message:@"您尚未授权优步账号，请先登陆授权后使用。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"登陆优步", nil];
            [_alertView show];
        } else {
            //可跳转Uber 设置优步绿色标志位
            [[[UIAlertView alloc] initWithTitle:@"已授权" message:@"您已授权打车神器使用您的优步账号，请点击叫车按键进行叫车（暂时仅开放人民优步车型）。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
}

@end

//
//  HKAddressTVC.m
//  hack
//
//  Created by Zhouboli on 15/7/15.
//  Copyright (c) 2015年 Bankwel. All rights reserved.
//

#import "RCAddressTVC.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define bTableViewHeight bHeight/2
#define bMapViewHeight bHeight - bTableViewHeight

static NSString *gaodeMapAPIKey = @"9f692108300515ec3819e362d6389159";

@interface RCAddressTVC () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, AMapSearchDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) AMapSearchAPI *search;
@property (strong, nonatomic) AMapInputTipsSearchResponse *tipsSearchResponse;
@property (strong, nonatomic) NSMutableDictionary *poiGeoObjs;

@end

@implementation RCAddressTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.delegate = self;
    self.navigationItem.titleView = _searchBar;

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, bWidth, bHeight) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _search = [[AMapSearchAPI alloc] initWithSearchKey:gaodeMapAPIKey Delegate:self];

}

-(void)viewWillAppear:(BOOL)animated
{
    if (_isForPickup) {
        _searchBar.placeholder = @"您想从哪上车？";
    } else {
        _searchBar.placeholder = @"您想去哪？";
    }
}

#pragma mark - UISearchBarDelegate

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"searchBarTextDidBeginEditing");
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    NSLog(@"searchBarTextDidEndEditing");
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //搜索栏有文字变更即触发检索
    if ([searchText isEqualToString:@""]) {
        _tipsSearchResponse = nil;
        [self.tableView reloadData];
    }
    _poiGeoObjs = nil;
    _poiGeoObjs = [[NSMutableDictionary alloc] initWithCapacity:10];
    [self startInputTipsSearchWithString:searchText];
}

#pragma mark - AMapSearchDelegate & Helpers

-(void)startInputTipsSearchWithString:(NSString *)searchText
{
    AMapInputTipsSearchRequest *tipsRequest = [[AMapInputTipsSearchRequest alloc] init];
    tipsRequest.searchType = AMapSearchType_InputTips;
    tipsRequest.keywords = searchText;
    tipsRequest.city = @[@"北京"];
    [_search AMapInputTipsSearch:tipsRequest];
}

-(void)startGeoCodeSearchWithAddress:(NSString *)address
{
    AMapGeocodeSearchRequest *geoRequest = [[AMapGeocodeSearchRequest alloc] init];
    geoRequest.searchType = AMapSearchType_Geocode;
    geoRequest.address = address;
    geoRequest.city = @[@"北京"];
    [_search AMapGeocodeSearch: geoRequest];
}

-(void)startPoiPlaceSearchWithKeyword:(NSString *)keyword
{
    AMapPlaceSearchRequest *placeSearchRequest = [[AMapPlaceSearchRequest alloc] init];
    placeSearchRequest.searchType = AMapSearchType_PlaceKeyword;
    placeSearchRequest.keywords = keyword;
    placeSearchRequest.city = @[@"北京"];
    placeSearchRequest.requireExtension = YES;
    
    [_search AMapPlaceSearch:placeSearchRequest];
}

-(void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)response
{
    AMapPOI *poi = [response.pois firstObject];
    [_poiGeoObjs setObject:poi forKey:request.keywords];
    NSLog(@"poi address: %@", poi.address);
    [_tableView reloadData];
}

-(void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    if(response.geocodes.count == 0){
        return;
    }
    AMapGeocode *code = [response.geocodes firstObject];
    NSLog(@"name: %@, address: %@, %f %f", request.address, code.formattedAddress, code.location.latitude, code.location.longitude);
    
    [_poiGeoObjs setObject:[response.geocodes firstObject] forKey:request.address];
    [_tableView reloadData];
}

-(void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response
{
    _tipsSearchResponse = response;
    NSLog(@"tips count: %ld", [response.tips count]);
    
    for (AMapTip *tip in response.tips) {
        //[self startGeoCodeSearchWithAddress:tip.name];
        [_poiGeoObjs setObject:[NSNull null] forKey:tip.name];
        [self startPoiPlaceSearchWithKeyword:tip.name];
    }
}

-(void)searchRequest:(id)request didFailWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:@"出错了" message:[NSString stringWithFormat:@"错误信息: %@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

#pragma mark - Table view data source & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tipsSearchResponse.count > 0 ? _tipsSearchResponse.count: [_pois count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //[tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuse"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuse"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reuse"];
    }
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (_tipsSearchResponse.count && [_poiGeoObjs count]) {
        AMapTip *tip = [_tipsSearchResponse.tips objectAtIndex:indexPath.row];
        cell.textLabel.text = tip.name;
        if (indexPath.row + 1 <= [_poiGeoObjs count]) {
            if (![[_poiGeoObjs objectForKey:tip.name] isEqual:[NSNull null]]) {
                AMapPOI *poi = [_poiGeoObjs objectForKey:tip.name];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@", poi.businessArea, poi.address];
            } else {
                cell.detailTextLabel.text = @"";
            }
        }
    } else {
        AMapPOI *poi = [_pois objectAtIndex:indexPath.row];
        cell.textLabel.text = poi.name;
        cell.detailTextLabel.text = poi.address;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *selectedObj;
    if (_tipsSearchResponse.count) {
        AMapTip *tip = [_tipsSearchResponse.tips objectAtIndex:indexPath.row];
        selectedObj = @{tip.name: [_poiGeoObjs objectForKey:tip.name]};
    }
    else
    {
        AMapPOI *poi = [_pois objectAtIndex:indexPath.row];
        selectedObj = @{poi.name: poi};
    }
    [self.delegate selectedPoiObject:selectedObj forPickup:_isForPickup];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
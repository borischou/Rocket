//
//  RCProfileTableViewController.m
//  Rocket
//
//  Created by Zhouboli on 15/7/25.
//  Copyright (c) 2015年 Bankwel. All rights reserved.
//

#import "RCProfileTableViewController.h"

@implementation RCProfileTableViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuse"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuse" forIndexPath:indexPath];
    cell.textLabel.text = @"test";
    return cell;
}

@end

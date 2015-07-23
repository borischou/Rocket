//
//  HKCarTypeCollectionViewCell.m
//  hack
//
//  Created by Zhouboli on 15/7/20.
//  Copyright (c) 2015年 Bankwel. All rights reserved.
//

#import "HKCarTypeCollectionViewCell.h"

#define unitHeight (self.contentView.frame.size.height-4)/4
#define unitWidth self.contentView.frame.size.width - 4

@implementation HKCarTypeCollectionViewCell

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initCellLayout];
    }
    return self;
}

-(void)initCellLayout
{
    self.backgroundColor = [UIColor whiteColor];
    
    _brandTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 2, unitWidth, unitHeight)];
    _brandTextLabel.textColor = [UIColor darkGrayColor];
    _brandTextLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_brandTextLabel];
    
    _brandIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, unitHeight*2, unitHeight*2)];
    _brandIconView.center = self.contentView.center;
    [self.contentView addSubview:_brandIconView];
    
    _waitingTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 2+unitHeight*3, unitWidth, unitHeight)];
    _waitingTimeLabel.textColor = [UIColor darkGrayColor];
    _waitingTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_waitingTimeLabel];
}

@end

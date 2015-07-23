//
//  HKCarTypeCollectionView.m
//  hack
//
//  Created by Zhouboli on 15/7/20.
//  Copyright (c) 2015年 Bankwel. All rights reserved.
//

#import "RCCarTypeCollectionView.h"
#import "RCCarTypeCollectionViewCell.h"

@interface RCCarTypeCollectionView ()

@end

@implementation RCCarTypeCollectionView

-(id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self initCollectionViewLayout:layout];
    }
    return self;
}

-(void)initCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self.backgroundColor = [UIColor whiteColor];
    [self registerClass:[RCCarTypeCollectionViewCell class] forCellWithReuseIdentifier:@"reuseCell"];
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)layout;
    flowLayout.itemSize = CGSizeMake((self.frame.size.width-4)/5, self.frame.size.height);
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
}

@end

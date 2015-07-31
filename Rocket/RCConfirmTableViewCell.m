//
//  RCConfirmTableViewCell.m
//  Rocket
//
//  Created by Zhouboli on 15/7/30.
//  Copyright (c) 2015年 Bankwel. All rights reserved.
//

#import "RCConfirmTableViewCell.h"

#define bSmallGap 5
#define bBigGap 10
#define bCarImageHeight 70
#define bCarImageWidth (self.contentView.frame.size.width-6*bSmallGap)*1/5
#define bPriceLabelWidth (self.contentView.frame.size.width-6*bSmallGap)*2/5
#define bPriceLabelHeight 45
#define bDistanceLabelWidth bPriceLabelWidth
#define bDistanceLabelHeight (bPriceLabelHeight-bSmallGap)/2
#define bEtaLabelWidth bPriceLabelWidth
#define bEtaLabelHeight bCarImageHeight-bPriceLabelHeight-bSmallGap
#define bFormulaLabelWidth bPriceLabelWidth
#define bFormulaLabelHeight bEtaLabelHeight

@implementation RCConfirmTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initCellLayout];
    }
    return self;
}

-(void)initCellLayout
{
    _carImageView = [[UIImageView alloc] initWithFrame:CGRectMake(bSmallGap, bSmallGap, bCarImageWidth, bCarImageHeight)];
    [self.contentView addSubview:_carImageView];
    
    _etaLabel = [[UILabel alloc] initWithFrame:CGRectMake(bSmallGap*2+bCarImageWidth, bSmallGap*2+bPriceLabelHeight, bEtaLabelWidth, bEtaLabelHeight)];
    _etaLabel.textColor = [UIColor darkGrayColor];
    [self.contentView addSubview:_etaLabel];
    
    _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(bSmallGap+bCarImageWidth+bSmallGap, bSmallGap, bPriceLabelWidth, bPriceLabelHeight)];
    _priceLabel.textColor = [UIColor darkGrayColor];
    [self.contentView addSubview:_priceLabel];
    
    _distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(bSmallGap+bCarImageWidth+bSmallGap+bPriceLabelWidth+bSmallGap, bSmallGap, bDistanceLabelWidth, bDistanceLabelHeight)];
    _distanceLabel.textColor = [UIColor darkGrayColor];
    [self.contentView addSubview:_distanceLabel];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(bSmallGap+bCarImageWidth+bSmallGap+bPriceLabelWidth+bSmallGap, bSmallGap*2+bDistanceLabelHeight, bDistanceLabelWidth, bDistanceLabelHeight)];
    _timeLabel.textColor = [UIColor darkGrayColor];
    [self.contentView addSubview:_timeLabel];
    
    _formulaLabel = [[UILabel alloc] initWithFrame:CGRectMake(3*bSmallGap+bCarImageWidth+bEtaLabelWidth, 3*bSmallGap+bDistanceLabelHeight*2, bFormulaLabelWidth, bFormulaLabelHeight)];
    _formulaLabel.textColor = [UIColor darkGrayColor];
    [self.contentView addSubview:_formulaLabel];
}

@end

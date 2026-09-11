//
//  SectionHeadingTableViewCell.m
//  HistoricPubCrawl
//
//  Created by  James on 07/08/2017.
//  Copyright © 2017 CoDeveloper. All rights reserved.
//

#import "SectionHeadingTableViewCell.h"

@implementation SectionHeadingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.layer.masksToBounds = true;

    self.titleLabel.layer.cornerRadius = 8.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

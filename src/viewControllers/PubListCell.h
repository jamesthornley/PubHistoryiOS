//
//  PoiListCell.h
//  Southend
//
//  Created by  James on 12/02/2014.
//  Copyright (c) 2014 CoDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pub.h"

@interface PubListCell : UICollectionViewCell
{
    UIView *greyoverlay;
}

@property (nonatomic) IBOutlet UIImageView *icon;
@property (nonatomic) IBOutlet UIImageView *frontImage;
@property (nonatomic) IBOutlet UILabel *numberLabel;
@property (nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic) IBOutlet UILabel *distanceLabel;
@property (nonatomic)  Pub*pub;
@property (nonatomic) IBOutlet UIImageView *tickIcon;




@end

//
//  PHAleTrailCellCollectionViewCell.h
//  London
//
//  Created by  James on 23/03/2021.
//  Copyright © 2021 CoDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHAleTrail.h"


NS_ASSUME_NONNULL_BEGIN

@interface PHAleTrailCell : UITableViewCell

@property (nonatomic)  PHAleTrail *phAleTrail;

@property (nonatomic) IBOutlet UIImageView *icon;
@property (nonatomic) IBOutlet UILabel *title;
@property (nonatomic) IBOutlet UILabel *shortDescription;


@end

NS_ASSUME_NONNULL_END

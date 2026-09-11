//
//  PHAleTrailCellCollectionViewCell.m
//  London
//
//  Created by  James on 23/03/2021.
//  Copyright © 2021 CoDeveloper. All rights reserved.
//

#import "PHAleTrailCell.h"
#import "PHAleTrail.h"
#import "SystemVariables.h"

@implementation PHAleTrailCell





-(void)setPhAleTrail:(PHAleTrail*) pphaleTrail
{
    _phAleTrail =pphaleTrail;
    
    [_shortDescription setText:_phAleTrail.shortDescription];
    _title.text = _phAleTrail.title;
    _icon.image = _phAleTrail.icon;
    
    [self setBackgroundColor:[SystemVariables colorFromHexString:_phAleTrail.backgroundColour]];
    
    [self.layer setBorderWidth: 1.0];
    [self.layer setCornerRadius:8.0f];
    [self.layer setMasksToBounds:YES];
    [self.layer setBorderColor:[[UIColor blackColor] CGColor]];
    
    
    
}
@end

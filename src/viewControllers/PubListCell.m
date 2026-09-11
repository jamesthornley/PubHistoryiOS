//
//  PoiListCell.m
//  Southend
//
//  Created by  James on 12/02/2014.
//  Copyright (c) 2014 CoDeveloper. All rights reserved.
//

#import "PubListCell.h"
#import "SystemVariables.h"

@implementation PubListCell

@synthesize pub;
@synthesize icon;
@synthesize frontImage;
@synthesize titleLabel;
@synthesize distanceLabel;
@synthesize tickIcon;


-(void)setPub:(Pub*)ppub
{

    pub= ppub;
    
    NSString *title = [pub getTitle];
    NSString *number = [pub getNumber];

    self.numberLabel.text = number;
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentCenter;
    paragraph.lineSpacing = 1.0f;
    paragraph.lineHeightMultiple = 0.80;     // Reduce this value !!!
    NSMutableAttributedString* attrText = [[NSMutableAttributedString alloc] initWithString:title];
    [attrText addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, title.length)];
    self.titleLabel.attributedText = attrText;
    
    self.distanceLabel.text = [pub getDistanceString];
    
    
    UIImage *image = [pub getIcon];
    icon.image = image;
    
    
    titleLabel.textColor = [pub getTitleColour];
    
    
    frontImage.image = image;
    icon.layer.cornerRadius = 5;
    icon.layer.masksToBounds = YES;
    
    [greyoverlay removeFromSuperview];
    
    if ([pub isVisited] == NO)
    {
        
        [tickIcon setHidden:YES];
    }
    else
    {
        
        [tickIcon setHidden:NO];
    }
}
@end

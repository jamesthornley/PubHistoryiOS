//
//  NotesListCellTableViewCell.h
//  HistoricPubCrawl
//
//  Created by  James on 27/07/2017.
//  Copyright © 2017 CoDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"
#import "Pub.h"
#import "SpeechTextView.h"
#import "BaseViewController.h"

@interface NotesListCellTableViewCell : UITableViewCell
{
}

@property (nonatomic)  Note *note;
@property (nonatomic)  BaseViewController *parent;
@property (nonatomic) IBOutlet SpeechTextView *text;
@property (nonatomic) IBOutlet UILabel *noteDate;
@property (nonatomic) IBOutlet UIImageView *image;
@property (nonatomic) IBOutlet UILabel *username;
@property (nonatomic) IBOutlet UIButton *shareButton;
@property (nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;
@property (nonatomic) IBOutlet NSLayoutConstraint *imageWidthConstraint;

-(void)setNote:(Note *)pnote;


@end

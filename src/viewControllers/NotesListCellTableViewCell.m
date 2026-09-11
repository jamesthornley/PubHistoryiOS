//
//  NotesListCellTableViewCell.m
//  HistoricPubCrawl
//
//  Created by  James on 27/07/2017.
//  Copyright © 2017 CoDeveloper. All rights reserved.
//

#import "NotesListCellTableViewCell.h"
#import "AppConfiguration.h"
#import "Note.h"
#import "UserList.h"
#import "TeamList.h"
#import "BaseDate.h"
#import "MyTrailViewController.h"
#import "TapGestureWithNote.h"

@implementation NotesListCellTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setNote:(Note *)pnote
{
    _note = pnote;
    self.text.text = @"";
    self.text.note = nil;
    self.noteDate.text = @"";
    if ([pnote isText])
    {
        self.text.note = pnote;

        self.text.text = pnote.note;
        
        [self.image setHidden:YES];
        [self.noteDate setHidden:YES];
        [self.username setHidden:YES];
        [self.text setHidden:NO];

    }
    else
    {
   
        UIImage * newImage = [pnote getImage];
        
        [self.image setImage:newImage ];
  
        self.imageWidthConstraint.constant = newImage.size.width;
        self.imageHeightConstraint.constant = newImage.size.height;

        self.noteDate.text = [pnote.noteDate getDisplayTime];

        [self.text setHidden:YES];
        [self.image setHidden:NO];
        [self.noteDate setHidden:NO];
        if ([self.note isCurrentUserWithDatabase:nil] == NO)
        {
            [self.username setHidden:NO];
            self.username.text = self.note.username;
        }
        

   //     self.image.layer.cornerRadius = 5.0;
        self.image.layer.masksToBounds = YES;
  //      self.image.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.image.layer.borderWidth = 1.0;
        
        
        TapGestureWithNote *singleTap = [[TapGestureWithNote alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.note = pnote;
        [self.image setUserInteractionEnabled:YES];
        [self.image addGestureRecognizer:singleTap];
        
    }
    
    [_shareButton addTarget:self action:@selector(shareButton:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([pnote isText])
    {
        [_shareButton setHidden:YES];
    }
    else
    {
        [_shareButton setHidden:NO];
    }
    
}

-(void)handleSingleTapGesture:(TapGestureWithNote *)tapGestureRecognizer
{
    UIImage *newImage = [UIImage imageWithContentsOfFile:[tapGestureRecognizer.note getActualFilenameWithDatabase:nil]];
    
    [self.parent.fullImageView setImage:newImage];
    [self.parent.fullImageContainerView setHidden:NO];
    
}

- (void)shareButton:(UIBarButtonItem *)sender
{
    UIImage *newImage = [UIImage imageWithContentsOfFile:[self.note getActualFilenameWithDatabase:nil]];

    NSString *textToShare = @"Share Pub History Ale Trail data";
    
    NSArray *objectsToShare = @[textToShare, newImage];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeAddToReadingList];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self.parent presentViewController:activityVC animated:YES completion:nil];
}
@end

//
//  PubTabViewController.h
//  HistoricPubCrawl
//
//  Created by  James on 23/07/2017.
//  Copyright © 2017 CoDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pub.h"
#import "BaseViewController.h"


@interface PubTabViewController : BaseViewController
{
    
}

@property (nonatomic) Pub*pub;
@property (nonatomic) Pub*selectedPub;

@property (nonatomic) IBOutlet UIButton *historyButton;
@property (nonatomic) IBOutlet UIButton *storyButton;
@property (nonatomic) IBOutlet UIButton *backButton;
@property (nonatomic) IBOutlet UIView *historyVC;
@property (nonatomic) IBOutlet UIView *storyVC;
@property (nonatomic) IBOutlet UIView *notInPubView;
@property (nonatomic) IBOutlet UITextView *nextPubName;
@property (nonatomic) IBOutlet UIImageView *nextPubIcon;
@property (nonatomic) IBOutlet UIView *notStartedYet;

@property (nonatomic) IBOutlet UILabel *pubtitle;
@property (nonatomic) IBOutlet UIProgressView *historyPV;
@property (nonatomic) IBOutlet UIProgressView *storyPV;
@property (nonatomic) IBOutlet UIButton *inPubCheckBox;
@property (nonatomic) IBOutlet UIView *beerImage;




-(IBAction) showStory;
-(IBAction) showHistory;
-(IBAction) back;
-(IBAction) start;



@end

//
//  StartTrailViewController.h
//  HistoricPubCrawl
//
//  Created by  James on 04/06/2018.
//  Copyright © 2018 CoDeveloper. All rights reserved.
//

#import "BaseViewController.h"
#import "Trail.h"

@interface StartTrailViewController : BaseViewController
{
    Trail * trail;
    BOOL isCreating;
    BOOL isGroup;
    BOOL startQuestionAsked;
    UIAlertController* alert;
}
@property (weak, nonatomic) IBOutlet UISegmentedControl *publicOrPrivate;
@property (weak, nonatomic) IBOutlet UIButton *createGroupButton;
@property (weak, nonatomic) IBOutlet UILabel *pubprivateMessage;
@property (weak, nonatomic) IBOutlet UIButton *individualButton;
@property (weak, nonatomic) IBOutlet UIButton *joinGroupButton;
@property (weak, nonatomic) IBOutlet UITextField *trailName;
@property (weak, nonatomic) IBOutlet UIView *bottomButtons;
@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

//
//  RegisterViewController.h
//  HistoricPubCrawl
//
//  Created by  James on 04/06/2018.
//  Copyright © 2018 CoDeveloper. All rights reserved.
//

#import "BaseViewController.h"
#import "NoteList.h"
#import "User.h"

@interface RegisterViewController : BaseViewController
{
    NoteList *noteList;
    User *user;

    BOOL registering;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *loginRegisterSegControl;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *whyRegisterButton;
@property (weak, nonatomic) IBOutlet UIButton *continueWithoutButton;
@property (weak, nonatomic) IBOutlet UISwitch *sendEmailsSwitch;
@property (weak, nonatomic) IBOutlet UILabel *optInMessage;

@property (weak, nonatomic) IBOutlet UIView *progressView;
+(NSString*) PASSWORD;
+(NSString*) USERNAME;
+(NSString*) DONT_REGISTER;
-(IBAction)endEditing;

@end

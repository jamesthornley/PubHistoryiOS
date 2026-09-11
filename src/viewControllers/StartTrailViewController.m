//
//  StartTrailViewController.m
//  HistoricPubCrawl
//
//  Created by  James on 04/06/2018.
//  Copyright © 2018 CoDeveloper. All rights reserved.
//

#import "StartTrailViewController.h"
#import "UserList.h"
#import "SendServerData.h"
#import "AppDelegate.h"
#import "BaseDate.h"
#import "PHLogger.h"
#import "Trail.h"
#import "GPSLocation.h"
#import "RegisterViewController.h"
#import "Reachability.h"
#import "AppConfiguration.h"
#import "NoteList.h"
#import "PubFactory.h"
#import "SystemVariables.h"
#import "PHAleTrailFactory.h"
#import "PHAleTrail.h"

@interface StartTrailViewController ()

@end

@implementation StartTrailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.progressView setHidden:YES];

    
    
    [self.publicOrPrivate setHidden:YES];
    [self.pubprivateMessage setHidden:YES];
    [self.passwordField setHidden:YES];
    [self.trailName setHidden:YES];
    [self.bottomButtons setHidden:YES];
    self.trailName.autocorrectionType = UITextAutocorrectionTypeNo;
    self.passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
    if (@available(iOS 12, *))
    {
        self.passwordField.textContentType = UITextContentTypeOneTimeCode;
    }

    self.trailName.text = [StartTrailViewController TRAIL_NAME_START];
    self.passwordField.text = [RegisterViewController PASSWORD];
    self.pubprivateMessage.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.pubprivateMessage.layer.borderWidth = 1.0;
    [self setTitle:@"Start Trail"];
    
    [self.publicOrPrivate setSelectedSegmentIndex:1];
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(endEditing)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    
    

}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([UserList isRegistered] == NO && [UserList notRegistering] == NO)
    {
        [[BaseViewController getInstance] performSegueWithIdentifier:@"Register"
                                                              sender:self] ;
    }
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480)
        {
            self.topBarHeight.constant = self.topBarHeight.constant -35 ;
            self.topBarTop.constant = 45;
        }
        if(result.height == 568)
        {
            self.topBarHeight.constant = self.topBarHeight.constant -25 ;
            self.topBarTop.constant = 55;
            self.textEntry.spacing = 10;
        }
    }
    
    startQuestionAsked = NO;
}
+(NSString*) TRAIL_NAME_START
{
    return @"Trail Name";
}
- (IBAction)start:(id)sender
{
    if ([self signInValidation ] == NO)
    {
        return;
    }
    
    if ([self checkExists] == NO )
    {
        return;
    }
    
    if ([UserList isRegistered] || [UserList notRegistering])
    {
       
        
            AppConfiguration *config = [[AppConfiguration alloc] init];
            User *user = [UserList getCurrentUser];
            trail = [[Trail alloc] init];
            
            trail.trailID = -1;
            trail.userID = user.userID;
            trail.appID = [config getAppID];
            trail.trailName = self.trailName.text;
            trail.endTime = [BaseDate getNullDate];
            trail.password = self.passwordField.text;
            trail.PHAleTrailCode = [[PHAleTrailFactory getCurrentPHAleTrail] code];
            trail.privateOrPublic = [self.publicOrPrivate titleForSegmentAtIndex:self.publicOrPrivate.selectedSegmentIndex];
            
            if (isGroup)
            {
                trail.individualOrGroup = [Trail GROUP];
            }
            else
            {
                trail.individualOrGroup = [Trail INDIVIDUAL];

            }
            trail.isCreating = isCreating;
            
            if ([UserList isRegistered] && [UserList notRegistering ] == NO)
            {
                [self.progressView setHidden:NO];
                
                Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
                NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
                if (networkStatus == NotReachable)
                {
                    
                    [PHLogger showMessage:@"Internet Connection seems to be turned off, you can turn it on now and try again or you can start later if you wish." withViewContoller:self];
                    
                    return;
                    
                }
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    
                    // Do your background work here
                    NSString *response = [SendServerData startTrail:self->trail ];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        @try {
                            
                        
                                    if (response == nil)
                                    {
                                        // SUCCESS
                                        [SystemVariables removeVariableForName:[GPSLocation GPS_OFF]]; // in case was previously turned off

                                        [NoteList resetAllNotesUserExists]; // in case continuing without clearing
                                        GPSLocation *gpsLocation = [GPSLocation getInstance];
                                        [gpsLocation startTrail];
                                        [self leaveScreen];
                                    }
                                    else if ([response isEqualToString:@"TrialNameAlreadyExists"] && self->isCreating == NO)
                                    {
                                        [PHLogger showMessage:@"Trail Name and/or Password incorrect." withViewContoller:self];
                                    }
                                    
                                    else if ([response isEqualToString:@"TrialNameAlreadyExists"] && self->isCreating)
                                    {
                                        [PHLogger showMessage:@"Trial Name already exists, please choose another" withViewContoller:self];
                                    }
                                    else if ([response isEqualToString:@""] == NO)
                                    {
                                        [self showLeaveTillLaterMessage:@"There seems to be a problem connecting to the Pub History Ale Trail server, this could be due to your internet connection or the server being down. You can try again or leave starting till later"];
                                    }
                            
                            }
                            @catch (NSException *exception)
                            {
                                [PHLogger errorLog:@"Error starting trail" withException:exception];
                            }
                        @finally
                        {
                            [self.progressView setHidden:YES];

                        }
                    });
                });
            }
            else
            {
                [trail insert];
                GPSLocation *gpsLocation = [GPSLocation getInstance];
                [gpsLocation startTrail];
            }
            
        }
    
}
- (IBAction)cancel:(id)sender
{
    [self leaveScreen];
}
- (IBAction)privatePublic:(id)sender
{
    
    if ([_publicOrPrivate selectedSegmentIndex] == 1)
    {
        _pubprivateMessage.text = @"Public means you will be able to give your friends a link to see your trail on the Pub History Ale Trail website";
        [_pubprivateMessage setBackgroundColor:[UIColor lightGrayColor]];
    }
    else
    {
       _pubprivateMessage.text = @"Private means friends will need to enter a password to see your trail on the Pub History Ale Trail website";
        [_pubprivateMessage setBackgroundColor:[UIColor lightGrayColor]];
    }
                                         
}
- (IBAction)individualClick:(id)sender
{
    [self.publicOrPrivate setHidden:NO];
    
    [self turnOn:self.individualButton];
    [self turnOff:self.joinGroupButton];
    [self turnOff:self.createGroupButton];

    [self.passwordField setHidden:YES];
    [self.trailName setHidden:YES];
    [self.bottomButtons setHidden:NO];
    
    isGroup = NO;
    isCreating = NO;
    
    if ([UserList notRegistering])
    {
        [self.pubprivateMessage setHidden:YES];
        [self.publicOrPrivate setHidden:YES];
    }
    else
    {
        [self.pubprivateMessage setHidden:NO];
        [self.publicOrPrivate setHidden:NO];
    }
}
- (IBAction)joinGroupClick:(id)sender
{
    if ([UserList notRegistering])
    {
        [self showREgisterMessage:@"You can not join a group without registering"];
        return;
    }
    [self.pubprivateMessage setHidden:YES];
    [self.publicOrPrivate setHidden:YES];

    [self turnOn:self.joinGroupButton];
    [self turnOff:self.createGroupButton];
    [self turnOff:self.individualButton];

    [self.passwordField setHidden:NO];
    [self.trailName setHidden:NO];
    [self.bottomButtons setHidden:NO];

    isGroup = YES;
    isCreating = NO;
    
}
- (IBAction)createGroupClick:(id)sender
{
    if ([UserList notRegistering])
    {
        [self showREgisterMessage:@"You can not create a group without registering"];
    
        return;
        
    }
    
    [self.pubprivateMessage setHidden:NO];
    [self.publicOrPrivate setHidden:NO];

    [self turnOff:self.joinGroupButton];
    [self turnOn:self.createGroupButton];
    [self turnOff:self.individualButton];
 
    [self.passwordField setHidden:NO];
    [self.trailName setHidden:NO];
    [self.bottomButtons setHidden:NO];
    
    isGroup = YES;
    isCreating = YES;
    
}
-(BOOL) signInValidation
{
    if ((_trailName.text == nil || [_trailName.text isEqualToString:[StartTrailViewController TRAIL_NAME_START]]) && isGroup)
    {
        [_trailName setBackgroundColor:[UIColor redColor]];

        [PHLogger showMessage:@"Please Enter A Trail Name" withViewContoller:self];
        return NO;
    }
    
    if ((_passwordField.text == nil || [_passwordField.text isEqualToString:[RegisterViewController PASSWORD]]) && isGroup )
    {
        [_passwordField setBackgroundColor:[UIColor redColor]];
        
        [PHLogger showMessage:@"Please Enter A Password" withViewContoller:self];
        return false;
    }
    
    if ([_publicOrPrivate selectedSegmentIndex] == -1 && isCreating)
    {
        [_publicOrPrivate setBackgroundColor:[UIColor redColor]];
        
        [PHLogger showMessage:@"Please Select Public or Private" withViewContoller:self];
        
        return false;
    }
    
    return true;
}
-(BOOL) checkExists
{
    PHAleTrail *phTrail = [PHAleTrailFactory getCurrentPHAleTrail];
    NoteList *notesList=[phTrail  getNotes] ;
    if (([notesList size] > 0 || [[phTrail getVisitedPubs] count] > 0) && startQuestionAsked == NO)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Info"
                                                                       message:@"You have already done some of this trail, do you want to clear all visited pubs and notes and start again? - (if you registered these will still be available online even if you clear them here)"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Clear Trail and Start Again" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action)
                                        {
                                            [notesList deleteAll];
                                            [phTrail  clearAllVisited];
                                            [SystemVariables clearVisitedPubs];
                                            self->startQuestionAsked = YES;
                                            [self start:nil];
                                        }];
        
        UIAlertAction* otherAction = [UIAlertAction actionWithTitle:@"Continue Trail without Clearing" style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action)

                                      {
                                          self->startQuestionAsked = YES;
                                          [self start:nil];

                                      }];
        UIAlertAction* anotherAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action)
                                      {
                                          
                                      }];
        [alert addAction:defaultAction];
        [alert addAction:otherAction];
        [alert addAction:anotherAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
}
- (void) showLeaveTillLaterMessage:(NSString*) message
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Info"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Try again" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
                                    {
                                        [self start:self];
                                    }];
    
    UIAlertAction* otherAction = [UIAlertAction actionWithTitle:@"Do it later" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
                                    {
                                        
                                        [self leaveScreen];
                                    }];
    [alert addAction:defaultAction];
    [alert addAction:otherAction];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void) showREgisterMessage:(NSString*) message
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Info"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
                                    {
                                        // [self start:self]; don't do nothing
                                    }];
    
    UIAlertAction* otherAction = [UIAlertAction actionWithTitle:@"Register Now" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
                                    {
                                        [[BaseViewController getInstance] performSegueWithIdentifier:@"Register"
                                                                                              sender:self] ;
                                    }];
    [alert addAction:defaultAction];
    [alert addAction:otherAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}
    - (void) leaveScreen
    {
        [self.navigationController popViewControllerAnimated:YES];
        [self dismissViewControllerAnimated:YES completion:Nil];
    }


-(void)turnOn:(UIButton*)button
{
    AppConfiguration *config = [[AppConfiguration alloc] init];
    
    [button setBackgroundColor:[config headerColour]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}
-(void)turnOff:(UIButton*)button
{
    AppConfiguration *config = [[AppConfiguration alloc] init];
    
    [button setBackgroundColor:[UIColor whiteColor]];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button.layer setBorderWidth:1.0];
    [button.layer setBorderColor:[[config headerColour] CGColor] ];
}
- (IBAction)trailnameEditingDidBegin:(id)sender
{
    [self.trailName setBackgroundColor:[UIColor whiteColor]];
    
    if ([self.trailName.text isEqualToString:[StartTrailViewController TRAIL_NAME_START]])
    {
        self.trailName.text = @"";
    }
}

- (IBAction)trailnameEditingDidEnd:(id)sender
{
    if ([self.trailName.text length] == 0)
    {
        self.trailName.text = [StartTrailViewController TRAIL_NAME_START];
    }
}
- (IBAction)passwordEditingDidBegin:(id)sender
{
    [self.passwordField setBackgroundColor:[UIColor whiteColor]];
    
    if ([self.passwordField.text isEqualToString:[RegisterViewController PASSWORD]])
    {
        self.passwordField.text = @"";
        [self.passwordField setSecureTextEntry:YES];
    }
}
- (IBAction)passwordEditingDidEnd:(id)sender
{
    if ([self.passwordField.text length] == 0)
    {
        [self.passwordField setSecureTextEntry:NO];
        self.passwordField.text = [RegisterViewController PASSWORD];
    }
}
-(void)endEditing
{
    [self.trailName resignFirstResponder];
    [self.passwordField resignFirstResponder];
}
@end

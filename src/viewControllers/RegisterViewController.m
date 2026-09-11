//
//  RegisterViewController.m
//  HistoricPubCrawl
//
//  Created by  James on 04/06/2018.
//  Copyright © 2018 CoDeveloper. All rights reserved.
//

#import "RegisterViewController.h"
#import "User.h"
#import "UserList.h"
#import "PHLogger.h"
#import "Reachability.h"
#import "SendServerData.h"
#import "SendServerThread.h"
#import "SystemVariables.h"
#import "GPSLocation.h"
#import "TrailList.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view
    
    registering = YES;
    User *user = [UserList getCurrentUser];
    if (user.username != nil && [user.username length] > 0)
    {
        self.usernameTextField.text = user.username;
    }
    if (user.email != nil && [user.email length] > 0)
    {
        self.emailTextField.text = user.email;
    }
    self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.loginRegisterSegControl setSelectedSegmentIndex:0];
    if (@available(iOS 12, *))
    {
        self.passwordField.textContentType = UITextContentTypeOneTimeCode;
    }
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(endEditing)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
+(NSString*) DONT_REGISTER
{
    return @"DONTREGISTER";
}
+(NSString*) PASSWORD
{
    return @"Password";
}
+(NSString*) USERNAME
{
    return @"Username";
}
+(NSString*) EMAIL
{
    return @"Email";
}

-(BOOL)signInValidation
{
    if (self.usernameTextField.text == nil || [self.usernameTextField.text isEqualToString:[RegisterViewController USERNAME]])
    {
        [self.usernameTextField setBackgroundColor:[UIColor redColor]];
        
        [PHLogger showMessage:@"Please Enter A Username" withViewContoller:self];
        
        return false;
    }
    if (self.passwordField.text == nil || [self.passwordField.text isEqualToString:[RegisterViewController PASSWORD]])
    {
        [self.passwordField setBackgroundColor:[UIColor redColor]];
        
        [PHLogger showMessage:@"Please Enter A Password" withViewContoller:self];
        
        return false;
    }
    
    return true;
}

- (IBAction)usernameEditingDidBegin:(id)sender
{
    [self.usernameTextField setBackgroundColor:[UIColor whiteColor]];

    if ([self.usernameTextField.text isEqualToString:[RegisterViewController USERNAME]])
    {
        self.usernameTextField.text = @"";
    }
}

- (IBAction)usernameEditingDidEnd:(id)sender
{
    if ([self.usernameTextField.text length] == 0)
    {
        self.usernameTextField.text = [RegisterViewController USERNAME];
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
- (IBAction)emailEditingDidBegin:(id)sender
{
    [self.emailTextField setBackgroundColor:[UIColor whiteColor]];

    if ([self.emailTextField.text isEqualToString:[RegisterViewController EMAIL]])
    {
        self.emailTextField.text = @"";
    }
}
- (IBAction)emailEditingDidEnd:(id)sender
{
   
    if ([self.emailTextField.text length] == 0)
    {
        self.emailTextField.text = [RegisterViewController EMAIL];
    }
    
}
- (IBAction)registerSignInAction:(id)sender
{
    if ([self.loginRegisterSegControl selectedSegmentIndex] == 1)
    {
        [self.emailTextField setHidden:YES];
        [self.sendEmailsSwitch setHidden:YES];
        [self.optInMessage setHidden:YES];
        [self.continueWithoutButton setHidden:YES];
        [self.whyRegisterButton setHidden:YES];
        [self.registerButton setTitle:@"Sign In" forState:UIControlStateNormal];
        registering = false;
        
    }
    else
    {
        [self.emailTextField setHidden:NO];
        [self.sendEmailsSwitch setHidden:NO];
        [self.optInMessage setHidden:NO];
        [self.continueWithoutButton setHidden:NO];
        [self.whyRegisterButton setHidden:NO];
        [self.registerButton setTitle:@"Register" forState:UIControlStateNormal];
        registering = true;
      
    }
    
}
- (IBAction)registerClicked:(id)sender
{
    if ([self signInValidation] == NO)
    {
        return;
    }
    
    user = [[User alloc] init];
    
    if (registering && (self.usernameTextField.text == nil || [self.usernameTextField.text isEqualToString:[RegisterViewController EMAIL]]))
    {
        [self.emailTextField setBackgroundColor:[UIColor redColor]];
        
        [PHLogger showMessage:@"Please Enter your Email Address" withViewContoller:self];
        
        return;
    }
    else if (registering && ([self.emailTextField.text containsString:@"@"] == NO || [self.emailTextField.text containsString:@"."]  == false || [self.emailTextField.text containsString:@" "]))
    {
        [self.emailTextField setBackgroundColor:[UIColor redColor]];

        [PHLogger showMessage:@"Please Enter a valid Email Address" withViewContoller:self];

        return;
    }
    else if (registering)
    {
        user.email     = self.emailTextField.text;

        user.optIn     = [NSString stringWithFormat:@"%d",self.sendEmailsSwitch.isOn ];
    }
    
    
    user.password  = self.passwordField.text;
    user.username  = self.usernameTextField.text;
        
    Reachability *connectionnetworkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus connectionnetworkStatus = [connectionnetworkReachability currentReachabilityStatus];
    
    Reachability *networkReachability = [Reachability reachabilityWithHostName:[SendServerData getServerName] ];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if (connectionnetworkStatus == NotReachable)
    {
        [PHLogger showMessage:@"Internet Connection seems to be turned off, you can turn it on now and try again or you can register later if you wish." withViewContoller:self];
    }
    else if (networkStatus == NotReachable)
    {
        [PHLogger showMessage:@"There seems to be a problem connecting to the Pub History Ale Trail server, this could be due to your internet connection or the server being down. You can try again or leave registration till later" withViewContoller:self];    }
    else
    {
        [self.progressView setHidden:NO];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            // Do your background work here
            NSString* response = [SendServerData registerUser:self->user];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (response != nil && [response isEqualToString:@"UsernameAlreadyExists"] && self->registering == NO)
                {
                    [PHLogger showMessage:@"Username and/or Password incorrect" withViewContoller:self];
                }
                
                else if (response != nil && [response isEqualToString:@"UsernameAlreadyExists"] && self->registering)
                {
                    [PHLogger showMessage:@"Username already exists, please choose another" withViewContoller:self];
                }
                else if (response != nil && [response isEqualToString:@""]  == false)
                {
                    [PHLogger showMessage:@"There seems to be a problem connecting to the Pub History Ale Trail server, this could be due to your internet connection or the server being down. You can try again or leave registering till later" withViewContoller:self];
                }
                else
                {
                    @try
                    {
                        [UserList deleteNonUsers];
                        
                        
                        [NoteList resetAllNotesNewUser]; // sets userid
                        
                        if ([TrailList onTrail ])
                        {
                           Trail *trail = [TrailList getCurrentTrail ];
                           trail.userID = [UserList getCurrentUser].userID;
                           [SendServerData startTrail:trail ];
                           GPSLocation *gpsLocation = [GPSLocation getInstance];
                           [gpsLocation startTrail];
                           
                           [trail updatePrimaryKey ];

                        }
                    }
                    @catch (NSException *exception)
                    {
                        [PHLogger errorLog:@"Exception clicking don't register" withException:exception ];
                        
                    }
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Info"
                                                                                   message:@"Thank you for registering/signing in"
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    
                    
                    [self presentViewController:alert animated:YES completion:nil];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [alert dismissViewControllerAnimated:YES completion:^{
                            [self.navigationController popViewControllerAnimated:YES];
                            [self dismissViewControllerAnimated:YES completion:Nil];
                        }];
                    });
                    
                    [SendServerThread startThread];
                    
                    [SystemVariables removeVariableForName:[RegisterViewController DONT_REGISTER]];
                }
                [self.progressView setHidden:YES];
            });
        });
    }
      
}
- (IBAction)whyRegisterClicked:(id)sender
{
    [PHLogger showMessage:@"If you register the app will upload your trail to the Pub History Ale Trail website. You will be able to log on and see your route with the pubs you visited, when you visited them, and any comments you made. Dont worry if you don't want to register now, you can do at any time" withViewContoller:self];
}
- (IBAction)dontRegisterClicked:(id)sender
{
    @try
    {
        [SystemVariables addVariableForName:[RegisterViewController DONT_REGISTER ] forValue:@"YES"];
    }
    @catch (NSException *exception)
    {
        [PHLogger errorLog:@"Exception clicking don't register" withException:exception ];
        
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:Nil];


}
-(IBAction)endEditing
{
    [self.usernameTextField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
}

- (IBAction)UsernameFinished:(id)sender
{
    [self.passwordField becomeFirstResponder];
}
- (IBAction)passwordFinished:(id)sender
{
    [self.emailTextField becomeFirstResponder];
}

@end

//
//  PubTabViewController.m
//  HistoricPubCrawl
//
//  Created by  James on 23/07/2017.
//  Copyright © 2017 CoDeveloper. All rights reserved.
//

#import "PubTabViewController.h"
#import "PHAleTrailFactory.h"
#import "PubFactory.h"
#import "AppConfiguration.h"
#import "appDelegate.h"
#import "TrailList.h"
#import "UserList.h"
#import "SystemVariables.h"
#import "TeamList.h"
#import "PHLogger.h"
#import "MoreViewController.h"
#import "SystemVariables.h"

@interface PubTabViewController ()

@end

@implementation PubTabViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    PHAleTrail *phTrail = [PHAleTrailFactory getCurrentPHAleTrail] ;

    [self.beerImage setBackgroundColor:[SystemVariables colorFromHexString:phTrail.backgroundColour]];

   
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [self showHistory];
       
       if (self.selectedPub != nil)
       {
           [self.backButton setHidden:NO];
           _pub = _selectedPub;
           _selectedPub = nil;
           [_inPubCheckBox setHidden:NO];
           
       }
       else
       {
           
           GPSLocation *gpsLocation = [GPSLocation getInstance];

           [self.backButton setHidden:YES];
           
           self.pub = gpsLocation.currentPub;
           
           [_inPubCheckBox setHidden:YES];
           
       }
    
    [self.notInPubView setHidden:YES];
    [self.notStartedYet setHidden:YES];

    if ([_pub isVisited])
    {
        _inPubCheckBox.backgroundColor = [UIColor greenColor];
    }
    else
    {
        _inPubCheckBox.backgroundColor = [UIColor lightGrayColor];
    }
    
    if ([TrailList onTrail] == NO && self.pub == nil)
    {
        [self.notStartedYet setHidden:NO];
    }
    else if (_pub == nil)
    {
        PHAleTrail *phTrail = [[TrailList getCurrentTrail] getAleTrail];

        Pub * nextPub = [phTrail getNextPub];
        
        self.nextPubName.text = [nextPub getTitle];
        self.nextPubIcon.image = [nextPub getIcon];
        
        [self.notInPubView setHidden:NO];
        self.pubtitle.text = @"Next Pub";
    }
    else
    {
        self.pubtitle.text = [self.pub getTitle];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) showStory
{
    [self.historyVC setHidden:YES];
    [self.storyVC setHidden:NO];
    [self.storyPV setProgress:1];
    [self.historyPV setProgress:0];
    AppConfiguration *config = [[AppConfiguration alloc] init];
  
    [self.historyButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.storyButton setTitleColor:config.headerColour forState:UIControlStateNormal];

}
-(IBAction) showHistory
{
    [self.historyVC setHidden:NO];
    [self.storyVC setHidden:YES];
    [self.storyPV setProgress:0];
    [self.historyPV setProgress:1];
    AppConfiguration *config = [[AppConfiguration alloc] init];

    [self.storyButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.historyButton setTitleColor:config.headerColour forState:UIControlStateNormal];
}
-(IBAction) back
{
    [self.navigationController popViewControllerAnimated:YES ];
}
-(IBAction) inPub
{
    if ([self.pub isVisited])
    {
        [PHLogger showMessage:@"\nYou can not 'unvisit' a pub.\n\n To clear all visited pubs - 'end the trail' (in the more menu), then restart it - you will be given the option to clear all visited pubs" withViewContoller:self];
        return;
    }
    
    NSString *message = @"You only need to click this button if your GPS isn't working. GPS should detect you have arrived at this pub. If your GPS isn't working make sure location is enabled for this app in your device settings. If location is enabled try rebooting the device. If GPS won't work then click the arrived button below. ";
    
    NSString * gps_off = [SystemVariables getValueForName:[GPSLocation GPS_OFF]];

    if (gps_off != nil && [gps_off length] > 0)
    {
        message = [NSString stringWithFormat:@"Have you arrived at the %@?",[self.pub getTitle]];
    }
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Info"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {}];
  
    UIAlertAction* arrivedAction = [UIAlertAction actionWithTitle:@"Arrived" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action)
                                                        {
                                                            self.inPubCheckBox.backgroundColor = [UIColor greenColor];

                                                            @try
                                                            {
                                                                GPSLocation * gpsLoc = [GPSLocation getInstance];
                                                                
                                                                if ([gpsLoc isInPub])
                                                                {
                                                                    [gpsLoc leftPubWithDoNote:YES];
                                                                }
                                                                
                                                                [gpsLoc enteredPub:self.pub];
                                                                
                                                                [gpsLoc endTrail]; // This stops the next location indicating we have left the pub from now on it's manual unless they restart GPS
                                                               

                                                                
                                                                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                                                                [appDelegate.myTrail reload];
                                                                [appDelegate.pubTrail reload];
                                                                
                                                                if (gps_off == nil || [gps_off length] == 0)
                                                                {
                                                                    [PHLogger showMessage:@"GPS will now be turned off so you can control the app manually, to turn it back on go to 'More/GPS On'" withViewContoller:self];
                                                                }
                                                                
                                                                [SystemVariables addVariableForName:[GPSLocation GPS_OFF] forValue:@"YES" ];

                                                            }
                                                            @catch (NSException *exception)
                                                            {
                                                                [PHLogger errorLog:@"Error manually setting visit" withException:exception];
                                                            }
                                                            
                                                         }];

    [alert addAction:cancelAction];
    [alert addAction:arrivedAction];
    [self presentViewController:alert animated:YES completion:nil];
    
    
}
-(IBAction) start
{
    [self.tabBarController setSelectedIndex:4 ];
    UINavigationController *nav = [[self.tabBarController viewControllers] objectAtIndex:4];
    MoreViewController *cont = [[nav viewControllers] objectAtIndex:0];
    [cont start];
}

@end

//
//  GPSLocation.m
//  audiotrails
//
//  Created by James Thornley on 25/08/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GPSLocation.h"
#import "Pub.h"
#import "PHLogger.h"
#import "PubFactory.h"
#import "DistanceTracker.h"
#import "DBInterface.h"
#import "PubFactory.h"
#import "AppDelegate.h"
#import "SendServerData.h"
#import "SystemVariables.h"
#import "BaseDate.h"
#import "TrailList.h"
#import "TeamList.h"
#import "UserList.h"
#import <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIKit.h>

@implementation OutOfPub
static sqlite3 *GPSLocation_database_;

-(id)init
{
    self = [super init];
    
    self.poisList =  [PubFactory getNotVisited];
    locationsCount = 0;
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0) return;
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
   // if (locationAge > 5.0) return;
    _gpsLocation.coordinate = newLocation.coordinate;

    [self.gpsLocation.pubController refresh];
    
    for (Pub * pub in self.poisList)
    {
        
        if ([newLocation distanceFromLocation:[pub getLocation]] <pub.triggerDistance)
        {
            
           
            @try
            {
                _gpsLocation.currentPub = pub;
                
                AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
                
                NSString *beepPath = [[NSBundle mainBundle]
                                      pathForResource:@"beep" ofType:@"mp3"];
                NSURL *backgroundMusicURL = [NSURL fileURLWithPath:beepPath];
                
                NSError *error;
                _gpsLocation.backgroundMusicPlayer = [[AVAudioPlayer alloc]
                                                      initWithContentsOfURL:backgroundMusicURL error:&error];
                [_gpsLocation.backgroundMusicPlayer prepareToPlay];
                [_gpsLocation.backgroundMusicPlayer play];
                
                [pub setVisited];
                AppConfiguration *config = [[AppConfiguration alloc] init];
                Note * note = [[Note alloc] init];
                note.note = [NSString stringWithFormat:@"%@ %@",[Note ARRIVED_MESSAGE],pub.getTitle];
                note.pubID = [[pub getNumber] intValue];
                note.appID = [config getAppID];
                note.userID = [UserList getCurrentUser].userID;
                note.teamID = [TeamList getCurrentTeam].teamID;
                note.trailID = [TrailList getCurrentTrail].trailID;
                note.noteType = [Note NOTE_TYPE_ARRIVED];

                [note insert];
                
                [SystemVariables addVariableForName:[GPSLocation CURRENT_PUB] forValue:[pub getNumber]];
                
                UILocalNotification *localNotif = [[UILocalNotification alloc] init];
                
                if (localNotif)
                {
                    localNotif.alertBody = [NSString stringWithFormat:
                                            @"You have arrived at %@",[pub getTitle]];
                    //   localNotif.alertAction = NSLocalizedString(@"Read Message", nil);
                    localNotif.soundName = @"beep.mp3";
                    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
                    
                }
                [SystemVariables addVariableForName:[GPSLocation CURRENT_PUB] forValue:[pub getNumber]];

                [_gpsLocation enteredPub];
                
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                
                UITabBarController *tabBarController = (UITabBarController *)appDelegate.window.rootViewController;
                [tabBarController setSelectedIndex:2];
            }
            @catch (NSException *exception)
            {
                [PHLogger errorLog:@"Exception inserting Arrived Note" withException:exception ];
            }
            
            
        }
    }
    
    
    
    
    @try
    {
        BaseDate *time = [[BaseDate alloc] init];
        
        NSString *sql = [NSString stringWithFormat:@"Insert into RouteTaken (lat,lng,time) values (%f,%f,'%@')",  newLocation.coordinate.latitude,newLocation.coordinate.longitude,[time getDatabaseDateTime]];
        
        [DBInterface executeUpdateWithNSString:sql];
    }
    @catch (NSException *exception)
    {
        [PHLogger errorLog:@"Exception updating Route" withException:exception ];
        
    }
    
    locationsCount++;
    
    if (locationsCount > 50)
    {
        [SendServerData checkRouteTaken];
        locationsCount = 0;
    }
    
    
}
- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return NO;
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location manager error: %@", [error description]);
}
@end

@implementation InPub

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (newLocation.horizontalAccuracy < 0) return;
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
    _gpsLocation.coordinate = newLocation.coordinate;

    [self.gpsLocation.pubController refresh];
    
    if ([newLocation distanceFromLocation:[_gpsLocation.currentPub getLocation]] > (_gpsLocation.currentPub.triggerDistance + newLocation.horizontalAccuracy))
    {
        NSString * noteStr =[NSString stringWithFormat:@"%@ %@",[Note LEFT_MESSAGE],_gpsLocation.currentPub.getTitle];
        NSString * leftStr = [_gpsLocation.currentPub getLeftMarker];
        // Can only leave once -
        
        NSString *left = [SystemVariables getValueForName:leftStr];
        if ( left == nil || [left length] == 0)
        {
            AppConfiguration *config = [[AppConfiguration alloc] init];
            Note *note = [[Note alloc] init];
            note.note = noteStr;
            note.pubID = [[_gpsLocation.currentPub getNumber] intValue];
            note.appID = [config getAppID];
            note.userID = [UserList getCurrentUser].userID;
            note.teamID = [TeamList getCurrentTeam].teamID;
            note.trailID = [TrailList getCurrentTrail].trailID;
            note.noteType = [Note NOTE_TYPE_LEFT];
            @try
            {
                [note insert];
            }
            @catch (NSException *exception)
            {
                [PHLogger errorLog:@"Exception inserting Left Note" withException:exception ];
       
            }
        }
        else
        {
            @try
            {
                Note *note = [NoteList getNoteWithNote:noteStr];
                
                //update to latest leave time
                
                note.noteDate = [[BaseDate alloc] init];
                
                [note update];
            }
            @catch (NSException *exception)
            {
                [PHLogger errorLog:@"Exception updating Left Note" withException:exception ];
                
            }
        }
        
        [SystemVariables addVariableForName:leftStr forValue:@"YES"];
        [SystemVariables removeVariableForName:[GPSLocation CURRENT_PUB]];

        [_gpsLocation leftPub];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        
        UITabBarController *tabBarController = (UITabBarController *)appDelegate.window.rootViewController;
        [tabBarController setSelectedIndex:1];
    }
  
}
- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return NO;
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location manager error: %@", [error description]);
}
@end


@implementation GPSLocation


@synthesize mapController;
@synthesize currentPub;
@synthesize backgroundMusicPlayer;
@synthesize coordinate;


-(GPSLocation*) init
{
    
	if ([TrailList onTrail])
    {
        Pub *pub;
        @try
        {
            NSString *pubNum = [SystemVariables getValueForName:[GPSLocation CURRENT_PUB]];
            
            if (pubNum != nil)
            {
                pub = [PubFactory getPoiFromNumber:[pubNum intValue]];
            }
        }
        @catch (NSException *exception)
        {
            [PHLogger errorLog:@"Error finding current Pub" withException:exception];
        }
        
        if (pub != nil)
        {
            currentPub = pub;
            [self enteredPub];
        }
        else
        {
            [self leftPub ]; // Assume out of pub to start
        }
    }
	
	return self;
	
}

-(CLLocation *) currentLocation
{
    return  [[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude  ];
}

-(void)enteredPub
{
    if (inPub == nil)
    {
        inPub = [[InPub alloc] init];
        inPub.gpsLocation = self;
    }
    if (locationManager == nil)
    {
        locationManager=[[CLLocationManager alloc] init];
        locationManager.activityType = CLActivityTypeFitness;
        locationManager.distanceFilter = 5;
        
        if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        {
            [locationManager requestAlwaysAuthorization];
        }
        [locationManager setAllowsBackgroundLocationUpdates:YES];
        [locationManager setPausesLocationUpdatesAutomatically:NO];
        [locationManager setShowsBackgroundLocationIndicator:YES];


    }
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    locationManager.delegate=inPub;
    
    [locationManager startUpdatingLocation];
    
}
-(void)leftPub
{
    
    
    
    if (outOfPub == nil)
    {
        outOfPub = [[OutOfPub alloc] init];
        outOfPub.gpsLocation = self;
    }

    outOfPub.poisList =  [PubFactory getNotVisited];

    if ([outOfPub.poisList count] == 0)
    {
        // The trail has ended
        Trail *trail = [TrailList getCurrentTrail];
        @try
        {
            [trail endTrail];
            currentPub = nil;
        }
        @catch (NSException *exception)
        {
            [PHLogger errorLog:@"Error finishing trail in gpslocation" withException:exception];
        }

        return; // Location manager etc been stopped in endtrail
    }
    if (locationManager == nil)
    {
        locationManager=[[CLLocationManager alloc] init];
        locationManager.activityType = CLActivityTypeFitness;
        locationManager.distanceFilter = 5;
        
        if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        {
            [locationManager requestAlwaysAuthorization];
        }
        [locationManager setAllowsBackgroundLocationUpdates:YES];
        [locationManager setPausesLocationUpdatesAutomatically:NO];
        [locationManager setShowsBackgroundLocationIndicator:YES];
    }
    locationManager.delegate=outOfPub;
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;

    [locationManager startUpdatingLocation];
    
    currentPub = nil;

    
    // Setup geofencing
    
   /* THIS DOESNT WORK BECAUSE IOS Defaults the distance to 100M minimum - Though that was tested on a simulator
    NSArray *list = [PubFactory getPoiArray];
    
    for (Pub *pub in list)
    {
        CLCircularRegion *region =  [[CLCircularRegion alloc] initWithCenter:[pub getCoordinate]                                              radius:20   identifier:[pub getNumber]];
        
        [locationManager startMonitoringForRegion:region];
        
    }
    */
    
}
-(void)endTrail
{
    [locationManager stopUpdatingLocation];
}
-(void)startTrail
{
    [self leftPub]; // Assume out of pub to start
}
- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    NSLog(@"Paused Locations");
}

-(void)checkLocationUpdating
{
    if ([TrailList onTrail])
    {
        if (currentPub == nil)
        {
            [self leftPub];
        }
        else
        {
            [self enteredPub];
        }
    }
}

+(void)createEndTrailNotification
{
    // THIS WON'T WORK AS IT CANT DO ANY WORK
    
        int hours = 8;
        int minute = 0;

    
        BaseDate *now = [[BaseDate alloc] init];
    
        [now addDays:1]; // Because this will be shown tmorrow
    
        NSString *message = @"Your Trail has ended, please restart if you are still on it";
    
        UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    
        content.title = [NSString localizedUserNotificationStringForKey:@"Pub History Ale Trail" arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:message
                                                             arguments:nil];
        content.sound = [UNNotificationSound defaultSound];
    
        // Configure the trigger for a wakeup.
        NSDateComponents* date = [[NSDateComponents alloc] init];
        date.hour = hours;
        date.minute = minute;
        UNCalendarNotificationTrigger* trigger = [UNCalendarNotificationTrigger
                                                  triggerWithDateMatchingComponents:date repeats:NO];
    
        // Create the request object.
        UNNotificationRequest* request = [UNNotificationRequest
                                          requestWithIdentifier:@"PubHATMorningAlarm" content:content trigger:trigger];
    
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    
   
}
+(NSString*)CURRENT_PUB
{
    return @"CurrentPub";
}

@end

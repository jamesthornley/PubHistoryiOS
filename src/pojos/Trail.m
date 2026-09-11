//
//  Trail.m
//  HistoricPubCrawl
//
//  Created by  James on 31/05/2018.
//  Copyright © 2018 CoDeveloper. All rights reserved.
//


#import "Trail.h"
#import "BaseDate.h"
#import "SendServerThread.h"
#import "SendServerData.h"
#import "AppDelegate.h"
#import "UserList.h"
#import "PHAleTrail.h"
#import "PHAleTrailFactory.h"
#import "TrailList.h"

@implementation Trail
- (id)init
{
    if (self = [super init] )
    {
        
        tableName_ = @"Trail";
        primaryKey_ = @"TrailID";
        
    }
    
    self.startTime = [[BaseDate alloc] init];
  
    return self;
}

+(NSString *)GROUP
{
    return @"GRP";
}
+(NSString *)INDIVIDUAL
{
    return @"IDV";
}

+(NSString *)getCreateStatement
{
    NSString *returnString = @" CREATE TABLE Trail ( TrailID long NOT NULL,  Password ntext,TrailName ntext,PrivateOrPublic ntext,IndividualOrGroup ntext,StartTime datetime,EndTime datetime,PHAleTrailCode ntext);     ";
    
    return returnString;
}
- (void)populateFromResultSet:(sqlite3_stmt *)statement
{
    self.trailID           = [BaseDB getInt:statement    withInt:0];
    self.password          = [BaseDB getString:statement withInt:1];
    self.trailName         = [BaseDB getString:statement withInt:2];
    self.privateOrPublic   = [BaseDB getString:statement withInt:3];
    self.individualOrGroup = [BaseDB getString:statement withInt:4];
    self.startTime         = [[BaseDate alloc] initWithNSString:[BaseDB getString:statement withInt:5]];
    self.endTime           = [[BaseDate alloc] initWithNSString:[BaseDB getString:statement withInt:6]];
    self.PHAleTrailCode    = [BaseDB getString:statement withInt:7];


}
-( void) setStrServerTrailID:(NSString *) strTrailID
{
    self.trailID = [strTrailID longLongValue];
}

-( void) endTrail
{

    _endTime = [[BaseDate alloc]init];
    
    [SendServerData amendTrail:self ];
    
    GPSLocation *gpsLocation = [GPSLocation getInstance];
    [gpsLocation endTrail];
    
    if ([gpsLocation isInPub])
    {
        [gpsLocation leftPubWithDoNote:YES];
    }
    
    [self update];
    
}

-( BOOL) isGroup
{
    return [_individualOrGroup isEqualToString: [Trail GROUP]];
}

-(NSData *)getJsonVersion
{
    // User has to be local user
    
    _userID = [UserList getCurrentUser].userID;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setValue:[NSString stringWithFormat:@"%ld",self.appID ] forKey:@"appID"];
    [dict setValue:[NSString stringWithFormat:@"%ld",self.trailID ] forKey:@"trailID"];
    [dict setValue:[NSString stringWithFormat:@"%ld",self.userID ] forKey:@"userID"];
    [dict setValue:self.trailName forKey:@"trailName"];
    [dict setValue:self.password forKey:@"password"];
    [dict setValue:self.privateOrPublic forKey:@"privateOrPublic"];
    [dict setValue:self.individualOrGroup forKey:@"individualOrGroup"];
    [dict setValue:[self.endTime getDatabaseDateTime ] forKey:@"endTime"];
    [dict setValue:self.PHAleTrailCode forKey:@"phAleTrailCode"];

    // Server can't take 1 and 0
    if (_isCreating)
    {
        [dict setValue:@"true" forKey:@"isCreating"];
    }
    else
    {
        [dict setValue:@"false" forKey:@"isCreating"];
    }

    NSError *error = nil;
    
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    
    if (error != nil)
    {
        @throw [NSException exceptionWithName:@"Creating json trail" reason:[error localizedDescription] userInfo:dict];
    }
    
    return jsonData;
    
}
-(void)updatePrimaryKey
{
    // This is where the trail was started before the user registered and then they register
    
    NSString *sql = [NSString stringWithFormat:@"update Trail set TrailID = %ld  where trailID = %ld", self.trailID,[TrailList getCurrentTrail].trailID];

    [DBInterface executeUpdateWithNSString:sql];
}
-(PHAleTrail *)getAleTrail
{
    return [PHAleTrailFactory getTrailWithCode:_PHAleTrailCode];
}
@end

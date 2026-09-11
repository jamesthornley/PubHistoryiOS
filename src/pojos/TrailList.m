//
//  TrailList.m
//  HistoricPubCrawl
//
//  Created by  James on 31/05/2018.
//  Copyright © 2018 CoDeveloper. All rights reserved.
//

#import "TrailList.h"
#import "Trail.h"
#import "BaseDate.h"

@implementation TrailList

- (id)init
{
    if (self = [super init] )
    {
        exampleElement_ = [[Trail alloc] init];
    }
    return self;
}

+(Trail*) getCurrentTrail
{
    
    NSString *sql = [NSString stringWithFormat:@"select * from Trail where endTime  =  ''"];
    
        
    TrailList *list =  (TrailList*)[TrailList populateListFromSQL:sql];

    
    return (Trail*)[list getRowWithInt:0];
    
}
+(Trail*) getTrailForId:(long)trailID
{
    
    NSString *sql = [NSString stringWithFormat:@"select * from Trail where TrailID  =  %ld",trailID];
    
        
    TrailList *list =  (TrailList*)[TrailList populateListFromSQL:sql];

    
    return (Trail*)[list getRowWithInt:0];
    
}

+(BOOL) onTrail
{
    if ([TrailList getCurrentTrail] != nil)
    {
        return true;
    }
    
    return false;
}

+(void)checkTrailEnded
{
    Trail* currentTrail = [TrailList getCurrentTrail];
    
    if ([TrailList onTrail])
    {
        BaseDate * startDate = currentTrail.startTime;
        BaseDate *endTime = [startDate copy];
        [endTime addDays:1];

        int hours = 4;
        int minutes = 0;
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: endTime.date];
        [components setHour: hours];
        [components setMinute: minutes];

        endTime.date = [gregorian dateFromComponents: components];
   
        BaseDate *now = [[BaseDate alloc] init];

        if ([now isGreaterThan:endTime])
        {
            
            [currentTrail endTrail];
            
        }
        
        
    }
}

@end

//
//  RouteTakenList.m
//  HistoricPubCrawl
//
//  Created by  James on 19/10/2018.
//  Copyright © 2018 CoDeveloper. All rights reserved.
//

#import "RouteTakenList.h"
#import "RouteTaken.h"
#import "User.h"
#import "UserList.h"
#import "Trail.h"
#import "TrailList.h"

@implementation RouteTakenList
- (id)init
{
    if (self = [super init] )
    {
        exampleElement_ = [[RouteTaken alloc] init];
    }
    return self;
}
+(RouteTakenList*)getReadyToUploadList
{
    NSString *sql = @" select rowID,* from RouteTaken where ifnull(uploaded,'') = ''";
    
    return (RouteTakenList*)[RouteTakenList populateListFromSQL:sql];

}
-(NSData *)getJsonVersion
{
    
    User *user = [UserList getCurrentUser];
    Trail* trail= [TrailList getCurrentTrail];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];

    for (RouteTaken *routeTaken in list_)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

        routeTaken.userID = user.userID;
        routeTaken.trailID = trail.trailID;

        [dict setValue:[NSString stringWithFormat:@"%ld",routeTaken.userID ] forKey:@"userID"];
        [dict setValue:[NSString stringWithFormat:@"%ld",routeTaken.trailID ] forKey:@"trailID"];
        [dict setValue:[NSString stringWithFormat:@"%f",routeTaken.lng ] forKey:@"lng"];
        [dict setValue:[NSString stringWithFormat:@"%f",routeTaken.lat ] forKey:@"lat"];
        [dict setValue:[routeTaken.time getDatabaseDateTime ] forKey:@"time"];
    
        [array addObject:dict];
    }
    
    NSError *error = nil;
    
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:array options:0 error:&error];
    
    if (error != nil)
    {
        @throw [NSException exceptionWithName:@"Creating json note" reason:[error localizedDescription] userInfo:nil];
    }
    
    return jsonData;
    
}
@end

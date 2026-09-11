//
//  TeamList.m
//  HistoricPubCrawl
//
//  Created by  James on 28/07/2017.
//  Copyright © 2017 CoDeveloper. All rights reserved.
//

#import "TeamList.h"
#import "Team.h"

@implementation TeamList
- (id)init
{
    if (self = [super init] )
    {
        exampleElement_ = [[Team alloc] init];
    }
    return self;
}
+(Team *)getCurrentTeam
{
    
    NSString *sql = [NSString stringWithFormat:@"select * from Team where current = '%@' ",@"Y"];
    
    TeamList * list = (TeamList*)[TeamList populateListFromSQL:sql];
    
    Team * team = (Team *) [list getRowWithInt:0];
    
    
    return team;
}

@end

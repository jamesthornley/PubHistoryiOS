//
//  Team.m
//  HistoricPubCrawl
//
//  Created by  James on 28/07/2017.
//  Copyright © 2017 CoDeveloper. All rights reserved.
//

#import "Team.h"

@implementation Team
- (id)init
{
    if (self = [super init] )
    {
        
        tableName_ = @"Team";
        primaryKey_ = @"TeamID";
    }
    return self;
}

+(NSString *)getCreateStatement
{
    NSString *returnString = @" CREATE TABLE Team ( TeamID long NOT NULL,  Password ntext,TeamName ntext,Current ntext); ";
    
    return returnString;
}

- (void)populateFromResultSet:(sqlite3_stmt *)statement
{
    self.teamID     = [BaseDB getInt:statement    withInt:0];
    self.password   = [BaseDB getString:statement withInt:1];
    self.teamName   = [BaseDB getString:statement withInt:2];
    self.current   = [BaseDB getString:statement withInt:3];
}
@end

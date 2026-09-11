//
//  Route.m
//  HistoricPubCrawl
//
//  Created by  James on 18/10/2018.
//  Copyright © 2018 CoDeveloper. All rights reserved.
//

#import "RouteTaken.h"
#import "DBInterface.h"
#import "AppDelegate.h"
#import "PHLogger.h"

@implementation RouteTaken

- (id)init
{
    if (self = [super init] )
    {
        primaryKey_ = @"rowID";
        tableName_ = @"RouteTaken";
    }
    
    return self;
}


+(NSString *)getCreateStatement
{
    // use ROWID as primary key
    return @"CREATE TABLE RouteTaken (  lng float , lat float ,time datetime, uploaded ntext); ";
}

-(void) setUploaded
{
    _uploaded = @"Y";
}
- (void)populateFromResultSet:(sqlite3_stmt *)statement
{
    self.rowID         = [BaseDB getInt:statement    withInt:0];
    self.lng         = [BaseDB getDouble:statement    withInt:1];
    self.lat         = [BaseDB getDouble:statement    withInt:2];
    self.time        = [[BaseDate alloc] initWithNSString:[BaseDB getString:statement withInt:3]];
    self.uploaded  = [BaseDB getString:statement withInt:4];
}

-(void) update
{
    NSString *sql = [NSString stringWithFormat:@"update RouteTaken set uploaded='%@' where rowID = %ld",self.uploaded, self.rowID];
    
   
        @try
        {
            [DBInterface executeUpdateWithNSString: sql ];

        }
        @catch (NSException *exception)
        {
            [PHLogger errorLog:@"Error updating route taken" withException:exception];
        }
    
}
@end

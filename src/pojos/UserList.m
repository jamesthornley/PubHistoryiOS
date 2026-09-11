//
//  UserList.m
//  HistoricPubCrawl
//
//  Created by  James on 27/07/2017.
//  Copyright © 2017 CoDeveloper. All rights reserved.
//

#import "UserList.h"
#import "User.h"
#import "DBInterface.h"
#import "RegisterViewController.h"
#import "SystemVariables.h"
#import "PHLogger.h"

@implementation UserList
- (id)init
{
    if (self = [super init] )
    {
        exampleElement_ = [[User alloc] init];
    }
    return self;
}

+(UserList *)getUserListWithUserID:(int)pUserID
{
    
    NSString *sql = [NSString stringWithFormat:@"select * from User where UserID = %d ",pUserID];
    
    return (UserList*)[UserList populateListFromSQL:sql];
}
+(User *)getCurrentUser
{
    
    NSString *sql = [NSString stringWithFormat:@"select * from User"];
    
    UserList * list = (UserList*)[UserList populateListFromSQL:sql];
    
    User * user = (User *) [list getRowWithInt:0];
    
    if (user == nil)
    {
        user = [[User alloc] init];
    }
    
    return user;
}
+(User *)getCurrentUserWithDatabase:(sqlite3*)database
{
    NSString *sql = [NSString stringWithFormat:@"select * from User"];
    
    UserList * list = (UserList*)[UserList populateListFromSQL:sql withDatabase:database];
    
    User * user = (User *) [list getRowWithInt:0];
    
    if (user == nil)
    {
        user = [[User alloc] init];
    }
    
    return user;
}

+(BOOL) isRegistered
{
    return [UserList getCurrentUser] != nil && [[UserList getCurrentUser ] isCreated ];
}

+( BOOL) notRegistering
{
    return [SystemVariables getValueForName:[ RegisterViewController DONT_REGISTER]] != nil;
}
+(void) deleteNonUsers
{
    // A user with a userid of -1 may have been created - get rid of it
    NSString *sql = @"delete from User where UserID <=0";
   
        
        @try
        {
            [DBInterface executeUpdateWithNSString:sql ];
        }
        @catch (NSException *exception)
        {
            [PHLogger errorLog:@"Error deleting sys var" withException:exception];
        }
  
    
}
@end

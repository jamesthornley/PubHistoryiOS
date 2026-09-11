//
//  UserTokenList.m
//  Norwich
//
//  Created by  James on 22/03/2019.
//  Copyright © 2019 CoDeveloper. All rights reserved.
//

#import "UserTokenList.h"
#import "UserToken.h"
#import "DBInterface.h"

@implementation UserTokenList
- (id)init
{
    if (self = [super init] )
    {
        exampleElement_ = [[UserToken alloc] init];
    }
    return self;
}
+(UserToken *)getTokenWithToken:(NSString*)token
{
    
    NSString *sql = [NSString stringWithFormat:@"select * from UserToken where Token = '%@'",token];
    
    UserTokenList * list = (UserTokenList*)[UserTokenList populateListFromSQL:sql];
    
    UserToken * userToken = (UserToken *) [list getRowWithInt:0];
    
    if (userToken == nil)
    {
        userToken = [[UserToken alloc] init];
    }
    
    return userToken;
}
+(void) deleteAllTokens
{
    // A user with a userid of -1 may have been created - get rid of it
    NSString *sql = @"delete from UserToken";
    
    [DBInterface executeUpdateWithNSString:sql ];
    
}
+(UserTokenList *)getUnsentTokens
{
    
    NSString *sql = [NSString stringWithFormat:@"select * from UserToken where Uploaded != '%@' ",@"Y"];
    
    return (UserTokenList*)[UserTokenList populateListFromSQL:sql];
}
@end

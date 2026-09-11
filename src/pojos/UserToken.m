//
//  UserToken.m
//  
//
//  Created by  James on 22/03/2019.
//

#import "UserToken.h"
#import "UserList.h"
#import "User.h"

@implementation UserToken

- (id)init
{
    if (self = [super init] )
    {
        
        tableName_ = @"UserToken";
        primaryKey_ = @"UserTokenID";
        
        _uploaded = @"N";
    }
    return self;
}
+(NSString *)getCreateStatement
{
    NSString *returnString = @" CREATE TABLE UserToken ( UserTokenID long, token ntext,uploaded ntext); ";
    return returnString;
}
- (void)populateFromResultSet:(sqlite3_stmt *)statement
{
    self.userTokenID = [BaseDB getInt:statement    withInt:0];
    self.token       = [BaseDB getString:statement withInt:1];
    self.uploaded    = [BaseDB getString:statement withInt:2];
    
}
-(NSData *)getJsonVersion
{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    User *user = [UserList getCurrentUser];
    
    [dict setValue:[NSString stringWithFormat:@"%ld",self.userTokenID ] forKey:@"userTokenID"];
    [dict setValue:[NSString stringWithFormat:@"%ld",user.userID ] forKey:@"userID"];
    [dict setValue:self.token forKey:@"token"];
    [dict setValue:@"IOS" forKey:@"deviceType"];

    NSError *error = nil;
    
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    
    if (error != nil)
    {
        @throw [NSException exceptionWithName:@"Creating json user" reason:[error localizedDescription] userInfo:dict];
    }
    
    return jsonData;
    
}
@end

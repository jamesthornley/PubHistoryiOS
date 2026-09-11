//
//  User.m
//  HistoricPubCrawl
//
//  Created by  James on 27/07/2017.
//  Copyright © 2017 CoDeveloper. All rights reserved.
//

#import "User.h"

@implementation User

- (id)init
{
    if (self = [super init] )
    {
        
        tableName_ = @"User";
        primaryKey_ = @"UserID";
    }
    return self;
}

+(NSString *)getCreateStatement
{
    NSString *returnString = @" CREATE TABLE User ( UserID long NOT NULL,  Password ntext,Username ntext,Email ntext,OptIn ntext); ";
    return returnString;
}

- (void)populateFromResultSet:(sqlite3_stmt *)statement
{
    self.userID     = [BaseDB getInt:statement    withInt:0];
    self.password   = [BaseDB getString:statement withInt:1];
    self.username   = [BaseDB getString:statement withInt:2];
    self.email      = [BaseDB getString:statement withInt:3];
    self.optIn      = [BaseDB getString:statement withInt:4];
}
-(void)setStrServerUserID:(NSString*) strUserID
{
    self.userID = [strUserID longLongValue];
}
-(NSData *)getJsonVersion
{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
   
    [dict setValue:[NSString stringWithFormat:@"%ld",self.userID ] forKey:@"userID"];
    [dict setValue:self.password forKey:@"password"];
    [dict setValue:self.username forKey:@"username"];
    [dict setValue:self.email forKey:@"email"];
    [dict setValue:self.optIn forKey:@"optIn"];

    NSError *error = nil;
    
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    
    if (error != nil)
    {
        @throw [NSException exceptionWithName:@"Creating json user" reason:[error localizedDescription] userInfo:dict];
    }
    
    return jsonData;
    
}
@end

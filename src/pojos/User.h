//
//  User.h
//  HistoricPubCrawl
//
//  Created by  James on 27/07/2017.
//  Copyright © 2017 CoDeveloper. All rights reserved.
//

#import "BaseDB.h"

@interface User : BaseDB

@property (nonatomic) long userID;
@property (nonatomic) NSString* username;
@property (nonatomic) NSString* email;
@property (nonatomic) NSString* optIn;
@property (nonatomic) NSString* password;

-(void)setStrServerUserID:(NSString*) strUserID;
-(NSData *)getJsonVersion;
+(NSString *)getCreateStatement;

@end

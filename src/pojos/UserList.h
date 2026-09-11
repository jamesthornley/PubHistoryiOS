//
//  UserList.h
//  HistoricPubCrawl
//
//  Created by  James on 27/07/2017.
//  Copyright © 2017 CoDeveloper. All rights reserved.
//

#import "BaseList.h"
#import "User.h"

@interface UserList : BaseList

+(UserList *)getUserListWithUserID:(int)pUserID;
+(User *)getCurrentUserWithDatabase:(sqlite3*)database;
+(User *)getCurrentUser;

+(BOOL) isRegistered;
+(BOOL) notRegistering;
+(void) deleteNonUsers;

@end

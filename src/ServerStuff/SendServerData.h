//
//  SendServerData.h
//  HistoricPubCrawl
//
//  Created by  James on 09/08/2017.
//  Copyright © 2017 CoDeveloper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Note.h"
#import "RouteTakenList.h"
#import "Trail.h"
#import "NoteList.h"
#import "User.h"
#import "UserToken.h"

@interface SendServerData : NSObject


+(void)sendNote:(Note *)note;
+(void) sendPhoto:(Note*) note;
+(NoteList *) getTeamNotes;
+(void)sendNoteSent:(Note *)note withDatabase:(sqlite3*)database;
+(void)getPhotoWithNote:(Note*)note withDatabase:(sqlite3 *)database;
+(long)amendTrail:(Trail *)trail;
+(NSString*)startTrail:(Trail *)trail;
+(NSString *)getServerName;
+(NSString *)registerUser:(User*)user;
+(void)sendRouteTaken:(RouteTakenList*) routeTakenList;
+(void)checkRouteTaken;
+(void)sendUserToken:(UserToken*) userToken;
+(void) getTeamPhotosWithList:(NoteList * )list withDatabase:(sqlite3 *)database;


@end

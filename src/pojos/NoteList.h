//
//  PositionList.h
//  FlagFinder
//
//  Created by  James on 06/12/2015.
//  Copyright © 2015  James. All rights reserved.
//

#import "BaseList.h"
#import "NoteList.h"
#import "Note.h"
#import "DBInterface.h"

@interface NoteList : BaseList
{
    NSMutableArray * sections;
}
+(NoteList *)getNoteListWithTeamID:(long)pTeamID;
+(NoteList *)getNoteListWithUserID:(long)pUserID withTrailCode:(NSString *) aleTrailCode;
+(NoteList *)getNoteListWithUserID:(long)pUserID withPubID:(long)ppubID;
+(NoteList *)getNotUploaded;
+(NoteList *)getNoteListWithServerNoteID:(long)pServerID;
-(void)serverReceivedFileAllWithDatabase:(sqlite3*)database;

+(NoteList * )getFromJson:(NSData *)reqResults;
-(void)insertAllFromServerWithDatabase:(sqlite3*)database;
+ (BaseList *)getAllInstance;
-(void)deleteAll;
-(void)resetSections;
-(void)sort;
+(BOOL)thereAreNotes;
+(void)resetAllNotesNewUser;
+(void)resetAllNotesUserExists;



-(NSArray *)getSections;
@end

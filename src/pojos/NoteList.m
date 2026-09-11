//
//  PositionList.m
//  FlagFinder
//
//  Created by  James on 06/12/2015.
//  Copyright © 2015  James. All rights reserved.
//

#import "NoteList.h"
#import "Note.h"
#import "Pub.h"
#import "DBInterface.h"
#import "SendServerData.h"
#import "UserList.h"
#import "User.h"
#import "TrailList.h"
#import "Trail.h"

@implementation NoteList

- (id)init
{
    if (self = [super init] )
    {
        exampleElement_ = [[Note alloc] init];
    }
    return self;
}
+ (BaseList *)getAllInstance
{

    NoteList *list = [[NoteList alloc] init];
    
    [list populateFromSQL:@"select * from Notes"];
    
    return list;
}

+(NoteList *)getNoteListWithTeamID:(long)pTeamID
{
    
    NSString *sql = [NSString stringWithFormat:@"select * from Notes where TeamID = %ld ",pTeamID];
    
    return (NoteList*)[NoteList populateListFromSQL:sql];
}

+(NoteList *)getNoteListWithUserID:(long)pUserID withTrailCode:(NSString *) aleTrailCode
{
    
    NSString *sql = [NSString stringWithFormat:@"select * from Notes nte, Trail trl where nte.TrailID = trl.TrailID and trl.PHAleTrailCode ='%@'",aleTrailCode ];// where UserID = %ld",pUserID];
    
    return (NoteList*)[NoteList populateListFromSQL:sql];
}
+(NoteList *)getNoteListWithUserID:(long)pUserID withPubID:(long)ppubID
{
    
    NSString *sql = [NSString stringWithFormat:@"select * from Notes where UserID = %ld and PubID=%ld",pUserID,ppubID];
    
    return (NoteList*)[NoteList populateListFromSQL:sql];
}
+(NoteList *)getNotUploaded
{
    
    NSString *sql = @"select * from Notes where Uploaded != 'Y' or UploadedPhoto != 'Y'";
    
    return (NoteList*)[NoteList populateListFromSQL:sql];
}
+(NoteList *)getNoteListWithServerNoteID:(long)pServerID
{
    NSString *sql = [NSString stringWithFormat:@"select * from Notes where ServerNoteID = %ld ",pServerID];
    
    return (NoteList*)[NoteList populateListFromSQL:sql];
}

-(NSArray *)getSections
{
    if (sections == nil)
    {
        sections = [[NSMutableArray alloc] init];
        
        Pub * currentPub;
        NSMutableArray * notesInSection = nil;
        NSMutableArray * returnSectionAndArray = nil;
        
        for (Note *note in list_)
        {
            
            if ([note getPub] == nil && notesInSection == nil) // before we've got in pub
            {
                
                notesInSection = [[NSMutableArray alloc] init];
                returnSectionAndArray = [[NSMutableArray alloc] init];
                
                Pub *pub = [[Pub alloc] init];
                [pub  setTitle:@"Between Pubs"];
                
                [returnSectionAndArray addObject:pub];
                [returnSectionAndArray addObject:notesInSection];
                
                [sections addObject:returnSectionAndArray];
            }
            if (([note getPub] == nil && [currentPub getNumber] != 0)|| [note getPub].getNumber != currentPub.getNumber) // if its outside the pub add to it last one
            {
                
                if ([note getPub] == nil)
                {
                    currentPub = [[Pub alloc] init];
                    [currentPub  setTitle:@"Between Pubs"];
                }
                else
                {
                    currentPub = [note getPub];
                }
                
                
                
                notesInSection = [[NSMutableArray alloc] init];
                returnSectionAndArray = [[NSMutableArray alloc] init];
                
                [returnSectionAndArray addObject:currentPub];
                [returnSectionAndArray addObject:notesInSection];
                
                [sections addObject:returnSectionAndArray];
            }
            
            
            [notesInSection addObject:note];
            
        }
    }
    
    return sections;
}
+(NoteList * )getFromJson:(NSData *)reqResults
{
    NoteList *returnList = [[NoteList alloc] init];
    NSError * error;
    
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:reqResults options:kNilOptions error:&error];
    
    for (NSDictionary * dataDict in jsonArray)
    {
        Note *note = [[Note alloc] initWithJson:dataDict ];
        [returnList addWithBaseDB:note];
    }
    
    return returnList;
}
-(void)insertAllFromServerWithDatabase:(sqlite3*)database
{
    for (Note* note in list_)
    {
        note.serverNoteID = note.noteID;
        note.noteID = 0;
        [note insertWithDatabase:database];
    }
}
-(void)deleteAll
{
    for (Note* note in list_)
    {
        [note delete__];
    }
}
-(void)serverReceivedFileAllWithDatabase:(sqlite3*)database
{
    for (Note* note in list_)
    {
        [SendServerData sendNoteSent:note withDatabase:database];
    }

}
-(void)resetSections
{
    sections = nil;
}
-(void)sort
{
    [list_ sortUsingSelector:@selector(compareNote:)];
}
+(BOOL)thereAreNotes
{
    return [[NoteList getAllInstance] size] > 0;
}
+(void)resetAllNotesNewUser
{
    NSString* sql = [NSString stringWithFormat:@" update Notes set Uploaded = '',UploadedPhoto='', UserID = %ld ", [UserList getCurrentUser].userID ];

    [DBInterface executeUpdateWithNSString:sql];
}
+(void)resetAllNotesUserExists
{
    NSString* sql = [NSString stringWithFormat:@" update Notes set Uploaded = '',UploadedPhoto='', TrailID = %ld where UserID = %ld " ,[TrailList getCurrentTrail].trailID,[UserList getCurrentUser].userID];

    [DBInterface executeUpdateWithNSString:sql];
}
@end

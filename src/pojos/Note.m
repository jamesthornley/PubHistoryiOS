//
//  Position.m
//  FlagFinder
//
//  Created by  James on 05/12/2015.
//  Copyright © 2015  James. All rights reserved.
//

#import "Note.h"
#import "BaseDate.h"
#import "User.h"
#import "AppConfiguration.h"
#import "UserList.h"
#import "TrailList.h"
#import "Trail.h"
#import "PubFactory.h"
#import "NoteList.h"
#import "DBInterface.h"
#import "PHAleTrailFactory.h"

@implementation Note

- (id)init
{
    if (self = [super init] )
    {
        
        tableName_ = @"Notes";
        primaryKey_ = @"NoteID";
        
        _note = @"";
           _username = @"";
           _uploaded = @"N";
           _uploadedPhoto = @"N";
    
    }
   
    return self;
}
- (id)initWithJson:(NSDictionary *)dict
{
    self = [self init];
    
    self.appID          = [[dict objectForKey:@"appID"] intValue];
    self.noteID         = [[dict objectForKey:@"noteID"] intValue];
    self.userID         = [[dict objectForKey:@"userID"] intValue];
    self.teamID         = [[dict objectForKey:@"teamID"] intValue];
    self.pubID          = [[dict objectForKey:@"pubID"] intValue];
    self.username       = [dict objectForKey:@"username"];
    self.note           = [dict objectForKey:@"note"];
    self.trailID        = [[dict objectForKey:@"trailID"] intValue];
    self.noteType        = [[dict objectForKey:@"noteType"] intValue];
    self.noteDate       = [[BaseDate alloc] initWithNSString:[dict objectForKey:@"noteDate"]];
    self.uploaded       = @"N";
    self.uploadedPhoto  = @"N";
    
    return self;
}

+(NSString *)getCreateStatement
{
    NSString *returnString = @" CREATE TABLE Notes (     AppID long NOT NULL,  NoteID long NOT NULL,      UserID long NOT NULL,    TeamID long,   PubID long,    Username ntext, Note ntext,    PhotoFileName ntext ,TrailID long, NoteType long, NoteDate DateTime, Uploaded ntext,UploadedPhoto ntext,ServerNoteID long );    ";
    
    return returnString;
}

- (void)populateFromResultSet:(sqlite3_stmt *)statement
{
    self.appID          = [BaseDB getInt:statement    withInt:0];
    self.noteID         = [BaseDB getInt:statement    withInt:1];
    self.userID         = [BaseDB getInt:statement    withInt:2];
    self.teamID         = [BaseDB getInt:statement    withInt:3];
    self.pubID          = [BaseDB getInt:statement    withInt:4];
    self.username       = [BaseDB getString:statement withInt:5];
    self.note           = [BaseDB getString:statement withInt:6];
//    self.photoFileName  = [BaseDB getString:statement withInt:7];
    self.trailID        = [BaseDB getInt:statement    withInt:8];
    self.noteType        = [BaseDB getInt:statement    withInt:9];
    self.noteDate       = [[BaseDate alloc] initWithNSString:[BaseDB getString:statement withInt:10]];
    self.uploaded       = [BaseDB getString:statement withInt:11];
    self.uploadedPhoto  = [BaseDB getString:statement withInt:12];
    self.serverNoteID   = [BaseDB getInt:statement    withInt:13];

}
-(BOOL)isText
{
    return self.noteType != [Note NOTE_TYPE_PICTURE] ;
}

-(void)insert
{
    if (_serverNoteID != 0) // This has come from the server
    {
        if ([[NoteList getNoteListWithServerNoteID:_serverNoteID] size] > 0)
        {
            return; // aleady exists
        }
    }
    else
    {
        _noteDate = [[BaseDate alloc] init];
    }
    [super insert];
}
-(CGSize ) getSize
{
    CGSize size = CGSizeZero;

    if ([self isText])
    {
        int widthValue = 200;
        
        if (_note) {
            CGRect frame = [_note boundingRectWithSize:CGSizeMake(widthValue, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:[UIFont fontWithName:@"Helvetica"  size:17] } context:nil];
            size = CGSizeMake(frame.size.width, frame.size.height + 10);
        }
        
        size.height = size.height + 20 + 30;  //plus 30 for date
        size.width = size.width + 20 ;
    }
    else
    {
    
        UIImage * image = [self getImage];
        
        size = CGSizeMake(image.size.width, image.size.height + 20);

    }
    
    return size;

}
-(BOOL)isCurrentUserWithDatabase:(sqlite3 *)database
{
    User * user = [UserList getCurrentUserWithDatabase:database];
    return user.userID == self.userID;
}
-(BOOL)isCurrentUserWithoutDatabase
{
    return [self isCurrentUserWithDatabase:nil];
}
-(Pub*)getPub
{
    if (pub == nil)
    {
        PHAleTrail *trail = [PHAleTrailFactory getCurrentPHAleTrail];
        pub = [trail getPubFromNumber:_pubID];
    }
    
    return pub;
}
-(NSString *)getActualFilenameWithDatabase:(sqlite3 *)database
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [[NSString alloc]initWithString:[documentsDirectory stringByAppendingPathComponent:[self photoFileNameWithDatabase:database]]];

}
-(NSData *)getJsonVersion
{
   
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setValue:[NSString stringWithFormat:@"%ld",self.appID ] forKey:@"appID"];
    [dict setValue:[NSString stringWithFormat:@"%ld",self.pubID ] forKey:@"pubID"];
    [dict setValue:[NSString stringWithFormat:@"%ld",self.noteID ] forKey:@"noteID"];
    [dict setValue:[NSString stringWithFormat:@"%ld",self.trailID ] forKey:@"trailID"];
#ifdef VERSION1
    [dict setValue:[NSString stringWithFormat:@"%ld",self.noteType ] forKey:@"noteType"];
#endif /* VERSION1 */
    [dict setValue:[NSString stringWithFormat:@"%ld",self.userID ] forKey:@"userID"];
    [dict setValue:[NSString stringWithFormat:@"%ld",self.teamID ] forKey:@"teamID"];
#ifndef VERSION1
    [dict setValue:[NSString stringWithFormat:@"%ld",self.noteType ] forKey:@"noteType"];
#endif /* ! VERSION1 */
    [dict setValue:self.note forKey:@"note"];
//    [dict setValue:[self photoFileName] forKey:@"photoFileName"];
    [dict setValue:[self.noteDate getDatabaseDateTime ] forKey:@"noteDate"];
    
    NSError *error = nil;

    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];

    if (error != nil)
    {
        @throw [NSException exceptionWithName:@"Creating json note" reason:[error localizedDescription] userInfo:dict];
    }
    
    return jsonData;
    
}
-(BOOL)isUploaded
{
    return [_uploaded isEqualToString:@"Y"];
}
-(BOOL)isPhotoUploaded
{
    return [_uploadedPhoto isEqualToString:@"Y"];
}
-(void)setIsUploaded
{
    _uploaded = @"Y";
}
-(void)setIsUploadedPhoto
{
    _uploadedPhoto = @"Y";
}
+(NSString *)ARRIVED_MESSAGE
{
    return @"Arrived at";
}
+(NSString *)LEFT_MESSAGE
{
    return @"Left";
}
-(BOOL)isArrivedMessage
{
    return self.noteType == [Note NOTE_TYPE_ARRIVED];
}
-(BOOL)isLeftMessage
{
    return self.noteType == [Note NOTE_TYPE_LEFT];
}
+(long) NOTE_TYPE_ARRIVED
{
    return 1;
}
+(long) NOTE_TYPE_LEFT
{
    return 2;
}
+(long) NOTE_TYPE_PICTURE
{
    return 3;
}
+(long) NOTE_TYPE_NOTE
{
    return 4;
}
- (NSComparisonResult)compareNote:(Note *)note
{
    return [self.noteDate isGreaterThan:note.noteDate];
}
-(UIImage *)getImage
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    CGSize inside = CGSizeMake(screenWidth - 60, screenWidth - 60); // just an arbitrary value for height
    UIImage *newImage = [UIImage imageWithContentsOfFile:[self getActualFilenameWithDatabase:nil]];
   // newImage = [MyTrailViewController scaleImage:newImage toSize:inside];
    
    return newImage;
}

-(NSString *)photoFileNameWithDatabase:(sqlite3 *)database
{
    
    if ([self isCurrentUserWithDatabase:database])
    {
        return [NSString stringWithFormat:@"U%ld.jpg",[self noteID]];
    }
    else
    {
        return [NSString stringWithFormat:@"%ld.jpg",[self serverNoteID]];
    }
}
-(Trail *)getTrail
{
    return [TrailList getTrailForId:self.trailID];
}
@end

//
//  Position.h
//  FlagFinder
//
//  Created by  James on 05/12/2015.
//  Copyright © 2015  James. All rights reserved.
//

@class Trail;
#import <Foundation/Foundation.h>
#import "Pub.h"
#import "BaseDB.h"
#import <MapKit/MapKit.h>


@interface Note : BaseDB
{
    Pub *pub;
}

@property (nonatomic) long appID;
@property (nonatomic) long pubID;
@property (nonatomic) long noteID;
@property (nonatomic) long serverNoteID;
@property (nonatomic) long trailID;
@property (nonatomic) long userID;
@property (nonatomic) long teamID;
@property (nonatomic) long noteType;
@property (nonatomic) NSString *username;
@property (nonatomic) NSString *note;
@property (nonatomic) NSString *uploadedPhoto;
@property (nonatomic) NSString *uploaded;
@property (nonatomic) BaseDate *noteDate;

- (id)initWithJson:(NSDictionary *)dict;

-(BOOL)isText;
-(CGSize ) getSize;
-(BOOL)isCurrentUserWithDatabase:(sqlite3*)database;
-(Pub*)getPub;
-(NSData *)getJsonVersion;

-(void)setIsUploaded;
-(void)setIsUploadedPhoto;
-(NSString *)getActualFilenameWithDatabase:(sqlite3*)database;
-(BOOL)isUploaded;
-(BOOL)isPhotoUploaded;
+(NSString *)getCreateStatement;
+(NSString *)ARRIVED_MESSAGE;
+(NSString *)LEFT_MESSAGE;
-(BOOL)isArrivedMessage;
-(BOOL)isLeftMessage;
- (NSComparisonResult)compareNote:(Note *)note;
-(UIImage *)getImage;
-(Trail *)getTrail;
-(BOOL)isCurrentUserWithoutDatabase;

+(long) NOTE_TYPE_ARRIVED;
+(long) NOTE_TYPE_LEFT;
+(long) NOTE_TYPE_PICTURE;
+(long) NOTE_TYPE_NOTE;

@end

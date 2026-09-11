//
//  Trail.h
//  HistoricPubCrawl
//
//  Created by  James on 31/05/2018.
//  Copyright © 2018 CoDeveloper. All rights reserved.
//


@class PHAleTrail;
#import "BaseDB.h"

@interface Trail : BaseDB
{
    
}


@property (nonatomic) long trailID;
@property (nonatomic) long userID;
@property (nonatomic) long appID;
@property (nonatomic) NSString *trailName;
@property (nonatomic) NSString *password;
@property (nonatomic) NSString *privateOrPublic;
@property (nonatomic) NSString *individualOrGroup;
@property (nonatomic) NSString *PHAleTrailCode;
@property (nonatomic) BaseDate *endTime;
@property (nonatomic) BaseDate *startTime;

@property BOOL isCreating; // Doesn't need to be saved, this is for the server


-(NSData *)getJsonVersion;
+(NSString *)getCreateStatement;
+(NSString *)GROUP;
+(NSString *)INDIVIDUAL;
-( BOOL) isGroup;
-( void) endTrail;
-(void)updatePrimaryKey;
-(PHAleTrail *)getAleTrail;



@end

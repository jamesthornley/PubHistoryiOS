//
//  Team.h
//  HistoricPubCrawl
//
//  Created by  James on 28/07/2017.
//  Copyright © 2017 CoDeveloper. All rights reserved.
//

#import "BaseDB.h"

@interface Team : BaseDB

@property (nonatomic) long teamID;
@property (nonatomic) NSString* teamName;
@property (nonatomic) NSString* password;
@property (nonatomic) NSString* current;

+(NSString *)getCreateStatement;

@end

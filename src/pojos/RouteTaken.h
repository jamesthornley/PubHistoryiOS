//
//  Route.h
//  HistoricPubCrawl
//
//  Created by  James on 18/10/2018.
//  Copyright © 2018 CoDeveloper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDB.h"
#import "BaseDate.h"

NS_ASSUME_NONNULL_BEGIN

@interface RouteTaken : BaseDB

@property (nonatomic) float lng;
@property (nonatomic) float lat;
@property (nonatomic) long userID;
@property (nonatomic) long trailID;
@property (nonatomic) long rowID;
@property (nonatomic) NSString *uploaded;
@property (nonatomic) BaseDate *time;


-(void) setUploaded;


@end

NS_ASSUME_NONNULL_END

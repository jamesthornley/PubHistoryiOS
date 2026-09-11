//
//  TrailList.h
//  HistoricPubCrawl
//
//  Created by  James on 31/05/2018.
//  Copyright © 2018 CoDeveloper. All rights reserved.
//

#import "BaseList.h"
#import "Trail.h"

@interface TrailList : BaseList

+(Trail*) getCurrentTrail;
+(BOOL) onTrail;
+(void)checkTrailEnded;
+(Trail*) getTrailForId:(long)trailID;

@end

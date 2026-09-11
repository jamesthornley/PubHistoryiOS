//
//  Trail.h
//  London
//
//  Created by  James on 22/03/2021.
//  Copyright © 2021 CoDeveloper. All rights reserved.
//

#import "Pub.h"
#import "NoteList.h"
#import "Route.h"

NS_ASSUME_NONNULL_BEGIN


@interface PHAleTrail : NSObject

@property NSString *code;
@property NSString *order;
@property NSString *title;
@property NSString *shortDescription;
@property NSString *backgroundColour;
@property NSArray *route;
@property (nonatomic) UIImage *icon;

-(PHAleTrail*) initWithString:(NSString *) pTrailString;
-(NSMutableArray *)getPubs;
-(Pub*) getNextPub;
-(Route*) getRoute;
-(NSMutableArray*) getVisitedPubs;
-(void) clearAllVisited;
-(NSMutableArray*) getNotVisited;
-(NoteList *)getNotes;
-(Pub*) getPubFromNumber: (long) number;





@end

NS_ASSUME_NONNULL_END

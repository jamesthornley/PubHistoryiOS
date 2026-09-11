//
//  Trail.m
//  London
//
//  Created by  James on 22/03/2021.
//  Copyright © 2021 CoDeveloper. All rights reserved.
//

#import "PHAleTrail.h"
#import "Pub.h"
#import "PubFactory.h"
#import "AppDelegate.h"
#import "GPSLocation.h"
#import "PHLogger.h"
#import "SystemVariables.h"
#import "Route.h"
#import "AppConfiguration.h"
#import "TrailList.h"
#import "Trail.h"
@implementation PHAleTrail

-(PHAleTrail*) init

{
    self = [super init];
    _title = @"";
    return self;

}
-(PHAleTrail*) initWithString:(NSString *) pTrailString
{
    self = [super init];
    
    NSArray* elements =
          [pTrailString componentsSeparatedByCharactersInSet:
           [NSCharacterSet characterSetWithCharactersInString:@","]];
    
    _code = [elements objectAtIndex:0];
    _order = [elements objectAtIndex:1];
    _title = [elements objectAtIndex:2];
    _shortDescription = [elements objectAtIndex:3];
    _backgroundColour = [elements objectAtIndex:4];

    return self;
}


-(UIImage*) icon
{
    
    
    if (_icon == nil)
    {
        
        NSString *imageString = [_code copy];
        imageString = [imageString stringByAppendingString:@"_thumb.jpg"];
        imageString = [[[AppConfiguration getContentFolder] stringByAppendingString:@"/thumbs/"] stringByAppendingString:imageString];
        _icon = [UIImage imageWithContentsOfFile: imageString] ;
        
    }
    
    
    return _icon;
}


- (NSComparisonResult) myCompare:(PHAleTrail*)obj
{

    return [_order compare:obj.order];
}

-(NSMutableArray *)getPubs
{
    NSMutableArray * returnArray = [[NSMutableArray alloc] init];
    for (Pub *pub in [PubFactory getPubArray])
    {
        if ([pub.phTrailCode isEqualToString: self.code ])
        {
            [returnArray addObject:pub];
        }
    }
    
    return returnArray;
}
-(Pub*) getNextPub
{
    int lastPubNumber = -1;
    int  firstPubNotVisited = -1;
    int iCount = 0;
    
    for (Pub* pub in [self getPubs])
    {
        if (pub.isVisited == YES)
        {
            lastPubNumber = iCount;
        }
        else if (pub.isVisited == NO && firstPubNotVisited == -1)
        {
            firstPubNotVisited = iCount;
        }

        
        iCount++;

    }
    
    if (lastPubNumber == -1)
    {
        return [[self getPubs] objectAtIndex:0];
    }
    else if (lastPubNumber == [[self getPubs]  count] - 1 && firstPubNotVisited != -1)
    {
        return [[self getPubs]  objectAtIndex:firstPubNotVisited];
    }
    else if (lastPubNumber < [[self getPubs]  count] - 1 )
    {
        return [[self getPubs]  objectAtIndex:lastPubNumber+1];
    }
    
    return nil;
}
-(Route*) getRoute
{
    Route* returnRoute = [[Route alloc] init];
    returnRoute.phTrailCode = self.code;
    
    return returnRoute;
}


-(NSMutableArray*) getVisitedPubs
{
    NSMutableArray * returnArray = [[NSMutableArray alloc] init];
    
    for (Pub* pub in [self getPubs])
    {
        if ([pub isVisited])
        {
            [returnArray addObject:pub];
        }
    }
    
    return returnArray;
}

-(void) clearAllVisited
{
    for (Pub* pub in [self getVisitedPubs])
    {
        [pub setNotVisited];
    }
}
-(NSMutableArray*) getNotVisited
{
    NSMutableArray * returnArray = [[NSMutableArray alloc] init];
    
    for (Pub* pub in [self getPubs])
    {
        if ([pub isVisited] == NO)
        {
            [returnArray addObject:pub];
        }
    }
    
    return returnArray;
}
-(NoteList *)getNotes
{
    NoteList * returnList = [[NoteList alloc] init];
    
    for (Note * note in [NoteList getAllInstance].list)
    {
        Trail * trail =[note getTrail];
        if ([trail.PHAleTrailCode isEqualToString:self.code])
        {
            [returnList addWithBaseDB:note];
        }
    }
    
    return returnList;
}
-(Pub*) getPubFromNumber: (long) number
{
    
    Pub* returnMedia;
    
    for (int iCount = 0; iCount < [[self getPubs] count]; iCount++)
    {
        Pub *pub= [[self getPubs] objectAtIndex:iCount];
        
        if ([[pub getNumber] intValue] == number)
        {
            returnMedia = pub;
        }
    }
    
    return returnMedia;
}
@end


//
//  Pub.m
//  HelloWorld
//
//  Created by James Thornley on 17/01/2001.
//  Copyright 2001 __MyCompanyName__. All rights reserved.
//

#import "Pub.h"
#import "AppDelegate.h"
#import "GPSLocation.h"
#import "PHLogger.h"
#import "SystemVariables.h"
#import "AppConfiguration.h"
#import "TrailList.h"


@implementation Pub
@synthesize xCoord;
@synthesize yCoord,fileName=filename;
-(Pub*) init

{
    self = [super init];
    title = @"";
    return self;

}
-(Pub*) initWithString:(NSString *) pPubString
{
	self = [super init];
    
    NSArray* elements =
          [pPubString componentsSeparatedByCharactersInSet:
           [NSCharacterSet characterSetWithCharactersInString:@","]];
    
    _phTrailCode = [elements objectAtIndex:0];
    number = [elements objectAtIndex:1];
    title = [elements objectAtIndex:2];
    self.xCoord = [[elements objectAtIndex:3] doubleValue];
    self.yCoord = [[elements objectAtIndex:4] doubleValue];
    self.triggerDistance = [[elements objectAtIndex:5] longLongValue];
	
	return self;
}
-(NSString*) getTitle
{
	NSString * returnValue = @""; // can use getNumber
	//returnValue = [returnValue stringByAppendingString:@". "];
	returnValue = [returnValue stringByAppendingString:title];
	return returnValue;
}

-(NSString*) getFilePrefix
{
    
    
    return [NSString stringWithFormat:@"%@_%@",_phTrailCode,number];
    
    
}
-(NSString*) getPhotoPrefix
{
    
    
    return [[NSString stringWithFormat:@"%@_%@",_phTrailCode,[title stringByReplacingOccurrencesOfString:@" " withString:@"_"]] lowercaseString];
    
    
}

-(UIImage*) getIcon
{
	
	
	if (icon == nil)
	{
        NSString *imageString = [NSString stringWithFormat:@"/thumbs/%@_%@_thumb.jpg",self.phTrailCode,[number copy]];
      
        imageString = [[AppConfiguration getContentFolder]  stringByAppendingString:imageString];
        
        icon = [UIImage imageWithContentsOfFile: imageString] ;
        
	}
	
	
	return icon;
}
-(UIImage*) getMapIcon
{
    UIImage *returnImage;
    
    if (self.isVisited)
    {
        returnImage = [UIImage imageNamed:@"mappin_visited"];
    }
    else
    {
        returnImage = [UIImage imageNamed:@"mappin"];
    }
	return returnImage;
}

-(NSString*) getNumber
{
	return number;
}
- (NSComparisonResult) myCompare:(Pub*)obj
{

    return [number compare:[obj getNumber]];
}


+(NSString*) getFileContents:(NSString *) pfileName 
{
	
    
    
	NSString *dataPathName = [[AppConfiguration getContentFolder]
							  stringByAppendingPathComponent:pfileName]; 
	
	NSFileHandle* file = [NSFileHandle fileHandleForReadingAtPath: dataPathName];
	NSString *buffer = @""; 
	
	if (file == nil)
        NSLog(@"Failed to open file");
	else {
		
		
		NSError *error;
		
		buffer = [NSString stringWithContentsOfFile:dataPathName encoding:NSUTF8StringEncoding error:&error];
        if (buffer == nil)
        {
            NSLog(@"%@", [error localizedDescription]);
        }
		[file closeFile];
	}
	
	return buffer;
}

-(NSString *) getTextForAudio:(NSString *) pAudioFileName 
{
	NSString *textfilename = [pAudioFileName substringToIndex:[pAudioFileName length]-4];
	textfilename = [textfilename stringByAppendingString:@"mp3.txt"];
	NSString *buffer = [Pub getFileContents:textfilename];
	
	return buffer;
	
}

-(CLLocation *) getLocation
{
	if (location == nil)
	{
		location = [[CLLocation alloc] initWithLatitude:self.yCoord longitude:self.xCoord  ];	
		
	}
	
	return location;
}
-(CLLocationCoordinate2D ) getCoordinate
{
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(self.yCoord, self.xCoord);
    
    return centerCoordinate;
}

-(int)getDistanceMetres
{
    
    GPSLocation *gpsLocation = [GPSLocation getInstance];

    int distance = [[self getLocation ]distanceFromLocation:[gpsLocation currentLocation]];

    if ([TrailList onTrail] == NO)
    {
        distance = -1;
    }
    return distance;
}
-(NSString *)getDistanceString
{
    NSString *returnString = [NSString stringWithFormat:@"%d Metres",[self getDistanceMetres]];
    
    if ([self getDistanceMetres ] > 1500)
    {
        returnString = [NSString stringWithFormat:@"%d Miles",[self getDistanceMetres]/1609];
    }
    else if (([self getDistanceMetres]/1609) > 3000)
    {
        returnString = @" unknown";
    }
    else if ([self getDistanceMetres] < 0)// Not on trail yet
    {
        returnString = @"";
    }
    
    return returnString;
}

-(Boolean)isVisited
{
    NSString *sysVar = [SystemVariables getValueForName:[self getTitle]];
    
    if (sysVar == nil || [sysVar length] == 0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
    
}
-(void)setVisited
{
    @try
    {
        [SystemVariables addVariableForName:[self getTitle] forValue:@"YES"];
    }
    @catch (NSException *exception)
    {
        [PHLogger errorLog:@"Exception setting visited" withException:exception ];
        
    }
    
}
-(void)setNotVisited
{
    
    @try
    {
        [SystemVariables removeVariableForName:[self getTitle]];
        [SystemVariables removeVariableForName:[self getLeftMarker]];
    }
    @catch (NSException *exception)
    {
        [PHLogger errorLog:@"Exception unsetting visited" withException:exception ];
        
    }
}



-(UIColor *)getTitleColour
{
    UIColor * returncolour;

    returncolour = [UIColor blackColor];
    
    return returncolour;
}


-(Boolean)isRoute
{
    return NO;
}
-(NSString*)getLeftMarker
{
    return [NSString stringWithFormat:@"LEFT %@",[self getNumber]];
}
-(void)setTitle:(NSString*)ptitle
{
    title = ptitle;
}

@end

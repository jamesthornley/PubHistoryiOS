//
//  Pub.h
//  HelloWorld
//
//  Created by James Thornley on 17/01/2001.
//  Copyright 2001 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface Pub: NSObject 
{
	
    NSString *filename;
    NSString *number;
	NSString * title;
	NSString * category;
	UIImage * icon;
	NSString *filePrefix;
	
	CLLocation *location;
	
	double xCoord;
	double yCoord;

}
@property double xCoord;
@property double yCoord;
@property long triggerDistance;
@property NSString *fileName;
@property NSString *phTrailCode;


-(Pub*) initWithString:(NSString *) pPubString ;
-(NSString*) getTitle;
-(UIImage*) getIcon;
-(NSString*) getFilePrefix;
-(NSString*) getNumber;
- (NSComparisonResult) myCompare:(Pub*)obj;


+(NSString*) getFileContents:(NSString *) pfileName ;
-(NSString *) getTextForAudio:(NSString *) pAudioFileName ;

-(CLLocation *) getLocation;
-(int)getDistanceMetres;
-(NSString *)getDistanceString;

-(Boolean)isVisited;
-(Boolean)isRoute;

-(void)setVisited;
-(void)setNotVisited;
-(UIColor *)getTitleColour;
-(UIImage*) getMapIcon;
-(CLLocationCoordinate2D ) getCoordinate;
-(NSString*)getLeftMarker;
-(void)setTitle:(NSString*)ptitle;
-(NSString*) getPhotoPrefix;


@end

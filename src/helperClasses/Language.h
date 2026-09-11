//
//  Language.h
//  Glaslyn
//
//  Created by James Thornley on 24/02/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *currentLanguage;
extern NSMutableDictionary *languages;
extern NSMutableDictionary *currentLanguageDict;
extern NSMutableArray *languageArray;

@interface Language : NSObject 
{
    

	
}


+(NSMutableDictionary *) getLanguages;

+(boolean_t) isEnglish;
+(void) setEnglish;
+(void) setLanguage:(NSString *)language;
+(NSString *) getIntroText;
+(NSString *) getInfoText;
+(NSString *) getGettingThereText;
+(NSString *) getMoreText;
+(NSString *) getOptionText;
+(NSString *) getDistanceText;
+(NSString *) getMetricText;
+(NSString *) getOnText;
+(NSString *) getOffText;
+(NSString *) getVibrateText;
+(NSString *) getTriggerText;
+(NSString *) getSafetyText;
+(NSString *) getPOIText;
+(NSString *) getPOIShortText;

+(NSString *) getMapText;
+(NSString *) getAboutText;
+(NSString *) getNavigationText;
+(NSString *) getFeedBackText;

+(NSString *) getLanguageText;
+(NSString *) getRouteText;
+(NSString *) getHtml:(NSString*)fileName;
+(NSString *) getLanguage;
+(NSMutableArray *) getLanguageArray;
@end


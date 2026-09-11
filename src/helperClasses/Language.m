//
//  Language.m
//  Glaslyn
//
//  Created by James Thornley on 24/02/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Language.h"
#import "PoiMedia.h"


@implementation Language

NSString *currentLanguage;
NSMutableDictionary *languages;
NSMutableDictionary *currentLanguageDict;
NSMutableArray *languageArray;

+(NSMutableDictionary*) getLanguages;
{
    if (languages == nil)
    {
        languages = [[NSMutableDictionary alloc] init];
        NSString *bundlePathName = [[NSBundle mainBundle] bundlePath];
        NSString *dataPathName = [bundlePathName
                                  stringByAppendingPathComponent:@"languages.txt"];
        
        NSFileHandle* file = [NSFileHandle fileHandleForReadingAtPath: dataPathName];
        NSString *buffer = @"";
        
        if (file == nil)
            NSLog(@"Failed to open file");
        else {
            
            
            NSError *error;
            
            buffer = [NSString stringWithContentsOfFile:dataPathName encoding:NSUTF16StringEncoding error:&error];
            if (buffer == nil)
            {
                NSLog(@"%@", [error localizedDescription]);
            }
            [file closeFile];
        }

        
        NSArray *lines = [buffer componentsSeparatedByString:@"\n"];
         languageArray = [[NSMutableArray alloc] init];
        
        int iLineCount=0;
        for (id object in lines)
        {
            NSString *line = object;
            line = [line stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]; //remove carriage return
            
             NSArray *words = [line componentsSeparatedByString:@","];
            
            int iWordCount = 0;
            NSString *keyValue;
            for (id wordobject in words)
            {
                NSString *word = wordobject;
                
                if (iLineCount == 0 && iWordCount > 0)
                {
                    NSMutableDictionary *dict =  [[NSMutableDictionary alloc] init];
                    
                    [languages setObject:dict forKey:word];
                    [languageArray addObject:word ];
                }
                if (iLineCount == 1 && iWordCount > 0)
                {
                    NSMutableDictionary *dict = [languages objectForKey:[languageArray objectAtIndex:iWordCount - 1]] ;
                      [dict setValue:word forKey:@"title"];
                }
                else if (iLineCount > 1 && iWordCount == 0)
                {
                    keyValue = word;
                    
                }
                else if (iLineCount > 1 && iWordCount > 0)
                {
                     NSMutableDictionary *dict = [languages objectForKey:[languageArray objectAtIndex:iWordCount - 1]] ;
                    
                    [dict setValue:word forKey:keyValue];
                    
                }
                
                iWordCount++;
            }
            
            iLineCount++;
        }
        
        
    }
	return languages;
}

+(void) setEnglish
{
	currentLanguage = [[NSString alloc] initWithFormat:@"English"];

}
+(boolean_t) isEnglish
{
	if (currentLanguage == nil)
	{
		currentLanguage =  [[NSString alloc] initWithFormat:@"English"];
	}
	return [currentLanguage isEqualToString:@"English" ];
}

+(NSString *) getIntroText
{
	if ([self isEnglish])
	{
		return @"Home";
	}
    return [currentLanguageDict objectForKey:@"Home"];
}
+(NSString *) getInfoText
{
	if ([self isEnglish])
	{
		return @"Information";
	}
    return [currentLanguageDict objectForKey:@"Info"];
}
+(NSString *) getGettingThereText
{
	if ([self isEnglish])
	{
		return @"Getting There";
	}
    return [currentLanguageDict objectForKey:@"Getting"];

}
+(NSString *) getMoreText
{
	if ([self isEnglish])
	{
		return @"More";
	}
    return [currentLanguageDict objectForKey:@"More"];

}
+(NSString *) getOptionText
{
	if ([self isEnglish])
	{
		return @"Options";
	}
    return [currentLanguageDict objectForKey:@"Options"];
}
+(NSString *) getDistanceText
{
	if ([self isEnglish])
	{
		return @"Distance Measurements";
	}
    return [currentLanguageDict objectForKey:@"Distance"];

}
+(NSString *) getMetricText
{
	if ([self isEnglish])
	{
		return @"Metric";
	}
    return [currentLanguageDict objectForKey:@"Metric"];
}
 

+(NSString *) getOnText
{
	if ([self isEnglish])
	{
		return @"On";
	}
    return [currentLanguageDict objectForKey:@"On"];
}
+(NSString *) getOffText
{
	if ([self isEnglish])
	{
		return @"Off";
	}
    return [currentLanguageDict objectForKey:@"Off"];
}
+(NSString *) getVibrateText
{
	if ([self isEnglish])
	{
		return @"Vibrate in range";
	}
    return [currentLanguageDict objectForKey:@"Vibrate"];
}
+(NSString *) getTriggerText
{
	if ([self isEnglish])
	{
		return @"Trigger Distance for POIs (Meters) ";
	}
    return [currentLanguageDict objectForKey:@"Trigger"];
}
+(NSString *) getSafetyText
{
	if ([self isEnglish])
	{
		return @"Safety";
	}
    return [currentLanguageDict objectForKey:@"Safety"];

}
+(NSString *) getAboutText
{
	if ([self isEnglish])
	{
		return @"About";
	}
    return [currentLanguageDict objectForKey:@"About"];
}
+(NSString *) getPOIText
{
	if ([self isEnglish])
	{
		return @"Places";
	}
	
    return [currentLanguageDict objectForKey:@"Places"];
}

+(NSString *) getPOIShortText
{
	if ([self isEnglish])
	{
		return @"Places";
	}
	
    return [currentLanguageDict objectForKey:@"Places"];
}
+(NSString *) getFeedbackText
{
	if ([self isEnglish])
	{
		return @"Feedback";
	}
	
    return [currentLanguageDict objectForKey:@"Feedback"];
}

+(NSString *) getLanguageText
{
	if ([self isEnglish])
	{
		return @"Language";
	}
	
    return [currentLanguageDict objectForKey:@"Language"];
}

+(NSString *) getMapText
{
    if ([self isEnglish])
	{
		return @"Map";
	}
	return [currentLanguageDict objectForKey:@"Map"];
}
+(NSString *) getRouteText
{
    if ([self isEnglish])
	{
		return @"Trails";
	}
	return [currentLanguageDict objectForKey:@"Trails"];
}
+(NSString *) getFeedBackText
{
    if ([self isEnglish])
	{
		return @"Feedback";
	}
	return [currentLanguageDict objectForKey:@"Feedback"];
}

+(NSString *) getNavigationText
{
	return @"Nav";
}

+(void) setLanguage:(NSString *)language
{
    currentLanguageDict = [[self getLanguages] objectForKey:language];
    currentLanguage = language;
}

+(NSString *) getHtml:(NSString*)fileName
{
    if ([self isEnglish] == false)
    {
        NSString *newFilename = [fileName stringByAppendingString:@"_"];
        newFilename = [newFilename stringByAppendingString:currentLanguage];
        
        NSString * htmlFilename = [newFilename stringByAppendingString:@".html"];
        
        NSString *bundlePathName = [[NSBundle mainBundle] bundlePath];
        NSString *dataPathName = [bundlePathName
                                  stringByAppendingPathComponent:htmlFilename];
        
        NSFileHandle* file = [NSFileHandle fileHandleForReadingAtPath: dataPathName];
        
        if (file != nil)
        {
            [file closeFile];
            return [newFilename lowercaseString];
        }
        
    }
    
    return fileName; //default to English
}

+(NSString *) getLanguage
{
    return currentLanguage;
}
+(NSMutableArray *) getLanguageArray
{
    [self getLanguages];//makes sure array is populated
    return languageArray;
}


@end

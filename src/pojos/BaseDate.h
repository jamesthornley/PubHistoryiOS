
#ifndef _BaseDate_H_
#define _BaseDate_H_

#import <Foundation/Foundation.h>


#define BaseDate_serialVersionUID 1

@interface BaseDate : NSObject
{
	NSDate *date_;

	BOOL isNullBool_;
}
@property (nonatomic) NSDate *date;
@property (nonatomic) BOOL isNullBool;

- (id)initWithNSString:(NSString *)thisDate;
- (id)initWithMSString:(NSString *)thisDate;
- (id)initWithPickerDate:(NSDate *)thisDate;
- (id)initWithUSString:(NSString *)thisDate;


- (BOOL)equalsDate:(BaseDate *)otherDate;
- (BOOL)equalsDateTime:(BaseDate *)otherDate;
- (BOOL)isGreaterThan:(BaseDate *)compareDate;
- (BOOL)isLessThan:(BaseDate *)compareDate;
- (BOOL)isGreaterThanOrEquals:(BaseDate *)inDate;
- (BOOL)isLessThanOrEquals:(BaseDate *)inDate;
- (BOOL)isGreaterThanOrEqualsIgnoreTime:(BaseDate *)dateFrom;
- (BOOL)isLessThanOrEqualsIgnoreTime:(BaseDate *)dateFrom;
- (BOOL)isGreaterThanIgnoreTime:(BaseDate *)dateFrom;
- (BOOL)isLessThanIgnoreTime:(BaseDate *)dateFrom;

- (void)addDays:(long)number;
- (long)getHours;
- (long)getDifferenceInMinutes:(BaseDate *)otherDate;

- (BOOL)isNull;
+ (BaseDate *)getIndefinateFutureDate;
+ (BaseDate *)getIndefinatePastDate;
+ (BaseDate *)getNullDate;
- (void)setTimeWithNSString:(NSString *)time;

- (NSString *)getDatabaseDateTime;
- (NSString *)getDisplayDateTime;
- (NSString *)getDisplayTime;
- (NSString *)getDisplayDate;
- (NSString *)getDatabaseDate;
- (NSString *)logDate;
- (NSString *)getDayMonth;
- (NSString *)getMSDatasetDate;
- (NSString *)timingDate;
-(double) getJulianDate;

-(NSString *)description;
-(BaseDate*)copy;

@end

#endif // _BaseDate_H_

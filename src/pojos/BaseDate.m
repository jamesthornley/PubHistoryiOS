#include "BaseDate.h"
#include "BaseDate.h"


@implementation BaseDate


static BaseDate *BaseDate_INDEFINATE_FUTURE_DATE_;
static BaseDate *BaseDate_INDEFINATE_PAST_DATE_;
static NSDateFormatter *databaseDateFormat_;

static NSDateFormatter *databaseDateTimeFormat_;
static NSDateFormatter *databaseOtherDateTimeFormat_;

static NSDateFormatter *displayDateFormat_;
static NSDateFormatter *displayTimeFormat_;
static NSDateFormatter *displayDateTimeFormat_;
static NSDateFormatter *logDateFormat_;
static NSDateFormatter *dayMonthFormat_;
static NSDateFormatter *timingDateFormat_;
static NSDateFormatter *msDateFormat_;
static NSDateFormatter *usDateFormat_;
static NSDateFormatter *usDateFormatNoAM_;
static NSDateFormatter *timeFormat_;


@synthesize date = date_;
@synthesize isNullBool = isNullBool_;

- (id)init
{
    if  (self = [super init])
    {
        date_ = [[NSDate alloc]init];
        isNullBool_ = NO;
    }
    
    return self;
}

- (id)initWithNSString:(NSString *)thisDate
{
    // assume is database format - any other format requires a special call
    // Formatter configuration
    //   NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    //  [formatter setLocale:posix];
    
    if ([thisDate rangeOfString:@":"].location != NSNotFound)
    {
        date_ = [databaseDateTimeFormat_ dateFromString:thisDate];
        if (date_ == nil)
        {
            date_ = [databaseOtherDateTimeFormat_ dateFromString:thisDate];
            isNullBool_ = NO;
            
        }
    }
    else
    {
        date_ = [databaseDateFormat_ dateFromString:thisDate];
        isNullBool_ = NO;

    }
    return self;
}
- (id)initWithUSString:(NSString *)thisDate
{
    self = [super init];
    // assume is database format - any other format requires a special call
    // Formatter configuration
    //   NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    //  [formatter setLocale:posix];
    
    if ([thisDate rangeOfString:@":"].location != NSNotFound)
    {
        date_ = [usDateFormat_ dateFromString:thisDate];
        if (date_ == nil)
        {
            // old ios 7 versions sometimes need this, but time will be wrong
            [usDateFormat_ setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
            date_ = [usDateFormat_ dateFromString:thisDate];
            isNullBool_ = NO;


        }
    }
    else
    {
        date_ = [usDateFormatNoAM_ dateFromString:thisDate];
        isNullBool_ = NO;

    }
    return self;
}

- (id)initWithPickerDate:(NSDate *)thisDate
{
    date_ = thisDate;
    return self;
}

- (id)initWithMSString:(NSString *)thisDate
{
    // assume is database format - any other format requires a special call
    // Formatter configuration
    //   NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    //  [formatter setLocale:posix];
    
    
    
    if ([thisDate length] > 24)         // means odd dash thing on end
    {
        thisDate = [thisDate substringToIndex:[thisDate length ]-6];
    }
    
    // Could be slash format - which will be american style (months first...)
    if ([thisDate rangeOfString:@"/"].location != NSNotFound)
    {
        date_ = [usDateFormat_ dateFromString:thisDate];
        if (date_ == nil)
        {
            // try without AM/PM
            date_ = [usDateFormatNoAM_ dateFromString:thisDate];
            isNullBool_ = NO;

        }
    }
    else
    {
        date_ = [msDateFormat_ dateFromString:thisDate];
        isNullBool_ = NO;

    }
    
    return self;
}


- (void)setTimeWithNSString:(NSString *)time;
{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *dateComponents = [calendar components:( NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay ) fromDate:date_];
    
    NSDate *timeDate = [timeFormat_ dateFromString:time];
    
    NSDateComponents *timeComponents = [calendar components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:timeDate];
    
    [dateComponents setHour:[timeComponents hour]];
    [dateComponents setMinute:[timeComponents minute]];
    [dateComponents setSecond:[timeComponents second]];
    
    date_ = [calendar dateFromComponents:dateComponents]; // New Date with My "Year" "Month" "Date" "Hours" "Minutes" and "Seconds"
    isNullBool_ = NO;

}

- (BOOL)equalsDate:(BaseDate *)otherDate
{
    NSString *thisdate = [self getDatabaseDate];
    NSString *other = [otherDate getDatabaseDate];
    
    return [thisdate caseInsensitiveCompare:other] == NSOrderedSame;
}

- (BOOL)equalsDateTime:(BaseDate *)otherDate
{
    return [[self getDatabaseDateTime] isEqual :[otherDate getDatabaseDateTime]];
}

- (BOOL)isGreaterThan:(BaseDate *)compareDate
{
    BOOL returnValue = NO;
    
    if ([date_ timeIntervalSinceDate:compareDate.date] > 0)
    {
        returnValue = YES;
    }
    return returnValue;
}

- (BOOL)isLessThan:(BaseDate *)compareDate
{
    BOOL returnValue = NO;
    
    if ([date_ timeIntervalSinceDate:compareDate.date] < 0)
    {
        returnValue = YES;
    }
    return returnValue;
}

- (BOOL)isGreaterThanOrEquals:(BaseDate *)inDate
{
    return [self isGreaterThan:inDate] || [self equalsDateTime:inDate];
}

- (BOOL)isLessThanOrEquals:(BaseDate *)inDate
{
    return [self isLessThan:inDate] || [self equalsDateTime:inDate];
}

- (BOOL)isGreaterThanOrEqualsIgnoreTime:(BaseDate *)dateFrom
{
    BaseDate *thisDate = [[BaseDate alloc] initWithNSString:[self getDatabaseDate]];
    BaseDate *dateFromDate = [[BaseDate alloc] initWithNSString:[dateFrom getDatabaseDate]];
    
    return [thisDate isGreaterThan : dateFromDate] || [thisDate equalsDateTime : dateFromDate];
}

- (BOOL)isLessThanOrEqualsIgnoreTime:(BaseDate *)dateFrom
{
    BaseDate *thisDate = [[BaseDate alloc] initWithNSString:[self getDatabaseDate]];
    BaseDate *dateFromDate = [[BaseDate alloc] initWithNSString:[dateFrom getDatabaseDate]];
    
    return [thisDate isLessThan : dateFromDate] || [thisDate equalsDateTime : dateFromDate];
}

- (BOOL)isGreaterThanIgnoreTime:(BaseDate *)dateFrom
{
    BaseDate *thisDate = [[BaseDate alloc] initWithNSString:[self getDatabaseDate]];
    BaseDate *dateFromDate = [[BaseDate alloc] initWithNSString:[dateFrom getDatabaseDate]];
    
    return [thisDate isGreaterThan : dateFromDate];
}

- (BOOL)isLessThanIgnoreTime:(BaseDate *)dateFrom
{
    BaseDate *thisDate = [[BaseDate alloc] initWithNSString:[self getDatabaseDate]];
    BaseDate *dateFromDate = [[BaseDate alloc] initWithNSString:[dateFrom getDatabaseDate]];
    
    return [thisDate isLessThan : dateFromDate];
}

- (NSString *)getDatabaseDateTime
{
    if ([self isNull])
    {
        return @"";
    }
    return [databaseDateTimeFormat_ stringFromDate:date_];
}

- (NSString *)getDisplayDateTime
{
    if ([self isNull])
    {
        return @"";
    }
    return [displayDateTimeFormat_ stringFromDate:date_];
}

- (NSString *)getDisplayTime
{
    if ([self isNull])
    {
        return @"";
    }
    return [displayTimeFormat_ stringFromDate:date_];
}

- (NSString *)getDisplayDate
{
    if ([self isNull])
    {
        return @"";
    }
    return [displayDateFormat_ stringFromDate:date_];
}

- (NSString *)getDatabaseDate
{
    if ([self isNull])
    {
        return @"";
    }
    return [databaseDateFormat_ stringFromDate:date_];
}

- (NSString *)logDate
{
    return [logDateFormat_ stringFromDate:date_];
}

- (NSString *)getDayMonth
{
    if ([self isNull])
    {
        return @"";
    }
    return [dayMonthFormat_ stringFromDate:date_];
}

- (NSString *)getMSDatasetDate
{
    if ([self isNull])
    {
        return @"";
    }
    return [msDateFormat_ stringFromDate:date_];
}

- (NSString *)timingDate
{
    if ([self isNull])
    {
        return @"";
    }
    return [timingDateFormat_ stringFromDate:date_];
}

- (void)addDays:(long)number
{
    NSCalendar *calendar = [[NSCalendar alloc]
                            initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    [components setDay:number];
    date_ = [calendar dateByAddingComponents:components
                                      toDate:date_
                                     options:0];
}

- (long)getHours
{
    NSCalendar *calendar = [[NSCalendar alloc]
                            initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit units = NSCalendarUnitHour;
    NSDateComponents *components = [calendar components:units fromDate:date_];
    
    return [components hour];
}

- (long)getDifferenceInMinutes:(BaseDate *)otherDate
{
    NSTimeInterval interval = [date_ timeIntervalSinceDate:otherDate.date];
    
    return interval / 60;         // to get to minutes
}

- (BOOL)isNull
{
    if (date_ == nil)
    {
        return YES;
    }
    return [self isNullBool];
}

+ (BaseDate *)getIndefinateFutureDate
{
    return BaseDate_INDEFINATE_FUTURE_DATE_;
}

+ (BaseDate *)getIndefinatePastDate
{
    return BaseDate_INDEFINATE_PAST_DATE_;
}

+ (BaseDate *)getNullDate
{
    BaseDate *returnDate = [[BaseDate alloc]init];
    
    returnDate.isNullBool = YES;
    return returnDate;
}

- (void)initialise
{
    isNullBool_ = NO;
}

+ (void)initialize
{
    if (self == [BaseDate class])
    {
        databaseDateFormat_ = [[NSDateFormatter alloc] init];
        [databaseDateFormat_ setDateFormat:@"y-MM-dd"];
        NSLocale* formatterLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"] ;
        [databaseDateFormat_ setLocale:formatterLocale]; // This forces 24 hour clock
        
        databaseDateTimeFormat_ = [[NSDateFormatter alloc] init];
        [databaseDateTimeFormat_ setDateFormat:@"y-MM-dd HH:mm:ss"];
        [databaseDateTimeFormat_ setLocale:formatterLocale];
        
        databaseOtherDateTimeFormat_ = [[NSDateFormatter alloc] init];
        [databaseOtherDateTimeFormat_ setDateFormat:@"y-MM-dd hh:mm:ss a"];
        
        displayDateFormat_ = [[NSDateFormatter alloc] init];
        [displayDateFormat_ setDateFormat:@"dd MMM y"];
        
        displayTimeFormat_ = [[NSDateFormatter alloc] init];
        [displayTimeFormat_ setDateFormat:@"HH:mm"];
        [displayTimeFormat_ setLocale:formatterLocale];

        displayDateTimeFormat_ = [[NSDateFormatter alloc] init];
        [displayDateTimeFormat_ setDateFormat:@"dd MMM y  HH:mm"];
        [displayDateTimeFormat_ setLocale:formatterLocale];

        timeFormat_ = [[NSDateFormatter alloc] init];
        [timeFormat_ setDateFormat:@"HH:mm:ss"];
        [timeFormat_ setLocale:formatterLocale];

        logDateFormat_ = [[NSDateFormatter alloc] init];
        [logDateFormat_ setDateFormat:@"y-MM-dd HH-mm-ss"];
        
        dayMonthFormat_ = [[NSDateFormatter alloc] init];
        [dayMonthFormat_ setDateFormat:@"dd MMM"];
        
        
        timingDateFormat_ = [[NSDateFormatter alloc] init];
        [timingDateFormat_ setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        usDateFormat_ = [[NSDateFormatter alloc] init];
        [usDateFormat_ setDateFormat:@"M/d/yyyy hh:mm:ss a"];
        
     //   [usDateFormat_ setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        
        usDateFormatNoAM_ = [[NSDateFormatter alloc] init];
        [usDateFormatNoAM_ setDateFormat:@"M/d/yyyy HH:mm:ss"];
    //    [usDateFormatNoAM_ setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        
        msDateFormat_ = [[NSDateFormatter alloc] init];
        [msDateFormat_ setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
        
        
        BaseDate_INDEFINATE_FUTURE_DATE_ = [[BaseDate alloc] initWithNSString:@"2500-01-01"];
        BaseDate_INDEFINATE_PAST_DATE_ = [[BaseDate alloc] initWithNSString:@"1901-01-01"];
    }
}
-(double) getJulianDate
{
    return [date_ timeIntervalSince1970];
}
-(NSString *)description
{
    return [self getDatabaseDateTime];
}
-(BaseDate*)copy
{
    BaseDate *returnDate = [[BaseDate alloc]init];
    returnDate.date = [date_ copy];
    returnDate.isNullBool = isNullBool_;
    return returnDate;
}
@end

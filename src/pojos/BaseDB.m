

#include "BaseDB.h"
#include "BaseDate.h"
#include "BaseList.h"
#include "DBInterface.h"
#include "PHLogger.h"
#include "AppDelegate.h"
#include "sqlite3.h"
#import <objc/runtime.h>


@implementation BaseDB

static NSMutableDictionary *BaseDB_TableDefHash_;
static NSMutableDictionary *BaseDB_primaryKeyHash_;
static NSMutableDictionary *BaseDB_allFields_;

static NSMutableDictionary  *getterNames;


@synthesize tableName = tableName_;
@synthesize primaryKey = primaryKey_;


+ (NSMutableDictionary *)TableDefHash
{
	return BaseDB_TableDefHash_;
}

+ (void)setTableDefHash:(NSMutableDictionary *)TableDefHash
{
	BaseDB_TableDefHash_ = TableDefHash;
}

+ (NSMutableDictionary *)primaryKeyHash
{
	return BaseDB_primaryKeyHash_;
}

+ (void)setPrimaryKeyHash:(NSMutableDictionary *)primaryKeyHash
{
	BaseDB_primaryKeyHash_ = primaryKeyHash;
}

+ (NSMutableDictionary *)allFields
{
	return BaseDB_allFields_;
}

+ (void)setAllFields:(NSMutableDictionary *)allFields
{
	BaseDB_allFields_ = allFields;
}


- (void)delete__WithLongInt:(long)keyValue
{
	NSString *deleteStatement = [NSString stringWithFormat:@"delete from %@ where %@ = %li", tableName_, primaryKey_, keyValue];

    
    [DBInterface executeUpdateWithNSString:deleteStatement];
        
}

- (long)insertWithJavaUtilHashMap
{
    NSString *StatementSQL = @"";
    
    StatementSQL = [self getInsertStatementWithJavaUtilHashMapWithDatabase:nil];

    [DBInterface executeUpdateWithNSString:StatementSQL];
    
    return [self getPrimaryKey];
}
- (long)insertWithJavaUtilHashMapWithDatabase:(sqlite3 *)database
{
    NSString *StatementSQL = @"";
    
    StatementSQL = [self getInsertStatementWithJavaUtilHashMapWithDatabase:database];
    
    
    [DBInterface executeUpdateWithNSString:StatementSQL withLogBoolean:YES withDatabase:database];
            
     
    return [self getPrimaryKey];
}



- (long)getKeyValueWithDatabase:(sqlite3*)  database
{
    
    if ([self getPrimaryKey] > 0)
    {
        return [self getPrimaryKey]; // might already be set
    }
	 long KeyValue = 1;


	NSString *getKeyValue = [NSString stringWithFormat:@"select max(%@) + 1 from %@", primaryKey_, tableName_];
    sqlite3_stmt *stmt;
    if (database != nil)
    {
        stmt = [DBInterface executeQueryWithNSString:getKeyValue withDatabase:database] ;
    }
    else
    {
        stmt = [DBInterface executeQueryWithNSString:getKeyValue];
    }
    

        while (sqlite3_step(stmt) == SQLITE_ROW)
            KeyValue = sqlite3_column_int(stmt, 0);

    if (database == nil)
    {
        [DBInterface closeResultSet:stmt];
    }
    else
    {
        [DBInterface closeResultSetKeepLock:stmt];
    }
        
    if (KeyValue == 0)
    {
        KeyValue = 1; // never use zero
    }
   
	return KeyValue +1;
}

- (NSString *)getInsertStatementWithJavaUtilHashMapWithDatabase:(sqlite3*)database
{
	NSString *insertSQL = @"";
	NSString *valuesSQL = @"";
	NSString *StatementSQL = @"";
	long KeyValue = 0;
	NSString *firstComma = @"";

	insertSQL = [NSString stringWithFormat:@"%@%@", insertSQL, [NSString stringWithFormat:@"insert into %@ (", tableName_]];
	valuesSQL = [NSString stringWithFormat:@"%@ values (", valuesSQL];
	if ([primaryKey_ length] > 0)
	{
		insertSQL = [NSString stringWithFormat:@"%@%@", insertSQL, primaryKey_];
		KeyValue = [self getKeyValueWithDatabase:database];
        [PHLogger debugLogWithNSString:@"Got val" withException:nil withInt:5];
		[BaseDB_primaryKeyHash_ setValue:[NSNumber numberWithLong:KeyValue] forKey:tableName_];
		valuesSQL = [NSString stringWithFormat:@"%@%@", valuesSQL, [NSNumber numberWithLong:KeyValue]];
		
		firstComma = @",";
	}
    
    [PHLogger debugLogWithNSString:@"Got val 1" withException:nil withInt:5];

	NSMutableDictionary *scratchHash = [self getTableDefWithNSString:tableName_];
    [PHLogger debugLogWithNSString:@"Got val 2" withException:nil withInt:5];

	for (NSString* Column in [scratchHash allKeys])
	{
		NSString *Type = (NSString *)[scratchHash objectForKey : Column];
		id Value = nil;
		if ([[Column lowercaseString]isEqualToString : [primaryKey_ lowercaseString]])
		{
			continue;
		}
        [PHLogger debugLogWithNSString:@"Got val 3" withException:nil withInt:5];

        Value = [self getDataFromGetterWithNSString:Column];
		

		if ([Value isKindOfClass:[NSString class]])
		{
			Value = [Value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];   // remove any single quotes as this affects insert statement
		}
        [PHLogger debugLogWithNSString:@"Got val 4" withException:nil withInt:5];

		Value = [BaseDB getFormattedValue:Value withType:Type];

		insertSQL = [NSString stringWithFormat:@"%@%@", insertSQL, [NSString stringWithFormat:@"%@%@", firstComma, Column]];
		@try
		{
			valuesSQL = [NSString stringWithFormat:@"%@%@", valuesSQL, [NSString stringWithFormat:@"%@%@", firstComma, [BaseDB formatValueWithId:Value withNSString:Type]]];
		}
		@catch (NSException *e) {
            [PHLogger debugLogWithNSString:@"Got val 5" withException:nil withInt:5];

			[PHLogger errorLogWithNSString:[NSString stringWithFormat:@"problem Formatting Data - %@ %@ %@", Column, Value, Type] withJavaLangThrowable:e];
			@throw e;
		}
        [PHLogger debugLogWithNSString:@"Got val 6" withException:nil withInt:5];

		firstComma = @",";
	}
    [PHLogger debugLogWithNSString:@"Got val 7" withException:nil withInt:5];

	insertSQL = [NSString stringWithFormat:@"%@)", insertSQL];
	valuesSQL = [NSString stringWithFormat:@"%@)", valuesSQL];
	StatementSQL = [NSString stringWithFormat:@"%@%@", insertSQL, valuesSQL];

    [PHLogger debugLogWithNSString:@"Got val 8" withException:nil withInt:5];

    [self setValue:[NSNumber numberWithLong:KeyValue] forKey:primaryKey_];
    [PHLogger debugLogWithNSString:@"Got val 9" withException:nil withInt:5];

	return StatementSQL;
}

- (id)getDataFromGetterWithNSString:(NSString *)column
{
	id returnValue = nil;
    Class clazz = [self class];
    u_int count;
    
    objc_property_t* properties = class_copyPropertyList(clazz, &count);
    
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        NSString *propNameString = [NSString  stringWithCString:propertyName encoding:NSUTF8StringEncoding] ;
        if ([[propNameString lowercaseString] isEqualToString:[column lowercaseString]])
        {
         /*   const char * type = property_getAttributes(class_getProperty([self class], "myPropertyName"));
            NSString * typeString = [NSString stringWithUTF8String:type];
            NSArray * attributes = [typeString componentsSeparatedByString:@","];
            NSString * typeAttribute = [attributes objectAtIndex:0];
            NSString * propertyType = [typeAttribute substringFromIndex:1];

            const char * rawPropertyType = [propertyType UTF8String];
*/
            returnValue = [self valueForKey:propNameString];

  /*          if (strcmp(rawPropertyType, @encode(float)) == 0)
            {
            }
            else if (strcmp(rawPropertyType, @encode(int)) == 0)
            {
                //it's an int
            }
            else if (strcmp(rawPropertyType, @encode(id)) == 0)
            {
                //id value = [self valueForKey:propNameString];
            }
            else
            {
                // According to Apples Documentation you can determine the corresponding encoding values
            }*/
        }
    }
    /*
		NSString *getterName = [NSString stringWithFormat:@"get%@%@", [[column substringToIndex: 1] uppercaseString], [column substringFromIndex : 1]];
    
		@try
		{
            SEL selector = NSSelectorFromString(getterName);
           // returnValue = [self performSelectorSafely:selector];
        
            if (returnValue == nil)
            {
                NSMethodSignature * sig = nil;
                sig = [[self class] instanceMethodSignatureForSelector:selector];
                const char* retType = [sig methodReturnType];

                NSInvocation * myInvocation = nil;
                myInvocation = [NSInvocation invocationWithMethodSignature:sig];
                [myInvocation setTarget:self];
                [myInvocation setSelector:selector];
                
                
                [myInvocation retainArguments];
                [myInvocation invoke];
                NSString *retString = [NSString stringWithFormat:@"%s", retType];
                if ([ints rangeOfString:retString].location != NSNotFound)
                {
                    long result = 0;

                    [myInvocation getReturnValue:&result];
                
                    returnValue = [NSNumber numberWithLong:result];
                }
                else
                {
                    double result = 0;
                    
                    [myInvocation getReturnValue:&result];
                    
                    returnValue = [NSNumber numberWithDouble:result];
                }
            }
            

        }
		@catch (NSException *e1) {
			[PHLogger debugLogWithNSString:[NSString stringWithFormat:@" not using getter as doesn't exist %@", [e1 debugDescription]] withInt:9];
		}
	*/
   	return returnValue;
}

- (void)updateWithJavaUtilHashMap
{
    NSString *updateSQL = [self getUpdateSQL];
   
    [DBInterface executeUpdateWithNSString:updateSQL];
   
}
- (void)updateWithJavaUtilHashMapWithDatabase:(sqlite3*)database
{
    NSString *updateSQL = [self getUpdateSQL];
     
    [DBInterface executeUpdateWithNSString:updateSQL withLogBoolean:YES withDatabase:database];

}
-(NSString *)getUpdateSQL
{
    NSString *KeyValue = nil;
    NSString *updateSQL = [NSString stringWithFormat:@"update %@ set ", tableName_];
    NSString *Comma = @"";
    NSMutableDictionary *scratchHash = [self getTableDefWithNSString:tableName_];
    for(NSString* Column in [scratchHash allKeys])
    {
        NSString *Type = (NSString *)[scratchHash objectForKey : Column];
        if ([[Column lowercaseString]isEqualToString : [primaryKey_ lowercaseString]])
        {
            
            KeyValue = [[self getDataFromGetterWithNSString:Column] description];
            
            continue;
        }
        id Value = [self getDataFromGetterWithNSString:Column];
        
        if (Value != nil)
        {
            updateSQL = [NSString stringWithFormat:@"%@%@", updateSQL, [NSString stringWithFormat:@"%@%@=%@", Comma, Column, [BaseDB formatValueWithId:Value withNSString:Type]]];
            Comma = @",";
        }
    }
    updateSQL = [NSString stringWithFormat:@"%@%@", updateSQL, [NSString stringWithFormat:@" where %@=%@", primaryKey_, KeyValue]];

    return updateSQL;
}
- (NSMutableDictionary *)getTableDefWithNSString:(NSString *)tableName
{
    
    NSMutableDictionary *scratchHash = [[BaseDB TableDefHash] objectForKey : tableName];
    
    if (scratchHash == nil)
    {
        NSString *createStatement = @"";
        NSString *line = @"";
        NSString *token = @"";
        @try
        {
            scratchHash = [[NSMutableDictionary alloc] init];
            createStatement = [self.class getCreateStatement];
            
            NSArray *lines = [createStatement componentsSeparatedByString:@","];
            
            for (int iCount=0; iCount < [lines count]; iCount++)
            {
                
                
                line = [lines objectAtIndex:iCount];
                line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                NSArray *linefields = [line componentsSeparatedByString:@" "];
                NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
                linefields = [linefields filteredArrayUsingPredicate:noEmptyStrings];
                
                token = [linefields objectAtIndex:0];
                long nextOne = 1;
                if ([[token lowercaseString] isEqual : @"create"])
                {
                    token = [linefields objectAtIndex:4];
                    nextOne = 5;
                }
                else if ([[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] hasPrefix : @"primary"] || [[line lowercaseString] hasPrefix : @"index"] || [[line lowercaseString] hasPrefix : @")"])
                {
                    break;
                }
                
                NSString *column = token;
                token = [linefields objectAtIndex:nextOne];
                NSString *value = token;
                (void)[scratchHash setObject:value forKey:column];
            }
        }
        @catch (NSException
                *e)
        {
            
            @throw e;
        }
        
        [[BaseDB TableDefHash] setObject:scratchHash forKey:tableName];
    }
    return scratchHash;
}


+ (NSString *)formatValueWithId:(id)Value
				   withNSString:(NSString *)Type
{
    NSString *returnString;
    
    if ([[Type lowercaseString] isEqualToString:@"double"] || [[Type lowercaseString] isEqualToString:@"long"])
     {
         returnString = Value;
     }
     else
     {
        returnString = [Value description];
         returnString = [returnString stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
         
         
         returnString =  [NSString stringWithFormat:@"%@%@%@", @"'", returnString, @"'"];

     }
	
  	return returnString;

}

- (NSMutableDictionary *)makeHashMap:(sqlite3_stmt *)statement
{
	NSString *column = @"";
	id data = @"";
	NSMutableDictionary *h = [[NSMutableDictionary alloc] init];
    long iCount = 1;

	@try
	{
		for (int i = 0; i < sqlite3_column_count(statement); i++)
		{
		    long colType = sqlite3_column_type(statement, i);
			id value;

			const char *col = sqlite3_column_name(statement, i);
			NSString *colName = [NSString stringWithCString:col encoding:NSUTF8StringEncoding];

			if (colType == SQLITE_TEXT)
			{
				
                value = [NSString stringWithUTF8String: (char*)sqlite3_column_text(statement,i)];

			}
			else if (colType == SQLITE_INTEGER)
			{
			    long col = sqlite3_column_int(statement, i);
				value = [NSNumber numberWithLong:col];
			}
			else if (colType == SQLITE_FLOAT)
			{
				double col = sqlite3_column_double(statement, i);
				value = [NSNumber numberWithDouble:col];
			}
			else if (colType == SQLITE_NULL)
			{
				continue;
			}
			else
			{
				NSLog(@"[SQLITE] UNKNOWN DATATYPE");
			}

			colName = [colName lowercaseString];

			[h setObject:value forKey:colName ];
		}
	}
	@catch (NSException *e) {
		NSString *msg = [NSString stringWithFormat:@"Error Setting column %ld - %@ to %@", iCount, column, data];
		[PHLogger errorLogWithNSString:msg withJavaLangThrowable:e];
		@throw e;
	}
	return h;
}


- (void)insert
{
    [self insertWithJavaUtilHashMap];
}
- (void)insertWithDatabase:(sqlite3*)database
{
    [self insertWithJavaUtilHashMapWithDatabase:database];
}


- (void)update
{
    [self updateWithJavaUtilHashMap];

}
- (void)updateWithDatabase:(sqlite3*)database
{
    [self updateWithJavaUtilHashMapWithDatabase:database];

}
- (long long)getPrimaryKey
{
    
    NSString * KeyValue = [[self getDataFromGetterWithNSString:primaryKey_] description];

    
    return [KeyValue longLongValue];
}

- (void)populateFromResultSet:(sqlite3_stmt *)statement
{

    @throw [NSException exceptionWithName:@"populating " reason: @"Your BaseDB does not have a populateFromResultSet" userInfo:nil];

    
}



- (NSString *)getTableName
{
	return tableName_;
}

- (BOOL)hasChangedWithBaseDB:(BaseDB *)oldBaseDB
{
	if ([oldBaseDB equalsWithBaseDB : self])
	{
		return YES;
	}
	return NO;
}

- (NSString *)getIdentifier
{
	return [[NSNumber numberWithLong:[self getPrimaryKey] ] description];
}

- (BOOL)isCreated
{
	if (primaryKey_ != nil && [self getPrimaryKey] != 0)
	{
		return YES;
	}
	return NO;
}


- (BOOL)equalsWithBaseDB:(BaseDB *)other
{
	return [self getPrimaryKey] == [other getPrimaryKey];
}

- (NSMutableDictionary *)getTableDef
{
	return [self getTableDefWithNSString:[self getTableName]];
}

- (id)init
{
	if (self = [super init] )
	{
		tableName_ = nil;
		primaryKey_ = nil;
	}
	return self;
}

+ (void)initialize
{
	if (self == [BaseDB class])
	{
		BaseDB_TableDefHash_ = [[NSMutableDictionary alloc] init];
		BaseDB_primaryKeyHash_ = [[NSMutableDictionary alloc] init];
		BaseDB_allFields_ = [[NSMutableDictionary alloc] init];
	}
}

- (void)copyAllPropertiesTo:(id)copy
{
	 
	BaseDB *typedCopy = (BaseDB *)copy;
	typedCopy.tableName = tableName_;
	typedCopy.primaryKey = primaryKey_;
}

+ (NSString *)getFormattedValue:(NSObject *)value withType:(NSString *)type
{
	if ([type rangeOfString:@"date"].location != NSNotFound)
	{
		// date

		BaseDate *thisDate = (BaseDate *)value;
		NSString *stringvalue = [thisDate getDatabaseDateTime ];
		return [NSString stringWithFormat:@"%@%@%@", @"", stringvalue, @""];
	}

	return [NSString stringWithFormat:@"%@%@%@", @"", value, @""];
}

+(long)getInt:(sqlite3_stmt *)statement withInt:(int)row
{
    return sqlite3_column_int(statement, row);
}
+(double)getDouble:(sqlite3_stmt *)statement withInt:(int)row
{
    return sqlite3_column_double(statement, row);
}

+(NSString *)getString:(sqlite3_stmt *)statement withInt:(int)row
{
    if (sqlite3_column_text(statement, row) != nil)
    {
        return [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, row)];
    }
    else
    {
        return @"";
    }
}

+(BaseDate*)getDate:(sqlite3_stmt *)statement withInt:(int)row
{
    if (sqlite3_column_text(statement, row) != nil)
    {
        return [[BaseDate alloc] initWithNSString:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, row)]];
    }
    else
    {
        BaseDate *returnDate = [[BaseDate alloc ]init];
        returnDate.date = [BaseDate getNullDate].date.copy;
        returnDate.isNullBool = YES;
        return returnDate;
    }
}
-(NSString *)getValueForKey:(NSString *) key
{
    NSString *returnValue;
    @try
    {
        returnValue=[self valueForKey:key];
    }
    @catch (NSException *exception)
    {
        // dont worry if not found
    }
    return returnValue;
}
-(NSString *) description
{
    return [self getIdentifier];
}



- (void)delete__
{
    [self delete__WithLongInt:[self getPrimaryKey]];
}

+(NSString *)getCreateStatement
{
    @throw [[NSException alloc] initWithName:@"Invalid method" reason:@"Should be overwritten by inheriting class" userInfo:nil];

    return nil;
}
@end

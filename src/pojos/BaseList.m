

#include "BaseDB.h"
#include "BaseList.h"
#include "DBInterface.h"
#include "PHLogger.h"
#include "AppDelegate.h"



@implementation BaseList

@synthesize list = list_;
@synthesize exampleElement = exampleElement_;

- (NSMutableArray *)getRows
{
	return list_;
}

- (BaseDB *)getRowWithInt:(long)rowNo
{
    if ([list_ count] == 0)
    {
        return nil;
    }
	if (rowNo > [list_ count] - 1 || rowNo < 0)
	{
		return nil;
	}
	return (BaseDB *)[list_ objectAtIndex : rowNo];
}

- (long)size
{
	return [list_ count];
}

- (void)refresh
{
	(void)[self getList];
}

- (NSMutableArray *)getList
{
	if (list_ == nil)
	{
		[self populateList];
	}
	return list_;
}

- (void)populateList
{
	// can't call an abstract method
	[self doesNotRecognizeSelector:_cmd];
}

- (BaseDB *)getRowFromKeyWithLongInt:(long)key
{
	for (id baseDB in list_)
	{
		if ([baseDB getPrimaryKey] == key)
		{
			return baseDB;
		}
	}
	return nil;
}

- (BaseDB *)getRowWithNSString:(NSString *)identifier
{
	if (identifier == nil)
	{
		return nil;
	}
    
	for (id baseDB in list_)
	{
		if ([[[baseDB getIdentifier] lowercaseString] isEqual :[identifier lowercaseString]])
		{
			return baseDB;
		}
	}
	return nil;
}

- (long)getIndexWithBaseDB:(BaseDB *)item
{
	return [list_ indexOfObject : item];
}


- (void)refreshFromDB
{
	[list_ removeAllObjects];
	[self populateList];
}

- (void)delete__WithBaseDB:(BaseDB *)baseDB
{
	[baseDB delete__];
	[list_ removeObject : baseDB];
}

- (void)addWithBaseDB:(BaseDB *)tableDisplay
{
	[list_ addObject : tableDisplay];
}

- (BOOL)listContainsObjectWithBaseDB:(BaseDB *)tableDisplay
{
		return [list_ containsObject:tableDisplay];
}

- (void)clear
{
	[list_ removeAllObjects];
}

- (void)addAllWithBaseList:(BaseList *)otherList
{

    [list_ addObjectsFromArray:[otherList list]];
}

- (long)getMaxWidth
{
	long maxWidth = 0;

	if (list_ == nil)
	{
		[PHLogger debugLogWithNSString:@"Creating comphash" withInt:5];
		[self populateList];
	}
	for (id element in list_)
	{
		if ([[element getIdentifier] length] > maxWidth)
		{
			maxWidth = [[element getIdentifier] length];
		}
	}
	return maxWidth;
}

- (BaseDB *)getMaxWidthItem
{
	long maxWidth = 0;
	BaseDB *returnItem = nil;

	if (list_ == nil)
	{
		[PHLogger debugLogWithNSString:@"Creating comphash" withInt:5];
		[self populateList];
	}
	for (id element in list_)
	{
		if ([[element getIdentifier] length] > maxWidth)
		{
			maxWidth = [[element getIdentifier] length];
			returnItem = element;
		}
	}
	return returnItem;
}




- (BaseDB *)getExampleElement
{
	return exampleElement_;
}

- (id)init
{
	if (self = [super init] )
	{
		list_ = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)copyAllPropertiesTo:(id)copy
{
	 
    
	BaseList *typedCopy = (BaseList *)copy;
	typedCopy.list = list_;
	typedCopy.exampleElement = exampleElement_;
}

- (void)populateFromSQL:(NSString *)sql
{
  
            sqlite3_stmt *statement = [DBInterface executeQueryWithNSString:sql];

            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                    BaseDB *item = [[[self.exampleElement class] alloc] init];
                    if (item == nil)
                    {
                        @throw  [NSException exceptionWithName:@"Adding Item" reason: @"Your BaseList does not instantiate an exampleElement" userInfo:nil];
                    }
                    [item populateFromResultSet:statement];
                    [self addWithBaseDB:item];
            
            
            }
            
            [DBInterface closeResultSet:statement];
}
- (void)populateFromSQL:(NSString *)sql withDatabase:(sqlite3*)database
{
    
    if (database == nil)
    {
        [self populateFromSQL:sql];
        return;
    }
        sqlite3_stmt *statement = [DBInterface executeQueryWithNSString:sql withDatabase:database];
        
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            BaseDB *item = [[[self.exampleElement class] alloc] init];
            if (item == nil)
            {
                @throw [NSException exceptionWithName:@"Adding Item" reason: @"Your BaseList does not instantiate an exampleElement" userInfo:nil];
            }
            [item populateFromResultSet:statement];
            [self addWithBaseDB:item];
        }
    
    [DBInterface closeResultSetKeepLock:statement];

}
+ (BaseList *)populateListFromSQL:(NSString *)sql
{
    BaseList *list = [[[self class] alloc] init];
    
    @try
    {
        [list populateFromSQL:sql ];
    }
    @catch (NSException * e)
    {
        [PHLogger errorLog:@"error populating list" withException:e];
    }
    
    return list;}

+ (BaseList *)populateListFromSQL:(NSString *)sql withDatabase:(sqlite3*)database
{
    if (database == nil)
    {
        return [self populateListFromSQL:sql];
    }
    
	BaseList *list = [[[self class] alloc] init];

    @try
    {
        [list populateFromSQL:sql withDatabase:database];
    }
    @catch (NSException * e)
    {
        [PHLogger errorLog:@"error populating list" withException:e];
    }

	return list;
}

- (void)removeFromListWithLongInt:(long)key
{
    BaseDB *item = [self getRowFromKeyWithLongInt:key];
    
   [list_ removeObject:item];
}

@end

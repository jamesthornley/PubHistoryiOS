
#ifndef _BaseDB_H_
#define _BaseDB_H_

@class BaseDate;
@class ValidationList;

@protocol IDbAnythingChangedListener;
@protocol IDbChangeListener;

#import "sqlite3.h"
#import <Foundation/Foundation.h>

@interface BaseDB : NSObject  {
	@public
	NSString *tableName_;
    NSString *primaryKey_;
    
}

@property (nonatomic, copy) NSString *tableName;
@property (nonatomic, copy) NSString *primaryKey;


+ (NSMutableDictionary *)TableDefHash;
+ (void)setTableDefHash:(NSMutableDictionary *)TableDefHash;
+ (NSMutableDictionary *)primaryKeyHash;
+ (void)setPrimaryKeyHash:(NSMutableDictionary *)primaryKeyHash;

- (void)delete__WithLongInt:(long)keyValue;
- (long)getKeyValueWithDatabase:(sqlite3*)  database;

- (id)getDataFromGetterWithNSString:(NSString *)column;
- (NSMutableDictionary *)getTableDefWithNSString:(NSString *)tableName;
+ (NSString *)formatValueWithId:(id)Value
				   withNSString:(NSString *)Type;

- (void)insert;
- (void)update;
- (long long)getPrimaryKey;
- (void)populateFromResultSet:(sqlite3_stmt *)statement;
- (void)delete__;
- (NSString *)getTableName;
- (BOOL)hasChangedWithBaseDB:(BaseDB *)oldBaseDB;
- (NSString *)getIdentifier;
- (BOOL)isCreated;
- (BOOL)equalsWithBaseDB:(BaseDB *)other;
- (NSMutableDictionary *)getTableDef;
- (id)init;
+ (NSString *)getFormattedValue:(NSString *)value withType:(NSString *)type;

+(long)getInt:(sqlite3_stmt *)statement withInt:(int)row;
+(double)getDouble:(sqlite3_stmt *)statement withInt:(int)row;
+(NSString *)getString:(sqlite3_stmt *)statement withInt:(int)row;
-(NSString *)getValueForKey:(NSString *) key;
-(NSString *) description;
+(NSString *)getCreateStatement;
- (void)insertWithDatabase:(sqlite3*)database;
- (void)updateWithDatabase:(sqlite3*)database;

@end

#endif // _BaseDB_H_


#ifndef _BaseList_H_
#define _BaseList_H_

@class BaseDB;


#import <Foundation/Foundation.h>
#include "sqlite3.h"




@interface BaseList : NSObject  {
	@public
	NSMutableArray *list_;
	BaseDB *exampleElement_;
}

@property (nonatomic, strong) NSMutableArray *list;
@property (nonatomic, strong) BaseDB *exampleElement;

- (NSMutableArray *)getRows;
- (BaseDB *)getRowWithInt:(long)rowNo;
- (long)size;
- (void)refresh;
- (NSMutableArray *)getList;
- (void)populateList;
- (BaseDB *)getRowFromKeyWithLongInt:(long)key;
- (BaseDB *)getRowWithNSString:(NSString *)identifier;
- (long)getIndexWithBaseDB:(BaseDB *)item;
- (void)refreshFromDB;
- (void)delete__WithBaseDB:(BaseDB *)BaseDB;
- (void)addWithBaseDB:(BaseDB *)tableDisplay;
- (BOOL)listContainsObjectWithBaseDB:(BaseDB *)tableDisplay;
- (void)clear;
- (void)addAllWithBaseList:(BaseList *)otherList;
- (long)getMaxWidth;
- (BaseDB *)getMaxWidthItem;
- (void)removeFromListWithLongInt:(long)key;
- (BaseDB *)getExampleElement;
- (id)init;
- (void)populateFromSQL:(NSString *)sql;
+ (BaseList *)populateListFromSQL:(NSString *)sql;
- (void)populateFromSQL:(NSString *)sql withDatabase:(sqlite3 *)database;
+ (BaseList *)populateListFromSQL:(NSString *)sql withDatabase:(sqlite3 *)database;


@end

#endif // _BaseList_H_

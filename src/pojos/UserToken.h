//
//  UserToken.h
//  
//
//  Created by  James on 22/03/2019.
//

#import "BaseDB.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserToken : BaseDB

@property long userTokenID;
@property NSString * token;
@property NSString * uploaded;

-(NSData *)getJsonVersion;

@end

NS_ASSUME_NONNULL_END

//
//  UserTokenList.h
//  Norwich
//
//  Created by  James on 22/03/2019.
//  Copyright © 2019 CoDeveloper. All rights reserved.
//

#import "BaseList.h"
#import "UserToken.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserTokenList : BaseList

+(UserToken *)getTokenWithToken:(NSString*)token;
+(void) deleteAllTokens;
+(UserTokenList *)getUnsentTokens;


@end

NS_ASSUME_NONNULL_END

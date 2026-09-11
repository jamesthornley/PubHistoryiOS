//
//  RouteTakenList.h
//  HistoricPubCrawl
//
//  Created by  James on 19/10/2018.
//  Copyright © 2018 CoDeveloper. All rights reserved.
//

#import "BaseList.h"

NS_ASSUME_NONNULL_BEGIN

@interface RouteTakenList : BaseList

+(RouteTakenList*)getReadyToUploadList;
-(NSData *)getJsonVersion;


@end

NS_ASSUME_NONNULL_END

//
//  SendServerThread.h
//  HistoricPubCrawl
//
//  Created by  James on 10/08/2017.
//  Copyright © 2017 CoDeveloper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SendServerThread : NSObject
{
    NSMutableData *receivedData;
}

+(void)startThread;
+(void)stopThread;
+(void)doProcessing;


@end

@interface SendThread : NSThread
{
    BOOL stop;
}

- (void)run:(id)caller;
- (id)init;
- (void)stop;

@end



//
//  SendServerThread.m
//  HistoricPubCrawl
//
//  Created by  James on 10/08/2017.
//  Copyright © 2017 CoDeveloper. All rights reserved.
//

#import "SendServerThread.h"
#import "RouteTakenList.h"
#import "SendServerData.h"
#import "UserList.h"
#import "TrailList.h"
#import "UserTokenList.h"
#import "MyTrailViewController.h"
#import "Trail.h"
#import "Note.h"
#import "NoteList.h"
#import "PHLogger.h"
#import "Reachability.h"
#import "AppDelegate.h"
#import "DBInterface.h"
static SendThread *thread;
static NSString *thislock = @"lock";


@implementation SendServerThread
+(void)startThread
{
    if ([UserList isRegistered] == NO)
    {
        return; // no point in running this if not registered
    }
    if (thread == nil || [thread isCancelled] || [thread isFinished])
    {
        thread =[[SendThread alloc] init];
        NSThread* myThread = [[NSThread alloc] initWithTarget:thread
                                                     selector:@selector(run:)
                                                       object:nil];
        
        [myThread start];
        
    }
    else
    {
        // Just call the actual process immediately

      
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
             [NSThread sleepForTimeInterval:5]; // Its a bit weird but if you synchronise immediately it seems to block the main thread even if running on background thread.
            [SendServerThread doProcessing];
            
        });
    

    }
    
}
+(void)stopThread
{
    if (thread != nil)
    {
        [thread stop];
    }
}

+(void) doProcessing
{
   

    @synchronized(thislock)
    {
        @try
        {
           
            NoteList * list = [NoteList getNotUploaded];
            
            if ([list size] != 0)
            {
                for (int iCount=0; iCount<[list size]; iCount++)
                {
                    Note *note = (Note*)[list getRowWithInt:iCount];
                    if ([note isCurrentUserWithDatabase:nil] == NO)
                    {
                        if ([note isUploaded] == NO)
                        {
                                @try
                                {
                                    [SendServerData sendNoteSent:note withDatabase:nil];
                                }
                                @catch (NSException *exception)
                                {
                                    [PHLogger errorLog:@"Error sending note" withException:exception];
                                }
                        }
                        if ([note isPhotoUploaded] == NO && [note isText] == NO)
                        {
                            [SendServerData getPhotoWithNote:note withDatabase:nil];
                        }
                        if ([note isPhotoUploaded] == NO && [note isText])
                        {
                            [note setIsUploadedPhoto];
                            [note update];
                        }
                        continue;
                    }
                    
                    if ([note isUploaded] == NO && [note isCurrentUserWithDatabase:nil] )
                    {
                        [SendServerData sendNote:note];
                    }
                    
                    if ([note isPhotoUploaded] == NO && [note isText] == NO && [note isCurrentUserWithDatabase:nil] )
                    {
                        [SendServerData sendPhoto:note];
                        
                    }
                }
            }
            
            if ( [[TrailList getCurrentTrail] isGroup])
            {
                NoteList * teamnotelist = [SendServerData getTeamNotes];
                
                if ([teamnotelist size] > 0)
                {
                    sqlite3 * database = [DBInterface getDatabaseOther];

                
                        // do your database activity here
                        
                        @try
                        {
                            [DBInterface beginTransactionWithDatabase:database];
                            [teamnotelist insertAllFromServerWithDatabase:database];
                            
                            [SendServerData getTeamPhotosWithList:teamnotelist withDatabase:database];
                            [DBInterface commitTransactionWithDatabase:database];
                           
                            [DBInterface beginTransactionWithDatabase:database];
                            [teamnotelist serverReceivedFileAllWithDatabase:database];
                            [DBInterface commitTransactionWithDatabase:database];


                        }
                        @catch (NSException *exception)
                        {
                            @try
                            {
                                [PHLogger errorLog:@"Error getting notes from server" withException:exception];
                                [DBInterface rollbackTransactionWithDatabase:database];
                            }
                            @catch (NSException *exception)
                            {
                                // Do nothing, maybe nothing to roll back
                            }
                        }
                      
                    dispatch_queue_t myGlobalQueue;
                    myGlobalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    dispatch_async(myGlobalQueue, ^{
                        
                        // Some processing
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                            [appDelegate.myTrail reload];
                            [appDelegate.pubTrail reload];                        });
                    });
                    
                }
            }
            
            if ([UserList isRegistered] && [[UserTokenList getUnsentTokens] size] > 0)
            {
                [SendServerData sendUserToken:(UserToken*)[[UserTokenList getUnsentTokens] getRowWithInt:0]];
            }
            
            [SendServerData checkRouteTaken];
            
        }
        @catch (NSException *exception)
        {
            [PHLogger errorLog:@"Error in Server Thread" withException:exception];
        }
    }
}
@end
@implementation SendThread

- (void)run:(id)caller
{
    while (YES)
    {
        
        if (stop == YES || thread != self)
        {
            break;
        }

        [SendServerThread doProcessing];
        
        [NSThread sleepForTimeInterval:60]; // sleep for 5
      
    }
    
    [self cancel];
}


- (id)init
{
    self = [super init];
    
    stop = NO;
    return self;
}
- (void)stop
{
    
    stop = YES;
}




@end

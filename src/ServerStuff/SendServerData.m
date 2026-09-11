//
//  SendServerData.m
//  HistoricPubCrawl
//
//  Created by  James on 09/08/2017.
//  Copyright © 2017 CoDeveloper. All rights reserved.
//

#import "SendServerData.h"
#import "RouteTakenList.h"
#import "RouteTaken.h"
#import "Note.h"
#import "UserList.h"
#import "User.h"
#import "UserToken.h"
#import "NoteList.h"
#import "Trail.h"
#import "TrailList.h"
#import "PHLogger.h"

@implementation SendServerData

+(void)sendNote:(Note *)note
{
    //   SavedParameters *savedParams = [SavedParameters currentSavedParameters];
    
    //   NSString *authStr = [NSString stringWithFormat:@"%@/%@:%@", [savedParams username], [savedParams account], [savedParams password]];
    //   NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    //   NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64Encoding]];
    
    NSString *url  = [[SendServerData getServerName] stringByAppendingString:@"/AddNoteServlet"];
    
    NSURL *urlurl = [NSURL URLWithString:url];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlurl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    
    //      NSData *requestData = [json dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //[request setValue:[SyncAction getUserAgent] forHTTPHeaderField:@"User-Agent"];
    //[request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    NSData *jsonData  = [note getJsonVersion];
    [request setHTTPBody: jsonData];
    
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData * responseData = [self sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error != nil)
    {
        
        NSLog(@"%@", error.localizedDescription);
    }
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    long code = [httpResponse statusCode];
    
    if (code == 200)
    {
        note.serverNoteID = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] intValue];
        [note setIsUploaded];
        [note update];
    
        
        if ([note isText])
        {
            [note setIsUploadedPhoto];
            [note update];
        }
    }
    
}
+(void)sendNoteSent:(Note *)note withDatabase:(sqlite3*)database
{
    //   SavedParameters *savedParams = [SavedParameters currentSavedParameters];
    
    //   NSString *authStr = [NSString stringWithFormat:@"%@/%@:%@", [savedParams username], [savedParams account], [savedParams password]];
    //   NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    //   NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64Encoding]];
    
    NSString *url  = [[SendServerData getServerName] stringByAppendingString:@"/ReceivedNoteServlet"];
    
    NSURL *urlurl = [NSURL URLWithString:url];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlurl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    
    //      NSData *requestData = [json dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //[request setValue:[SyncAction getUserAgent] forHTTPHeaderField:@"User-Agent"];
    //[request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setValue:[NSString stringWithFormat:@"%ld",note.serverNoteID ] forKey:@"noteID"];
    User *user = [UserList getCurrentUserWithDatabase:database];
    [dict setValue:[NSString stringWithFormat:@"%ld",user.userID ] forKey:@"userID"];
    
    NSError *error = nil;
    
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    
    if (error != nil)
    {
        @throw [NSException exceptionWithName:@"Creating json note" reason:[error localizedDescription] userInfo:dict];
    }
    
    [request setHTTPBody: jsonData];
    
    
    NSURLResponse *response = nil;
    error = nil;
     [self sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error != nil)
    {
        
        NSLog(@"%@", error.localizedDescription);
    }
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    long code = [httpResponse statusCode];
    
    if (code == 200)
    {
        [note setIsUploaded ];
        [note updateWithDatabase:database];
        
    }
}

+(void) sendPhoto:(Note*) note
{
    NSDictionary *params = @{@"noteID"     : [NSString stringWithFormat:@"%ld",note.serverNoteID]};
    
    NSString * fileName = [NSString stringWithFormat:@"%ld.jpg",note.serverNoteID];
    if ([SendServerData sendFile:[note getActualFilenameWithDatabase:nil]   sendName:fileName withParams:params])
    {
        [note setIsUploadedPhoto ];
        [note update];
    }
}
+(Boolean) sendFile:(NSString*) filePath sendName:(NSString*)sendName withParams:(NSDictionary *)params
{
    NSString *url  = [[SendServerData getServerName] stringByAppendingString:@"/ReceiveFileServlet"];

    NSURL *theURL = [NSURL URLWithString:url];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                          timeoutInterval:20.0f];
    [theRequest setHTTPMethod:@"POST"];
    
    // define post boundary...
    NSString *boundary = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *boundaryString = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [theRequest addValue:boundaryString forHTTPHeaderField:@"Content-Type"];
    
    
    // define boundary separator...
    NSString *boundarySeparator = [NSString stringWithFormat:@"--%@\r\n", boundary];
    
    //adding the body...
    NSMutableData *postBody = [NSMutableData data];
    
    
    
    [params enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    // if file is defined, upload it...
    if (filePath)
    {
        
        NSData *fileContent = [NSData dataWithContentsOfFile:filePath options:0 error:nil];
        
        [postBody appendData:[boundarySeparator dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uploadedfile\"; filename=\"%@\"\r\n", sendName] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n"
                              dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:fileContent];
        
        
    }
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r \n",boundary]
                          dataUsingEncoding:NSUTF8StringEncoding]];
    [theRequest setHTTPBody:postBody];
    
    NSURLResponse *theResponse = NULL;
    NSError *theError = NULL;
    [self sendSynchronousRequest:theRequest
                                returningResponse:&theResponse
                                error:&theError];
    
    if (theError != nil)
    {
        
        NSLog(@"%@", theError.localizedDescription);
    }
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)theResponse;
    long code = [httpResponse statusCode];
    
    if (code == 200)
    {
        return YES;
    }
    
    return NO;
}
+(NSString *)getServerName
{
  //  return @"http://localhost:8080/PubHistory";
    return @"https://www.pubhistoryaletrails.co.uk";
}
+(NoteList *) getTeamNotes
{
    
    NSString *url  = [[SendServerData getServerName] stringByAppendingString:@"/GetNotesServlet"];
    
    NSURL *theURL = [NSURL URLWithString:url];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                          timeoutInterval:20.0f];
    [theRequest setHTTPMethod:@"POST"];
    
    User * user = [UserList getCurrentUser]; // Note that database isn't needed because this is not called within a transaction
    
    NSString *parameter = [NSString stringWithFormat:@"userID=%ld&trailID=%ld",user.userID, [TrailList getCurrentTrail].trailID ];
    NSData *parameterData = [parameter dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    
    
    [theRequest setHTTPBody:parameterData];
    
    NSURLResponse *theResponse = NULL;
    NSError *theError = NULL;
    NSData *reqResults = [self sendSynchronousRequest:theRequest
                                               returningResponse:&theResponse
                                                           error:&theError];
    
    NoteList * list ;

    if (reqResults != nil)
    {
    
        list = [NoteList getFromJson:reqResults];
    }
    
    return list;

}
+(void) getTeamPhotosWithList:(NoteList * )list withDatabase:(sqlite3 *)database
{

    for (Note * note in list.list)
    {
        if ([note isText ] == NO)
        {
            
            [self getPhotoWithNote:note withDatabase:database];
        
        }
    }
    
}
+(void)getPhotoWithNote:(Note*)note withDatabase:(sqlite3 *)database
{
    NSString *url  = [[SendServerData getServerName] stringByAppendingString:@"/GetPhotoServlet"];
    NSURL *theURL = [NSURL URLWithString:url];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                          timeoutInterval:20.0f];
    [theRequest setHTTPMethod:@"POST"];
    
    User * user = [UserList getCurrentUserWithDatabase:database];
    
    NSString *parameter = [NSString stringWithFormat:@"noteID=%ld&username=%@&password=%@",note.serverNoteID,user.username,user.password];
    NSData *parameterData = [parameter dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    [theRequest setHTTPBody:parameterData];
    
    NSURLResponse *theResponse = NULL;
    NSError *theError = NULL;
    NSData *reqResults = [self sendSynchronousRequest:theRequest
                                    returningResponse:&theResponse
                                                error:&theError];
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)theResponse;
    long code = [httpResponse statusCode];
    
    if (code == 200)
    {
        NSString *actualFileName = [note getActualFilenameWithDatabase:database];
        
        [reqResults writeToFile:actualFileName atomically:NO];
        
        [note setIsUploadedPhoto ];
        [note updateWithDatabase:database];
    }
    else
    {
        [PHLogger errorLog:[NSString stringWithFormat:@"Error getting photos %ld %@",code,[httpResponse description]] withException:nil];
    }
    
}
+(long)amendTrail:(Trail *)trail
{
    //   SavedParameters *savedParams = [SavedParameters currentSavedParameters];
    
    //   NSString *authStr = [NSString stringWithFormat:@"%@/%@:%@", [savedParams username], [savedParams account], [savedParams password]];
    //   NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    //   NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64Encoding]];
    
    NSString *url  = [[SendServerData getServerName] stringByAppendingString:@"/AmendTrailServlet"];
    
    NSURL *urlurl = [NSURL URLWithString:url];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlurl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    
    //      NSData *requestData = [json dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //[request setValue:[SyncAction getUserAgent] forHTTPHeaderField:@"User-Agent"];
    //[request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    NSData *jsonData  = [trail getJsonVersion];
    [request setHTTPBody: jsonData];
    
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    [self sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error != nil)
    {
        
        NSLog(@"%@", error.localizedDescription);
    }
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    long code = [httpResponse statusCode];
    
    return code;
    
}
+(NSString*)startTrail:(Trail *)trail
{
    
    NSString *url  = [[SendServerData getServerName] stringByAppendingString:@"/StartTrailServlet"];
    NSURL *theURL = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theURL
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                          timeoutInterval:20.0f];
    [request setHTTPMethod:@"POST"];
    
    
    NSData *jsonData  = [trail getJsonVersion];
    
    [request setHTTPBody: jsonData];
    
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData * responseData = [self sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error != nil)
    {
        NSLog(@"%@", error.localizedDescription);
    }
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    long code = [httpResponse statusCode];
    
    NSString *responseStr;

    if (code == 200)
    {
        responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];

        if ([self isStringNumeric:responseStr ])
        {
            trail.trailID = [responseStr integerValue];
            [trail insert];
            responseStr = nil;
        }
        
    }
    else
    {
        
        responseStr = @"Something went wrong, couldn't send data to www.pubhistoryaletrails.co.uk";
        [PHLogger errorLog:responseStr withException:nil];
        [PHLogger errorLog:[NSString stringWithFormat:@"%ld",code ] withException:nil];
        [PHLogger errorLog:[NSHTTPURLResponse description]  withException:nil];
    }
    
    
    return responseStr;
}
+ (BOOL)isStringNumeric:(NSString *)text
{
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:text];
    return [alphaNums isSupersetOfSet:inStringSet];
}
+(NSString *)registerUser:(User*)user
{
    // NOTE THAT IF THEY REGISTER AGAIN THE TOKEN WILL NEED TO BE SENT AGAIN

    NSString *url  = [[SendServerData getServerName] stringByAppendingString:@"/RegisterServlet"];
    
    NSURL *urlurl = [NSURL URLWithString:url];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlurl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    
    //      NSData *requestData = [json dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSData *jsonData  = [user getJsonVersion];
    [request setHTTPBody: jsonData];
    
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData * responseData = [self sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error != nil)
    {
        
        NSLog(@"%@", error.localizedDescription);
    }
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    long code = [httpResponse statusCode];
    
    NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];

    if (code == 200)
    {

        NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        if ([responseStr rangeOfCharacterFromSet:notDigits].location == NSNotFound)
        {
            [user setStrServerUserID:responseStr];
            [user insert];
            responseStr = @"";
            
        }
        
    }
    else if ([responseStr length] == 0)
    {
        responseStr = @"Internet Issue";
    }
    
    return responseStr;
  
}
// Needs to be called every ten minutes or so
+(void)sendRouteTaken:(RouteTakenList*) routeTakenList
{
    NSString *url  = [[SendServerData getServerName] stringByAppendingString:@"/RouteTakenServlet"];
    
    NSURL *urlurl = [NSURL URLWithString:url];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlurl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    //      NSData *requestData = [json dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //[request setValue:[SyncAction getUserAgent] forHTTPHeaderField:@"User-Agent"];
    //[request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    NSData *jsonData  = [routeTakenList getJsonVersion];
    [request setHTTPBody: jsonData];
    
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    [self sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error != nil)
    {
        NSLog(@"%@", error.localizedDescription);
    }
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    long code = [httpResponse statusCode];
    
    if (code == 200)
    {
        for (RouteTaken * route in [routeTakenList getList])
        {
            [route setUploaded];
            [route update];
        }
    }
    
    return ;
}
+(void)checkRouteTaken
{
    RouteTakenList * routeTakenList = [RouteTakenList getReadyToUploadList];
    if ([routeTakenList size] > 0)
    {
        [SendServerData sendRouteTaken:routeTakenList];
    }
}

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request
                 returningResponse:(__autoreleasing NSURLResponse **)responsePtr
                             error:(__autoreleasing NSError **)errorPtr
{
    dispatch_semaphore_t    sem;
    __block NSData *        result;
    
    result = nil;
    
    sem = dispatch_semaphore_create(0);
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                         if (errorPtr != NULL) {
                                             *errorPtr = error;
                                         }
                                         if (responsePtr != NULL) {
                                             *responsePtr = response;
                                         }
                                         if (error == nil) {
                                             result = data;
                                         }
        NSLog(@"End url ");

                                         dispatch_semaphore_signal(sem);
                                     }] resume];
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    NSLog(@"Continue ");

    return result;
}
+(void)sendUserToken:(UserToken*) userToken
{
    NSString *url  = [[SendServerData getServerName] stringByAppendingString:@"/RegisterTokenServlet"];
    
    NSURL *urlurl = [NSURL URLWithString:url];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlurl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    //      NSData *requestData = [json dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //[request setValue:[SyncAction getUserAgent] forHTTPHeaderField:@"User-Agent"];
    //[request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    NSData *jsonData  = [userToken getJsonVersion];
    [request setHTTPBody: jsonData];
    
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    [self sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error != nil)
    {
        NSLog(@"%@", error.localizedDescription);
    }
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    long code = [httpResponse statusCode];
    
    if (code == 200)
    {
        userToken.uploaded = @"Y";
        [userToken update];
    }
    
    return ;
}
@end

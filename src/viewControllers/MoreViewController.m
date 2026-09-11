//
//  MoreViewController.m
//

#import "MoreViewController.h"
#import "PubListController.h"
#import "Pub.h"
#import "PubFactory.h"
#import "SystemVariables.h"
#import "AppDelegate.h"
#import "GPSLocation.h"
#import "BaseDate.h"
#import "SendServerData.h"
#import "PHLogger.h"
#import "AppDelegate.h"
#import "PubFactory.h"
#import "DBInterface.h"
#import "UserList.h"
#import "User.h"
#import "TrailList.h"
#import "GenericWebViewController.h"
#import "HelpViewController.h"
#import "SendServerThread.h"

@implementation MoreViewController


- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    
    if ([sender isKindOfClass:[AppDelegate class]])
    {
        PubListController* cvc = segue.destinationViewController;
                
        GPSLocation *gpsLocation = [GPSLocation getInstance];
        
        cvc.selectedPoi = gpsLocation.currentPub;
        cvc.poiSelected = YES;
    }
    
        
    if ([segue.destinationViewController isKindOfClass:[GenericWebViewController class]])
    {
        GenericWebViewController* cont = segue.destinationViewController;
        NSString *filename =[segue identifier];
        [cont setFileName:filename];
    }
      
    if ([segue.destinationViewController isKindOfClass:[HelpViewController class]])
    {
        HelpViewController* cont = segue.destinationViewController;
        NSString *ident =[segue identifier];
        
        if ([ident isEqualToString:@"help"])
        {
            cont.url = @"help/mobile";
        }
        else if ([ident isEqualToString:@"viewTrail"])
        {
            cont.url = @"/login.jsp";
        }
        else
        {
            cont.url = @"feedback/Feedback.jsp";
            [self sendTheLogfile];
            [self sendDatabase:nil];
        }
    }
       
    
    [SendServerThread startThread];

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int returnID = 9;
    
    if ([UserList isRegistered] == NO)
    {
        returnID++;
    }
    
    if ([SystemVariables getValueForName:[GPSLocation GPS_OFF]] != nil && [SystemVariables getValueForName:[GPSLocation GPS_OFF]].length > 0)
    {
        returnID++;
    }
    return returnID;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    long choice = indexPath.row;
    
    if ([UserList isRegistered] && choice > 2)
    {
        choice++;
    }
    
    switch ( choice)
    {
        case 0 :
            CellIdentifier = @"returnToTrailsList";
            break;
     
        case 1 :
            CellIdentifier = @"introduction";
            break;
     
        case 2:
            if ([TrailList onTrail])
            {
                CellIdentifier = @"endTrail";
            }
            else
            {
                CellIdentifier = @"startTrail";
            }
            break;
            
        case 3:
            CellIdentifier = @"register";
            break;
        case 4:
            CellIdentifier = @"viewTrail";
            break;
              
        case 5:
            CellIdentifier = @"sponsors";
            break;
 
        case 6:
            CellIdentifier = @"acknowledgements";
            break;
            
        case 7:
            CellIdentifier = @"bibliography";
            break;
            
        case 8:
            CellIdentifier = @"help";
            break;
            
        case 9:
            CellIdentifier = @"feedback";
            break;
            
        case 10:
            CellIdentifier = @"turnGPSOn";
            break;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier forIndexPath: indexPath];
 
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    if (indexPath.row == 2 && [TrailList onTrail])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Info"
                                                                       message:@"Have you finished the Trail?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action)
                                        {
                                            [self.sendingView setHidden:NO];
                                            
                                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                                                
                                                @try
                                                {
                                    
                                                
                                                    // Do your background work here
                                                    Trail *trail = [TrailList getCurrentTrail];
                                                    [trail endTrail];
                                                    
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        
                                                        
                                                        
                                                        [PHLogger showMessage:@"You have completed the Trail, well done, we hope you enjoyed it. \n\nLook in the app store for more Pub History Ale Trails or go to the website \n\nwww.pubhat.co.uk\n\nHere you can view your trail as well as seeing what other trails are available." withViewContoller:self];
                                                      
                                                        
                                                        [self.table reloadData];
                                                        [self.sendingView setHidden:YES];
                                                        
                                                    });
                                                }
                                                @catch (NSException *exception)
                                                {
                                                    [PHLogger errorLog:@"Error ending" withException:exception];
                                                }
                                            });
                                            
                                        }];
        
        UIAlertAction* otherAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action)
                                      {
                                          // Do nothing
                                      }];
        [alert addAction:defaultAction];
        [alert addAction:otherAction];
        [self presentViewController:alert animated:YES completion:nil];
    }

    
    
    if (indexPath.row == 6)
    {
        [self sendDatabase:self];
        [self sendTheLogfile];
        
    }
    if (indexPath.row == 0)
    {
        [self dismissViewControllerAnimated:YES completion:nil];

    }

    if (indexPath.row == 10)
       {
           [SystemVariables removeVariableForName:[GPSLocation GPS_OFF]];
           [[GPSLocation getInstance] startInPubLocation];
           [PHLogger showMessage:@"GPS turned on" withViewContoller:self];
           [tableView reloadData];
       }
   
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
- (void)viewDidAppear:(BOOL)animated
{
    [_table reloadData];
    [super viewDidAppear:animated];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self tableView:self.table didSelectRowAtIndexPath:indexPath];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:Nil];
    GenericWebViewController* webView = [storyboard instantiateViewControllerWithIdentifier:@"genericWebView"];
    [webView setFileName:@"intro"];

    [self.navigationController pushViewController:webView animated:YES];
    
    [self.navigationController.navigationBar setValue:@(YES) forKeyPath:@"hidesShadow"];

    [self setTitle:@"More"];
    
    [self.sendingView setHidden:YES];



}

-(void)sendTheLogfile
{
        
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(backgroundQueue, ^
                   {
                       NSString *url = @"http://www.freelance-programmer.co.uk/freelance/ReceiveFileServlet";
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
                       
                       NSString *filePath=[PHLogger getFileName];
                       
                       // if file is defined, upload it...
                       if (filePath)
                       {
                           User *user = [UserList getCurrentUser];
                           //   NSArray *split = [filePath componentsSeparatedByString:@"/"];
                           //    NSString *fileName = (NSString*)[split lastObject];
                           BaseDate *date =[[BaseDate alloc] init];
                           NSString *sendName = [@"PP" stringByAppendingFormat:@"%@%f",user.username,[date getJulianDate]];
                           sendName = [sendName stringByReplacingOccurrencesOfString:@" " withString:@""];
                           
                           NSData *fileContent = [NSData dataWithContentsOfFile:filePath options:0 error:nil];
                           
                           [postBody appendData:[boundarySeparator dataUsingEncoding:NSUTF8StringEncoding]];
                           [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"audioBody\"; filename=\"%@\"\r\n", sendName] dataUsingEncoding:NSUTF8StringEncoding]];
                           [postBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n"
                                                 dataUsingEncoding:NSUTF8StringEncoding]];
                           [postBody appendData:fileContent];
                       }
                       [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r \n",boundary]
                                             dataUsingEncoding:NSUTF8StringEncoding]];
                       [theRequest setHTTPBody:postBody];
                       
                    
        [[[NSURLSession sharedSession] dataTaskWithRequest:theRequest completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {


        }] resume];

                   });
    
}

- (IBAction)sendDatabase:(id)sender
{
    
    [self.sendingView setHidden:NO];
                       
    NSString *filePath=[DBInterface getDatabaseName];
    User *user = [UserList getCurrentUser];

    BaseDate *date =[[BaseDate alloc] init];
    NSString *sendName = [@"QQ" stringByAppendingFormat:@"%@%f",user.username,[date getJulianDate]];
    sendName = [sendName stringByReplacingOccurrencesOfString:@" " withString:@""];
                       
    [self sendFile:filePath sendName:sendName ];
    
}
-(void) sendFile:(NSString*) filePath sendName:(NSString*)sendName
{
    NSString *url = @"http://www.freelance-programmer.co.uk/freelance/ReceiveFileServlet";
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
    
    
    
    // if file is defined, upload it...
    if (filePath)
    {
        
        NSData *fileContent = [NSData dataWithContentsOfFile:filePath options:0 error:nil];
        
        [postBody appendData:[boundarySeparator dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"audioBody\"; filename=\"%@\"\r\n", sendName] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n"
                              dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:fileContent];
        
        
    }
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r \n",boundary]
                          dataUsingEncoding:NSUTF8StringEncoding]];
    [theRequest setHTTPBody:postBody];
    
   
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:theRequest
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.sendingView setHidden:YES];

                });
            }] resume];
    
    
}

-(void)start
{
    [self performSegueWithIdentifier:@"start"
                          sender:self];
}
@end

//
//  MyTrailViewController.m
//  HistoricPubCrawl
//
//  Created by  James on 31/07/2017.
//  Copyright © 2017 CoDeveloper. All rights reserved.
//

#import "MyTrailViewController.h"
#import "NoteList.h"
#import "Note.h"
#import "UserList.h"
#import "PHLogger.h"
#import "Pub.h"
#import "BaseDate.h"
#import "NotesListCellTableViewCell.h"
#import "SectionHeadingTableViewCell.h"
#import "PubTabViewController.h"
#import "GPSLocation.h"
#import "PHAleTrail.h"
#import "PHAleTrailFactory.h"
#import "AppConfiguration.h"
#import "AppDelegate.h"
#import "SendServerThread.h"
#import "TeamList.h"
#import "TrailList.h"
#import "MoreViewController.h"


@interface MyTrailViewController ()

@end

@implementation MyTrailViewController

- (void)viewDidLoad
{
  
    [super viewDidLoad];
    self.text.layer.borderColor = [[UIColor grayColor] CGColor];
    self.text.layer.borderWidth = 1.0;
    self.text.layer.cornerRadius = 8;
    
    
    defaultBottomTextEntry = self.bottomTextEntry.constant;
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    appeared = NO;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self scrollToEnd];

    appeared = YES;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];


    if ([self.parentViewController isKindOfClass:PubTabViewController.class])
        {
        
            PubTabViewController *controller = (PubTabViewController*)self.parentViewController;
            pub = controller.pub;
            noteList = [NoteList getNoteListWithUserID:[UserList getCurrentUser].userID withPubID:[[pub getNumber ] integerValue]];
            [noteList sort];


            [_myViewheader setHidden:YES];
            _tableTopConstraint.constant = 0;
            appDelegate.pubTrail = self;
        }
    else
    {
        noteList = [NoteList getNoteListWithUserID:[UserList getCurrentUser].userID withTrailCode:[PHAleTrailFactory getCurrentPHAleTrail].code];
        [noteList sort];
        appDelegate.myTrail = self;

    }
    
    if ([TrailList onTrail] || [NoteList thereAreNotes])
    {
        [_startTrailView setHidden:YES];
    }
    else
    {
        [_startTrailView setHidden:NO];

    }

    [_mainTable reloadData];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}
- (UITableViewCell *)tableView:(UITableView *)ptableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = @"NoteListCellLeft";
    
    NSArray * notes = [[[noteList getSections] objectAtIndex:indexPath.section] objectAtIndex:1] ;
    Note *note = (Note*)[notes objectAtIndex:indexPath.row];

    if ([note isCurrentUserWithDatabase:nil])
    {
        CellIdentifier = @"NoteListCellRight";
    }
    
    // Set up the cell...
    
    UITableViewCell *cell = [ptableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    

    
    NotesListCellTableViewCell *pcell = (NotesListCellTableViewCell*) cell;
    [pcell setNote:note];
    if ([self.parentViewController isKindOfClass:PubTabViewController.class])
    {
        pcell.parent = (PubTabViewController*)self.parentViewController;
    }
    else
    {
        pcell.parent = self;
    }
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSArray * notes = [[[noteList getSections] objectAtIndex:indexPath.section] objectAtIndex:1] ;
    
    Note *note = (Note*)[notes objectAtIndex:indexPath.row];
    
    return [note getSize].height + 10;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[noteList getSections]count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
   
    return [[[[noteList getSections] objectAtIndex:section] objectAtIndex:1] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Pub *pub = (Pub *) [[[noteList getSections] objectAtIndex:section] objectAtIndex:0] ;

    return [pub  getTitle];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger) section
{
    
    SectionHeadingTableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"SectionHeader"];
    if (cell == nil) {
        cell = [[SectionHeadingTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:@"SectionHeader"];
    }
    Pub *pub = (Pub *) [[[noteList getSections] objectAtIndex:section] objectAtIndex:0] ;

    cell.titleLabel.text = [@" " stringByAppendingString:[pub getTitle]] ;
    
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (pub != nil)
    {
        return 0; //don't do headers if only one pub
    }
    
    return UITableViewAutomaticDimension;
}
-(IBAction) save
{
    if ([self.text.text length] == 0)
    {
        return;
    }
    else if ([TrailList onTrail] == NO)
    {
        [PHLogger showMessage:@"You must be on the Trail to add a note, please select Start Trail from 'More' menu" withViewContoller:self];
        return;
    }
    
    Note * note = [[Note alloc] init];
    note.note = self.text.text;

    GPSLocation *gpsLocation = [GPSLocation getInstance];

    if (pub == nil)
    {
        note.pubID = [[gpsLocation.currentPub getNumber] intValue];

    }
    else
    {
        note.pubID = [[pub getNumber] intValue];
    }
    
    if ( note.pubID != 0 && [[gpsLocation.currentPub getNumber] intValue] != note.pubID)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Info"
                                                                          message:@"You are not currently in this pub, do you still want to add this note to this pubs story?\n\nYou can add notes between pubs or to the current pub by adding them on the 'Trails' screen"
                                                                   preferredStyle:UIAlertControllerStyleAlert];

           UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                                                                         handler:^(UIAlertAction * action) {
                       [self saveNote:note];
                   }];
        
          UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                    // Do nothing...
                }];

           [alert addAction:yesAction];
           [alert addAction:noAction];
           [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        [self saveNote:note];
    }

}

-(void)saveNote:(Note*)note
{
    AppConfiguration *config = [[AppConfiguration alloc] init];

    note.appID = [config getAppID];
       note.userID = [UserList getCurrentUser].userID;
       note.teamID = [TeamList getCurrentTeam].teamID;
       note.trailID = [TrailList getCurrentTrail].trailID;
       note.noteType = [Note NOTE_TYPE_NOTE];
       
       @try
       {
           [note insert];
       }
       @catch (NSException *exception)
       {
           [PHLogger errorLog:@"Exception inserting  Note" withException:exception ];
           
       }
       [noteList addWithBaseDB:note];
       [noteList sort];

       [noteList resetSections];
       
       [_mainTable reloadData];
     

       self.text.text = @"";
       [self.view endEditing:YES];
       [SendServerThread startThread];
       [self scrollToEnd];
}
-(IBAction) takePhoto
{
    if ([TrailList onTrail] == NO)
    {
        [PHLogger showMessage:@"You must be on the Trail to take a photo, please select Start Trail from 'More' menu" withViewContoller:self];
        return;
    }
    GPSLocation *gpsLocation = [GPSLocation getInstance];

    if ( pub != nil && [[gpsLocation.currentPub getNumber] intValue] != [pub getNumber].intValue)
       {
           UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Info"
                                                                             message:@"You are not currently in this pub, do you still want to add a photo to this pubs story?\n\n You can add photos between pubs or to the current pub by taking a photo on the 'Trails' screen"
                                                                      preferredStyle:UIAlertControllerStyleAlert];

              UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                                                                            handler:^(UIAlertAction * action) {
                          [self actuallyTakePhoto];
                      }];
           
             UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault
                                                                         handler:^(UIAlertAction * action) {
                       // Do nothing...
                   }];

              [alert addAction:yesAction];
              [alert addAction:noAction];
              [self presentViewController:alert animated:YES completion:nil];
       }
    else
    {
        [self actuallyTakePhoto];
    }
   
    
}
-(void)actuallyTakePhoto
{
        UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
           
           
           // Displays a control that allows the user to choose picture or
           // movie capture, if both are available:
           
           if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
           {
               cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
           }
           else
           {
               cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
           }
           
           //  cameraUI.mediaTypes =
           // [UIImagePickerController availableMediaTypesForSourceType:
           // UIImagePickerControllerSourceTypeCamera];
           
           // Hides the controls for moving & scaling pictures, or for
           // trimming movies. To instead show the controls, use YES.
           
           cameraUI.allowsEditing = NO;
           
           cameraUI.delegate = self;
           
           [self presentViewController:cameraUI animated:YES completion:nil];
           
}

-(void)findPicture
{
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    
    
    cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    
    //  cameraUI.mediaTypes =
    // [UIImagePickerController availableMediaTypesForSourceType:
    // UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = self;
    
    [self presentViewController:cameraUI animated:YES completion:nil];
    
    
}

- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info
{
    AppConfiguration *config = [[AppConfiguration alloc] init];
    
    Note * note = [[Note alloc] init];
    if (pub == nil)
    {
        GPSLocation *gpsLocation = [GPSLocation getInstance];
        note.pubID = [[gpsLocation.currentPub getNumber] intValue];
        
    }
    else
    {
        note.pubID = [[pub getNumber] intValue];
    }
    note.appID = [config getAppID];
    note.userID = [UserList getCurrentUser].userID;
    note.teamID = [TeamList getCurrentTeam].teamID;
    note.trailID = [TrailList getCurrentTrail].trailID;
    note.noteType = [Note NOTE_TYPE_PICTURE];

    @try
    {
        [note insert];
    }
    @catch (NSException *exception)
    {
        [PHLogger errorLog:@"Exception inserting  Picture Note" withException:exception ];
        
    }
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    
    editedImage = (UIImage *) [info objectForKey:
                               UIImagePickerControllerEditedImage];
    originalImage = (UIImage *) [info objectForKey:
                                 UIImagePickerControllerOriginalImage];
    
    if (editedImage)
    {
        imageToSave = editedImage;
    } else
    {
        imageToSave = originalImage;
    }
    
    // resize it
    CGSize imageSize;
    imageSize.height = [config getPhotoHeight];
    imageSize.width = [config getPhotoWidth];
    
    imageToSave = [MyTrailViewController scaleImage:imageToSave toSize:imageSize];
    
    // Save the new image (original or edited) to the app directory
    NSData* imageData = UIImageJPEGRepresentation(imageToSave, 1.0);
        
    @try
    {
        [note update];
    }
    @catch (NSException *exception)
    {
        [PHLogger errorLog:@"Exception updating  Note" withException:exception ];
        
    }
    NSString *actualFileName = [note getActualFilenameWithDatabase:nil];
    
    [imageData writeToFile:actualFileName atomically:NO];
    
    //   answer_ = [imageToSave ]
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [noteList addWithBaseDB:note];
    [noteList sort];

    [noteList resetSections];
  

    [_mainTable reloadData];
    [self.view endEditing:YES];
    
    [self scrollToEnd];
   [SendServerThread startThread];

}

+ (UIImage*) scaleImage:(UIImage*)image toSize:(CGSize)newSize
{
    
    if (image == nil)
    {
        return nil;
    }
    CGSize scaledSize = newSize;
    float scaleFactor = 1.0;
    if( image.size.width > image.size.height )
    {
        scaleFactor = image.size.width / image.size.height;
        scaledSize.width = newSize.width;
        scaledSize.height = newSize.height / scaleFactor;
    }
    else
    {
        scaleFactor = image.size.height / image.size.width;
        scaledSize.height = newSize.height; // biggest side
        scaledSize.width = newSize.width / scaleFactor;
    }
    
    UIGraphicsBeginImageContextWithOptions( scaledSize, NO, 1.0 );
    CGRect scaledImageRect = CGRectMake( 0.0, 0.0, scaledSize.width, scaledSize.height );
    [image drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}
-(NSString *)getFileName:(Note *)note
{
    
    NSString *fileName;
    BaseDate *date = [[BaseDate alloc] init];
    fileName = [NSString stringWithFormat:@"%ld%f.jpg" , [note userID],[date getJulianDate]];
    
    
    return fileName;
}
// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
            
    long movement = kbSize.height;
    
    
    if (movement > 0  && self.bottomTextEntry.constant == defaultBottomTextEntry) // in case user tabs as this gets called again
    {
        
        self.bottomTextEntry.constant = movement;
        
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    
    [self.view layoutIfNeeded];
}


// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    
    self.bottomTextEntry.constant = defaultBottomTextEntry;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    
}
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    UITapGestureRecognizer * gest = (UITapGestureRecognizer *)sender;
    UIView* view = gest.view;
    CGPoint loc = [gest locationInView:view];
    UIView* subview = [view hitTest:loc withEvent:nil];
    
    if ([subview isKindOfClass:[UIButton class]] == false)
    {
        [self.view endEditing:YES];
        
    }
}
-(IBAction)reload
{
    bool scroll = NO;
 

    if (_mainTable != nil && appeared && _mainTable.contentOffset.y + 1 >= _mainTable.contentSize.height - _mainTable.frame.size.height)
    {
        scroll = YES; // only scroll more if already at bottom and this screen is showing
    }
    if (pub != nil)
    {
        noteList = [NoteList getNoteListWithUserID:[UserList getCurrentUser].userID withPubID:[[pub getNumber ] integerValue]];
    }
    else
    {
        noteList = [NoteList getNoteListWithUserID:[UserList getCurrentUser].userID  withTrailCode:[PHAleTrailFactory getCurrentPHAleTrail].code];
    }
    
    [noteList sort];
    [_mainTable reloadData];
    
    if (scroll)
    {
        [self scrollToEnd];
    }
}
-(void)scrollToEnd
{
    if ([noteList size] > 1 && [noteList getSections] > 0)
    {
       
        @try
        {
            NSArray * notes = [[[noteList getSections] objectAtIndex:[[noteList getSections] count ]-1] objectAtIndex:1] ;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[notes count]-1 inSection:[[noteList getSections] count] - 1];
            
            [_mainTable scrollToRowAtIndexPath:indexPath atScrollPosition:0 animated:YES];
        }
        @catch (NSException *exception)
        {
            [PHLogger errorLog:@"Error mytrail scrolling to end" withException:exception];
        }

        
    }

}
-(IBAction) start
{
    [self.tabBarController setSelectedIndex:4 ];
    UINavigationController *nav = [[self.tabBarController viewControllers] objectAtIndex:4];
    MoreViewController *cont = [[nav viewControllers] objectAtIndex:0];
    [cont start];
}
@end

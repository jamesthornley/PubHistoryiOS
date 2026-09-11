//
//  MyTrailViewController.h
//  HistoricPubCrawl
//
//  Created by  James on 31/07/2017.
//  Copyright © 2017 CoDeveloper. All rights reserved.
//

#import "BaseViewController.h"
#import "NoteList.h"
#import "Pub.h"

@interface MyTrailViewController : BaseViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    NoteList *noteList;
    Pub* pub;

    Boolean appeared;

}

@property (nonatomic) IBOutlet UITextView *text;
@property (nonatomic) IBOutlet UIView *myViewheader;
@property (nonatomic) IBOutlet UIView *startTrailView;
@property (nonatomic) IBOutlet NSLayoutConstraint *tableTopConstraint;

-(IBAction) save;
-(IBAction) takePhoto;
@property (nonatomic) IBOutlet UITableView *mainTable;
+ (UIImage*) scaleImage:(UIImage*)image toSize:(CGSize)newSize;
-(IBAction)reload;
-(IBAction) start;

@end

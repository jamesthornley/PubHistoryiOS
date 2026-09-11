//
//  PoiListController.m
//  audiotrails
//
//  Created by James Thornley on 12/08/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PubListController.h"
#import "PubFactory.h"
#import "Pub.h"
#import "PubListCell.h"
#import "GPSLocation.h"
#import "PubTabViewController.h"
#import "AppDelegate.h"
#import "PHAleTrailFactory.h"
#import "PHAleTrail.h"
#import "SystemVariables.h"

@implementation PubListController
@synthesize localTableView;
@synthesize  poiSelected,selectedPoi;



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    poiArray = [[PHAleTrailFactory getCurrentPHAleTrail]  getPubs];
    
    PHAleTrail *phTrail = [PHAleTrailFactory getCurrentPHAleTrail] ;

    
    [self.view setBackgroundColor:[SystemVariables colorFromHexString:phTrail.backgroundColour]];

    
        
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (poiSelected && selectedPoi != nil)
    {
        poiSelected = NO;
        [self performSegueWithIdentifier:@"poi"
                                  sender:self];
    }
    
    
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    
	return [poiArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"PoiListCell";
	
    // Set up the cell...
	Pub* pub= [poiArray objectAtIndex:indexPath.row ];
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
  //   = tableView.dequeueReusableCellWithIdentifier (CellIdentifier);
 	
	PubListCell *pcell = (PubListCell*) cell;
    [pcell setPub:pub];
    
	return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [poiArray count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    Pub* pub= [poiArray objectAtIndex:indexPath.row ];
   
    PubListCell *pcell = (PubListCell*) cell;
    [pcell setPub:pub];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger numberOfColumns = 3;
    
    CGFloat itemWidth = (CGRectGetWidth(collectionView.frame) - 20) / numberOfColumns;
    
    
    CGFloat itemHeight = 1.5 * itemWidth;
    return CGSizeMake(itemWidth, itemHeight);
    
    
}
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
 	selectedPoi = [poiArray objectAtIndex:indexPath.row ];
  
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:Nil];
    PubTabViewController* pubScene = [storyboard instantiateViewControllerWithIdentifier:@"CurrentPubScene"];
    pubScene.selectedPub= selectedPoi;

    [self.navigationController pushViewController:pubScene animated:YES];
    
	//[self performSegueWithIdentifier:@"pub"
		//					  sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
	 PubTabViewController *controller = (PubTabViewController *)segue.destinationViewController;
    controller.selectedPub= selectedPoi;
}


- (void)viewWillAppear:(BOOL)animated
 {
     [super viewWillAppear:animated];
     
     PHAleTrail *aleTrail = [PHAleTrailFactory getCurrentPHAleTrail];
     NSString *title = [NSString stringWithFormat:@"%@ Pubs",aleTrail.title];
     [localTableView reloadData];
     [self.screenTitle setText:title];
     
     // This means distances will be updated
     GPSLocation *gpsLocation = [GPSLocation getInstance];
     gpsLocation.pubController = self;
 }
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    // This means distances will be updated
    GPSLocation *gpsLocation = [GPSLocation getInstance];
    gpsLocation.pubController = nil; // Will no longer update whilst not in view, saving energy
}
-(IBAction) back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)refresh
{
    [localTableView reloadData];
}

@end

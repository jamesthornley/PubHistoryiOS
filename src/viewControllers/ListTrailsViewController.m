//
//  ListTrailsViewController.m
//  London
//
//  Created by  James on 21/03/2021.
//  Copyright © 2021 CoDeveloper. All rights reserved.
//

#import "ListTrailsViewController.h"
#import "PHAleTrailCell.h"
#import "PHAleTrailFactory.h"
#import "PHAleTrail.h"
#import "MainTabViewViewController.h"


@implementation ListTrailsViewController 

- (void)viewDidLoad
{
    [super viewDidLoad];

    pHAleTrailArray = [PHAleTrailFactory getPHAleTrailArray];
        
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UITableViewCell *)tableView:(UITableView *)ptableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"TrailCell";
    
    // Set up the cell...
    
    UITableViewCell *cell = [ptableView dequeueReusableCellWithIdentifier:CellIdentifier];
    PHAleTrail* pHAleTrail= [pHAleTrailArray objectAtIndex:indexPath.section ];
   
    
    PHAleTrailCell *pcell = (PHAleTrailCell*) cell;
    pcell.phAleTrail = pHAleTrail;
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [pHAleTrailArray count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    selectedTrail = [pHAleTrailArray objectAtIndex:indexPath.section ];
    [PHAleTrailFactory setCurrentPHAleTrailCode:selectedTrail];

    //[self performSegueWithIdentifier:@"pub"
    //                      sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MainTabViewViewController *controller = (MainTabViewViewController *)segue.destinationViewController;
    controller.selectedTrail = selectedTrail;
   
}



@end

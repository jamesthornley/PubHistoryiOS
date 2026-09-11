//
//  PoiListController.h
//  audiotrails
//
//  Created by James Thornley on 12/08/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pub.h"
#import "BaseViewController.h"

@interface PubListController : BaseViewController  <UICollectionViewDelegate,UICollectionViewDataSource>
{
	UICollectionView *localTableView  ;

    NSArray * poiArray;
}
@property (nonatomic, retain) IBOutlet  UICollectionView *localTableView;;
@property (nonatomic) BOOL poiSelected;
@property (nonatomic) Pub *selectedPoi;

-(void)refresh;


@end

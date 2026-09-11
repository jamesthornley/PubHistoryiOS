//
//  BaseViewController.h
//  RevealControllerStoryboardExample
//
//  Created by  James on 07/02/2014.
//  Copyright (c) 2014 CoDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Pub.h"

@interface BaseViewController : UIViewController<UIGestureRecognizerDelegate,UIScrollViewDelegate>
{
    BOOL dontAddButton;
     Pub*nearestmedia ;
    UINavigationItem* _navBar;
    
    UITapGestureRecognizer *singleFingerTap;

    float previousScale;
    long defaultBottomTextEntry;
    long defaultTopTextEntry;
    long textBoxYCoord;
    long textBoxHeight;

}


@property (nonatomic, retain) IBOutlet UIImageView *verticalBar;
@property (nonatomic) IBOutlet UINavigationItem* navBar;
@property (nonatomic, retain) IBOutlet  UIImageView *fullImageView;
@property (nonatomic, retain) IBOutlet  UIView *fullImageContainerView;
@property (nonatomic) IBOutlet UIScrollView *fullImageScrollView;
@property (nonatomic) IBOutlet NSLayoutConstraint *bottomTextEntry;
@property (nonatomic) IBOutlet NSLayoutConstraint *topTextEntry;
@property (nonatomic) IBOutlet NSLayoutConstraint *topBarTop;
@property (nonatomic) IBOutlet NSLayoutConstraint *topBarHeight;
@property (nonatomic) IBOutlet UIStackView *textEntry;
@property (nonatomic, retain) IBOutlet  UILabel *screenTitle;
@property (nonatomic, retain) IBOutlet  UIView *titleBar;


+(BaseViewController *)getInstance;
-(void)newLocation:(CLLocation *)location;

@end

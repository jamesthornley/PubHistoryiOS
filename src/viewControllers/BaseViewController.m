//
//  BaseViewController.m
//  RevealControllerStoryboardExample
//
//  Created by  James on 07/02/2014.
//  Copyright (c) 2014 CoDeveloper. All rights reserved.
//

#import "BaseViewController.h"
#import "PubFactory.h"
#import "TrailList.h"
#import "PHAleTrail.h"
#import "SystemVariables.h"
#import "PHAleTrailFactory.h"

@implementation BaseViewController 
static BaseViewController * instance;


@synthesize navBar = _navBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

  
    return self;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    instance = self;// therefore will always be the current one displayed
    
    singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(tapAction:)];
    [self.fullImageView addGestureRecognizer:singleFingerTap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];

  
    
    if (@available(iOS 11.0, *))
    {
        if (self.view.window.safeAreaInsets.top > 0.0)
        {
            self.topBarHeight.constant = self.topBarHeight.constant + 30;
            self.topBarTop.constant = 35;
        }
    }
   
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification  object:nil];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    instance = self;
    [self.fullImageContainerView setHidden:YES];
    
    [self setFullImageSize:self.view.frame.size];
    defaultBottomTextEntry = self.bottomTextEntry.constant;
    defaultTopTextEntry = self.topTextEntry.constant;
   
    PHAleTrail *phTrail = [PHAleTrailFactory getCurrentPHAleTrail] ;

    if(self.titleBar != nil)
    {
        [self.titleBar setBackgroundColor:[SystemVariables colorFromHexString:phTrail.backgroundColour]];

    }
    
   
   
}
+(BaseViewController *)getInstance
{
    return instance;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate
{
    // forcing the rotate IOS6 Only
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)newLocation:(CLLocation *)location
{
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.fullImageView;
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    // Do view manipulation here.
    
    [self setFullImageSize:size];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}
-(void)setFullImageSize:(CGSize)size
{
    CGSize scrollableSize = CGSizeMake(size.width, size.height);
    [self.fullImageScrollView setContentSize:scrollableSize];
    self.fullImageView.frame = CGRectMake(0, 0, size.width, size.height);
}

- (void)tapAction:(UITapGestureRecognizer *)sender
{
    [[self fullImageContainerView ]setHidden:YES];

    [self.fullImageView setTransform:CGAffineTransformIdentity] ;
  //  [self.fullImageScrollView reloadInputViews];
    [self setFullImageSize:self.view.frame.size];
    [self.self.fullImageScrollView setZoomScale:1.0f];


}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(double)scale
{
    CGPoint contentOffset = [self.fullImageScrollView contentOffset];
    CGSize  contentSize   = [self.fullImageScrollView contentSize];
    CGSize  containerSize = [self.fullImageView frame].size;
    
    self.fullImageScrollView.maximumZoomScale = self.fullImageScrollView.maximumZoomScale / scale;
    self.fullImageScrollView.minimumZoomScale = self.fullImageScrollView.minimumZoomScale / scale;
    
    previousScale *= scale;
    
    [self.fullImageScrollView setZoomScale:1.0f];
    
    [self.fullImageScrollView setContentOffset:contentOffset];
    [self.fullImageScrollView setContentSize:contentSize];
    [self.fullImageView setFrame:CGRectMake(0, 0, containerSize.width, containerSize.height)];
    
}
// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    
    textBoxYCoord = self.textEntry.frame.origin.y;
    textBoxHeight = self.textEntry.frame.size.height;
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    long neededY = [UIScreen mainScreen].bounds.size.height - kbSize.height;
    
    long movement = (textBoxYCoord + textBoxHeight) - neededY ;
    
        if (movement > 0)
        {
        self.bottomTextEntry.constant = defaultBottomTextEntry + movement;
        self.topTextEntry.constant = defaultTopTextEntry - movement;
        
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
    self.topTextEntry.constant = defaultTopTextEntry;

    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
@end

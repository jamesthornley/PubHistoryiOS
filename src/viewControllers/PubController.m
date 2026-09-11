//
//  PoiController.m
//  audiotrails
//
//  Created by James Thornley on 16/01/2001.
//  Copyright 2001 __MyCompanyName__. All rights reserved.
//

#import "PubController.h"

#import "Pub.h"
#import "PubFactory.h"
#import "MapViewController.h"
#import "AppConfiguration.h"
#import "AppDelegate.h"
#import "PubTabViewController.h"



@implementation PubController

@synthesize mainWebView;

@synthesize landscapeImageView,portraitImageView;

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}




//viewDidLoad method declared in RootViewController.m
- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    mainWebView.navigationDelegate = self;

   
    
	
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    PubTabViewController *controller = (PubTabViewController*)self.parentViewController;
    self.pub= controller.pub;
    self.fullImageView = controller.fullImageView;
    self.fullImageContainerView = controller.fullImageContainerView;

	self.title = [self.pub getTitle];
	

    // 1. Load header content from pub_header.html
    NSString *headerPath = [[NSBundle mainBundle] pathForResource:@"content/pub_header" ofType:@"html"];
    NSString *headerContent = [NSString stringWithContentsOfFile:headerPath encoding:NSUTF8StringEncoding error:nil];
    
    // 1.5. Load header content from pub_header.html
    NSString *footerPath = [[NSBundle mainBundle] pathForResource:@"content/pub_footer" ofType:@"html"];
    NSString *footerContent = [NSString stringWithContentsOfFile:footerPath encoding:NSUTF8StringEncoding error:nil];
 
    // 2. Generate the dynamic Swiper slides - this will search for all image types
    NSString *baseImageName =  [self.pub getPhotoPrefix];
    NSMutableString *slidesHTML = [NSMutableString string];
    
    NSInteger index = 1;
    BOOL fileExists = YES;
    while (fileExists)
    {
        NSString *imageNameWithoutExtension = [NSString stringWithFormat:@"content/%@_%ld", baseImageName, (long)index];
        
        NSArray *fileExtensions = @[@"jpg", @"jpeg",@"png", @"gif"];
        BOOL foundImage = NO;
        
        for (NSString *extension in fileExtensions) {
            NSString *imageNameWithExtension = [imageNameWithoutExtension stringByAppendingPathExtension:extension];
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageNameWithExtension ofType:nil];

          
            if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
            {
        
                NSString *descriptionPath = [[NSBundle mainBundle] pathForResource:imageNameWithoutExtension ofType:@"txt"];
                NSString *descriptionContent = [NSString stringWithContentsOfFile:descriptionPath encoding:NSUTF8StringEncoding error:nil];

                
                NSString *slide = [NSString stringWithFormat:@"<div class=\"swiper-slide\"><a href=\"%@\"><img class=\"swipe_image\" src=\"%@\"/></a><p>%@</p></div>", imageNameWithExtension, imageNameWithExtension,descriptionContent];
                [slidesHTML appendString:slide];
                index++;
                foundImage = YES;
                break; // break out of the fileExtensions loop since we found a match
            }
        }
        
        if (!foundImage) {
            fileExists = NO;
        }
    }

    
    // 3. Load the footer/content from white_lion.html
    NSString *filename = [NSString stringWithFormat:@"content/%@", [self.pub getFilePrefix]];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"html"];
    NSString *fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    // 4. Combine them and load the resulting HTML
    NSString *fullHTML = [NSString stringWithFormat:@"%@ <div class=\"swiper-container\"> <div class=\"swiper-wrapper\"> %@  </div><br><div class=\"swiper-pagination\"></div></div><script src=\"content/js/initialise_swiper.js\"></script> %@%@", headerContent, slidesHTML, fileContent,footerContent];
    
    [mainWebView loadHTMLString:fullHTML baseURL:[[NSBundle mainBundle] bundleURL]];

 
}
-(IBAction) visited
{
    [self.pub setVisited];
    [[self menuView] setHidden:NO];
    
}

-(IBAction) directions
{
    CLLocationCoordinate2D callLocation = [[self.pub getLocation] coordinate];

    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:callLocation
                                                   addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem setName:[self.pub getTitle]];
    
    // Set the directions mode to "Driving"
    // Can use MKLaunchOptionsDirectionsModeWalking instead
    NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey :   MKLaunchOptionsDirectionsModeDriving };
    // Get the "Current User Location" MKMapItem
    MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
    // Pass the current location and destination map items to the Maps app
    // Set the direction mode in the launchOptions dictionary
    [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem]
                   launchOptions:launchOptions];

    [[self menuView] setHidden:YES];

}

-(IBAction) menu
{

    if ([[self menuView ] isHidden])
    {
        [[self menuView] setHidden:NO];
    }
    else{
        [[self menuView] setHidden:YES];

    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    	MapViewController *controller = (MapViewController *)segue.destinationViewController;
    
	controller.selectedPoi = self.pub;
    
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}



- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if ([navigationAction.request.URL.absoluteString  rangeOfString:@"jpg"].location != NSNotFound
        ||  [navigationAction.request.URL.absoluteString  rangeOfString:@"png"].location != NSNotFound
        ||  [navigationAction.request.URL.absoluteString  rangeOfString:@"jpeg"].location != NSNotFound
        || [navigationAction.request.URL.absoluteString  rangeOfString:@"gif"].location != NSNotFound)
    {
        NSString *imageString = [NSString stringWithFormat:@"%@/%@",[AppConfiguration getContentFolder],[navigationAction.request.URL.absoluteURL lastPathComponent]];
        UIImage *image =[UIImage imageWithContentsOfFile:imageString];
        [self.fullImageView setImage:image];
        
        [self.fullImageContainerView setHidden:NO];
        
        decisionHandler(WKNavigationActionPolicyCancel);
        
        return;

    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}


-(BOOL)shouldAutorotate
{
    // forcing the rotate IOS6 Only
    return YES;
}


@end

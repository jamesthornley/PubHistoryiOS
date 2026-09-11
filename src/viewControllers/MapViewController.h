//
//  MapViewController.h
//  audiotrails
//
//  Created by James Thornley on 01/01/2001.
//  Copyright 2001 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "Pub.h"
#import "BaseViewController.h"


@interface Annotation : NSObject <MKAnnotation>
{
    Pub	*pub;
}

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property  Pub	*pub;

-(Annotation*) initWithPoi: (Pub*)pPub;

@end

@interface MapViewController : BaseViewController <MKMapViewDelegate>
{
    
    MKMapView *mapView;
    
    UIScrollView * scrollView;
    UIView *imageViewer;
    CLLocationManager *locManager;
    UIBarButtonItem *locationBarItem;
    UIImageView *currentLocation;
    
}

@property  IBOutlet MKMapView *mapView;

@property  IBOutlet UIView *imageViewer;
@property IBOutlet UIScrollView * scrollView;
@property IBOutlet UIButton * locationButton;
@property  Pub*selectedPoi;

-(void)poiSelected:(id) sender;
-(IBAction)mapSelectedAction:(id) sender;

- (void) didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
-(IBAction)myLocationAction;
-(IBAction) back;

@end

@interface MapAnnovationView : MKAnnotationView


@end



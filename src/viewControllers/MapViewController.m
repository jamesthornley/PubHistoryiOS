//
//  MapViewController.m
//  audiotrails
//
//  Created by James Thornley on 01/01/2001.
//  Copyright 2001 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "PubFactory.h"
#import "Pub.h"
#import "IntroPub.h" //<MKMapViewDelegate>
#import "MapHelper.h"
#import "SystemVariables.h"
#import "TrailList.h"
#import "PubTabViewController.h"
#import "PHAleTrailFactory.h"
#import "Route.h"

#import "AppDelegate.h"

@implementation MapAnnovationView


@end

@implementation Annotation

- (NSString *)title
{
        return @" ";
}

-(Annotation*) initWithPoi: (Pub*)ppub
{
    pub= ppub;
    return self;
}


@synthesize  coordinate;
@synthesize  pub;

@end



@implementation MapViewController
@synthesize mapView;

@synthesize imageViewer;
@synthesize scrollView;
@synthesize selectedPoi;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    if (selectedPoi != nil)
    {
        dontAddButton = YES;
    }
    [super viewDidLoad];
    
    //location button
    
    UIImage *buttonImage = [UIImage imageNamed:@"location-icon.png"];
    
    //create a UIBarButtonItem with the button as a custom view
    
    locationBarItem = [[UIBarButtonItem alloc] initWithImage:buttonImage style:UIBarButtonItemStyleDone target:self action:@selector(myLocationAction)];
    
    
    //map helper stuff
    
    mapView.mapType = MKMapTypeStandard;
    mapView.delegate = self;
    mapView.showsUserLocation = YES;
    
    Route *route = [[PHAleTrailFactory getCurrentPHAleTrail]  getRoute];

    MKPolyline *routeOverlay = [route getRoute];

    if (routeOverlay != nil)
    {
        [mapView addOverlay:routeOverlay];
        
    }
    

    [self moveMap];

}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [mapView removeAnnotations:[mapView annotations]];
    
    Pub*pub = [[PHAleTrailFactory getCurrentPHAleTrail]  getNextPub];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];

    if (appDelegate.resetMap && pub != nil)
    {
        [self moveMap];
        appDelegate.resetMap = NO;
    }
    
    if (selectedPoi == nil )
    {
        [self setupAnnotations];
    }
    else if (selectedPoi != nil)
    {
        [self addPoi:selectedPoi];
    }
    
    if ( [TrailList onTrail] == NO)
       {
           if (locManager == nil )
           {
              locManager=[[CLLocationManager alloc] init];
              locManager.activityType = CLActivityTypeFitness;
              locManager.distanceFilter = 5;
              
              if ([locManager respondsToSelector:@selector(requestAlwaysAuthorization)])
              {
                  [locManager requestAlwaysAuthorization];
              }
              [locManager setAllowsBackgroundLocationUpdates:YES];
              [locManager setPausesLocationUpdatesAutomatically:NO];
              [locManager setShowsBackgroundLocationIndicator:YES];


          }
          locManager.desiredAccuracy=kCLLocationAccuracyBest;
          
          [locManager startUpdatingLocation];
       }
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [locManager stopUpdatingLocation];
}

-(void)moveMap
{
    CLLocationCoordinate2D location;
        
        MKCoordinateRegion region;
        MKCoordinateSpan span;
        span.latitudeDelta=0.01;
        span.longitudeDelta=0.01;
        
        if (selectedPoi == nil )
        {
            Pub*pub = [[PHAleTrailFactory getCurrentPHAleTrail]  getNextPub];
            location =[pub getLocation].coordinate;

            region.span=span;
            region.center=location;
            
            [mapView setRegion:region animated:TRUE];
        }
        else if (selectedPoi != nil)
        {
            location = [[selectedPoi getLocation] coordinate];
            
            region.span=span;
            region.center=location;
            
            [mapView setRegion:region animated:TRUE];
            [mapView regionThatFits:region];
            
        }
       
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id ) annotation
{
    if ([annotation class] == MKUserLocation.class)
    {
        return nil;
    }
    
    Pub *pub = [annotation pub];
    
    MapAnnovationView *annView=[[MapAnnovationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
    
    UIButton *advertButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    
    advertButton.frame = CGRectMake(0, 10, 20, 20);
    advertButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    advertButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    [advertButton setBackgroundImage:[UIImage imageNamed:@"arrow.png"] forState:UIControlStateNormal];
    [advertButton addTarget:self action:@selector(poiSelected:) forControlEvents:UIControlEventTouchUpInside];

    NSString * number  = [pub getNumber];
    advertButton.tag = [number intValue];
    
    UIImage * mapIcon  = [pub getMapIcon];
    UIImage * pubIcon = [pub getIcon];
    
    if (pubIcon == nil)
    {
        pubIcon = mapIcon;
    }
    
    UIButton *frontButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    CGSize constraint = CGSizeMake(300,NSUIntegerMax);
    NSDictionary *attributes = @{NSFontAttributeName: [[frontButton titleLabel] font]};
    
    NSString *titleBit = [pub getTitle];
    
    CGRect rect = [titleBit boundingRectWithSize:constraint
                                         options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                      attributes:attributes
                                         context:nil];
    
    frontButton.frame = CGRectMake(0, 0, rect.size.width + 40, 35);
    frontButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    frontButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    frontButton.tag = [number intValue];
    [frontButton setTitle:titleBit forState:UIControlStateNormal];
    [frontButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [frontButton addTarget:self action:@selector(poiSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    imageView1.center = CGPointMake(10, frontButton.frame.size.height / 2);
    imageView1.contentMode = UIViewContentModeScaleAspectFit;
    imageView1.image = pubIcon;
    [frontButton addSubview:imageView1];
    
    annView.leftCalloutAccessoryView = frontButton;
    
    
    annView.image = mapIcon;

    
    annView.canShowCallout = YES;
    annView.calloutOffset = CGPointMake(0, 0);
    annView.centerOffset = CGPointMake(0, 0);
    
    Pub *nextPub = [[PHAleTrailFactory getCurrentPHAleTrail]  getNextPub];
    
    if ([pub isEqual:nextPub]) // make it thumping
    {
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.duration = 0.5;
        scaleAnimation.repeatCount = HUGE_VAL;
        scaleAnimation.autoreverses = YES;
        scaleAnimation.fromValue = [NSNumber numberWithFloat:1.1];
        scaleAnimation.toValue = [NSNumber numberWithFloat:0.9];

        
        [annView.layer addAnimation:scaleAnimation forKey:@"animateSize"];
    }
    return annView;
}



- (void)didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    
    if (currentLocation.hidden == YES)
    {
        currentLocation.hidden = NO;
    }
    
}
-(MKPolylineRenderer *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay
{

    MKPolylineRenderer *polylineView = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    
    polylineView.strokeColor =  [UIColor redColor];   // applying line-width
    polylineView.lineWidth = 2.0;
    polylineView.alpha = 1.0;
    
    return polylineView;
}

-(void)poiSelected:(id) sender
{
    
        
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:Nil];
    PubTabViewController* pubScene = [storyboard instantiateViewControllerWithIdentifier:@"CurrentPubScene"];
    
    PHAleTrail *trail = [PHAleTrailFactory getCurrentPHAleTrail];
    pubScene.selectedPub = [trail getPubFromNumber:[sender tag]];

    [self.navigationController pushViewController:pubScene animated:YES];
}


-(IBAction)mapSelectedAction:(id) sender
{
    if (mapView.mapType == MKMapTypeHybrid)
    {
        mapView.mapType = MKMapTypeStandard;
        
        
    }
    else if (mapView.mapType == MKMapTypeStandard)
    {
        mapView.mapType = MKMapTypeSatellite;
        
        
    }
    else if (mapView.mapType == MKMapTypeSatellite)
    {
        mapView.mapType = MKMapTypeHybrid;
        
        
    }
    
    
}

-(IBAction)myLocationAction{
    //Creates a 2D coordinate and sets it to the user's current lat/long
    //Centers the map to those coordinates and zooms to an appropriate level.
    //You can play with the numbers depending on what zoom level you want.
    
    CLLocationCoordinate2D userLoc;
    userLoc.latitude = mapView.userLocation.location.coordinate.latitude;
    userLoc.longitude = mapView.userLocation.location.coordinate.longitude;
    MKCoordinateRegion region;
    region.center=userLoc;
    MKCoordinateSpan span;
    span.latitudeDelta=0.02;
    span.longitudeDelta=0.02;
    region.span = span;
    mapView.region = region;
    
}

-(void) setupAnnotations
{
    [mapView removeAnnotations:[mapView annotations]];
    
    for (int iCount = 0; iCount < [[[PHAleTrailFactory getCurrentPHAleTrail] getPubs] count]; iCount++)
    {
        
        Pub*media = [[[PHAleTrailFactory getCurrentPHAleTrail] getPubs]  objectAtIndex:iCount];
        [self addPoi:media];
        
    }
    
}


-(void)addPoi:(Pub*)media
{
    
    
    CLLocationCoordinate2D location;
    
    location.latitude=media.yCoord ;
    location.longitude=media.xCoord ;
    
    
    Annotation *addAnnotation = [[Annotation alloc] initWithPoi:media];
    addAnnotation.coordinate = location;
    
    [mapView addAnnotation:addAnnotation];
    
}
-(BOOL)shouldAutorotate
{
    // forcing the rotate IOS6 Only
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}
-(IBAction) back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point
{
    
    int xadjust = 0;
    
    if ([text intValue] > 9)
    {
        xadjust = 6;
    }
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 2.0f);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x - xadjust, point.y, image.size.width, image.size.height);
    //    [[SystemVariables getMainColor] set];
    [text drawInRect:rect withAttributes:@{NSFontAttributeName            : [UIFont boldSystemFontOfSize:18]}];

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return newImage;
}

@end

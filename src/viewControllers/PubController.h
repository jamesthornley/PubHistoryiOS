//
//  PoiController.h
//  audiotrails
//
//  Created by James Thornley on 16/01/2001.
//  Copyright 2001 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Pub.h"
#import "BaseViewController.h"
#import <WebKit/WebKit.h>

@interface PubController : BaseViewController<WKNavigationDelegate>
{

    NSLayoutConstraint *heightConstraint;
}

@property (nonatomic) IBOutlet WKWebView *mainWebView;
@property (nonatomic) IBOutlet WKWebView *landscapeImageView;
@property (nonatomic) IBOutlet WKWebView *portraitImageView;
@property (nonatomic) Pub *pub;
@property (nonatomic, retain) IBOutlet  UIView *menuView;;


-(IBAction) visited;
-(IBAction) directions;
-(IBAction) menu;

@end

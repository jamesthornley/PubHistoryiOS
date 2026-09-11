//
//  GenericWebViewController.h
//  YorkshireDales
//
//  Created by  James on 24/02/2015.
//  Copyright (c) 2015 CoDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <WebKit/WebKit.h>

@interface GenericWebViewController : BaseViewController<WKNavigationDelegate>
{
}
@property (nonatomic, retain) IBOutlet WKWebView *webView;
@property (nonatomic, retain) IBOutlet UIButton *backButton;
@property (nonatomic, retain) IBOutlet UIButton *startButton;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain)  NSString *fileName;

-(IBAction)backPage:(id) sender;

@end

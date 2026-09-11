//
//  MainTabViewViewController.m
//  HistoricPubCrawl
//
//  Created by  James on 30/01/2019.
//  Copyright © 2019 CoDeveloper. All rights reserved.
//

#import "MainTabViewViewController.h"

@interface MainTabViewViewController ()

@end

@implementation MainTabViewViewController
static MainTabViewViewController * tabinstance;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
    
    self.selectedIndex = 4;
    tabinstance = self;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    
    if ([viewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *navController = (UINavigationController *)viewController;
        
        [navController popToRootViewControllerAnimated:NO];
        
    }
}
+(MainTabViewViewController *)getTabInstance
{
    return tabinstance;
}
@end

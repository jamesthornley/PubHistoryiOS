//
//  MainTabViewViewController.h
//  HistoricPubCrawl
//
//  Created by  James on 30/01/2019.
//  Copyright © 2019 CoDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHAleTrail.h"

NS_ASSUME_NONNULL_BEGIN

@interface MainTabViewViewController : UITabBarController <UITabBarDelegate,UITabBarControllerDelegate>

@property PHAleTrail * selectedTrail;
+(MainTabViewViewController *)getTabInstance;


@end

NS_ASSUME_NONNULL_END

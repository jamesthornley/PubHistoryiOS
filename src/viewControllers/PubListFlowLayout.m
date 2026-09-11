//
//  PoiListFlowLayout.m
//  HistoricPubCrawl
//
//  Created by  James on 24/05/2018.
//  Copyright © 2018 CoDeveloper. All rights reserved.
//

#import "PubListFlowLayout.h"

@implementation PubListFlowLayout

- (CGSize)itemSize
{
    NSInteger numberOfColumns = 3;
    
    CGFloat itemWidth = (CGRectGetWidth(self.collectionView.frame) - 0) / numberOfColumns;
    
    
    CGFloat itemHeight = 1.5 * itemWidth;
    return CGSizeMake(itemWidth, itemHeight);
}
@end

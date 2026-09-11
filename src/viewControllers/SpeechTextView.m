//
//  SpeechTextView.m
//  HistoricPubCrawl
//
//  Created by  James on 02/08/2017.
//  Copyright © 2017 CoDeveloper. All rights reserved.
//

#import "SpeechTextView.h"
#import "User.h"
#import "UserList.h"
#import "BaseDate.h"

@implementation SpeechTextView

-(SpeechTextView*)init
{
    self = [super init];
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    cornerRadius = 15;

    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, .5f);
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    
    rect.origin.y++;
    CGFloat radius = cornerRadius;
    
    CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
    
    CGMutablePathRef outlinePath = CGPathCreateMutable();
    
    UIColor * bubbleColour = [UIColor lightGrayColor];
    
    if ([self.note isLeftMessage])
    {
        bubbleColour = [UIColor redColor];
    }
    else if ([self.note isArrivedMessage])
    {
        bubbleColour = [UIColor greenColor];
    }
    else if ([self.note isCurrentUserWithDatabase:nil] )
    {
        bubbleColour = [UIColor blueColor];
    }
    
    NSMutableArray *normalGradientLocations = [NSMutableArray arrayWithObjects:
                                                  [NSNumber numberWithFloat:0.0f],
                                                  [NSNumber numberWithFloat:1.0f],
                                                  nil];
       
       
       NSMutableArray *colors = [NSMutableArray arrayWithCapacity:2];
       
       UIColor *color = [UIColor whiteColor];
       [colors addObject:(id)[color CGColor]];
       color = [UIColor lightTextColor];
       [colors addObject:(id)[color CGColor]];
       NSMutableArray  *normalGradientColors = colors;
       
       long locCount = [normalGradientLocations count];
       CGFloat locations[locCount];
       for (int i = 0; i < [normalGradientLocations count]; i++)
       {
           NSNumber *location = [normalGradientLocations objectAtIndex:i];
           locations[i] = [location floatValue];
       }
       CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
       
       CGGradientRef normalGradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)normalGradientColors, locations);
       CGColorSpaceRelease(space);
    
    if ([self.note isCurrentUserWithDatabase:nil] == NO)
    {
        minx += 5;
        
        CGPathMoveToPoint(outlinePath, nil, midx, miny);
        CGPathAddArcToPoint(outlinePath, nil, maxx, miny, maxx, midy, radius);
        CGPathAddArcToPoint(outlinePath, nil, maxx, maxy, midx, maxy, radius);
        CGPathAddArcToPoint(outlinePath, nil, minx, maxy, minx, midy, radius);
        CGPathAddLineToPoint(outlinePath, nil, minx, miny + 20);
        CGPathAddLineToPoint(outlinePath, nil, minx - 5, miny + 15);
        CGPathAddLineToPoint(outlinePath, nil, minx, miny + 10);
        CGPathAddArcToPoint(outlinePath, nil, minx, miny, midx, miny, radius);
        CGPathCloseSubpath(outlinePath);
        
        CGContextSetShadowWithColor(context, CGSizeMake(0,1), 1, bubbleColour.CGColor);
        CGContextAddPath(context, outlinePath);
        CGContextFillPath(context);
        
        CGContextAddPath(context, outlinePath);
        CGContextClip(context);
        CGPoint start = CGPointMake(rect.origin.x, rect.origin.y);
        CGPoint end = CGPointMake(rect.origin.x, rect.size.height);
        CGContextDrawLinearGradient(context, normalGradient, start, end, 0);

    }
    else
    {
        maxx-=5;
        CGPathMoveToPoint(outlinePath, nil, midx, miny);
        CGPathAddArcToPoint(outlinePath, nil, minx, miny, minx, midy, radius);
        CGPathAddArcToPoint(outlinePath, nil, minx, maxy, midx, maxy, radius);
        CGPathAddArcToPoint(outlinePath, nil, maxx, maxy, maxx, midy, radius);
        CGPathAddLineToPoint(outlinePath, nil, maxx, miny + 20);
        CGPathAddLineToPoint(outlinePath, nil, maxx + 5, miny + 15);
        CGPathAddLineToPoint(outlinePath, nil, maxx, miny + 10);
        CGPathAddArcToPoint(outlinePath, nil, maxx, miny, midx, miny, radius);
        CGPathCloseSubpath(outlinePath);
        
        CGContextSetShadowWithColor(context, CGSizeMake(0,1), 1, bubbleColour.CGColor);
        CGContextAddPath(context, outlinePath);
        CGContextFillPath(context);
        
        CGContextAddPath(context, outlinePath);
        CGContextClip(context);
        CGPoint start = CGPointMake(rect.origin.x, rect.origin.y);
        CGPoint end = CGPointMake(rect.origin.x, rect.size.height);
        CGContextDrawLinearGradient(context, normalGradient, start, end, 0);

    }
    

    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGRect newrect = CGRectMake(10, 10, 200, 30);
    
    NSString *dateText = [_note.noteDate getDisplayTime];
    [dateText drawInRect:newrect withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica"  size:14]}];

    if (self.note != nil && [self.note isCurrentUserWithDatabase:nil] == NO)
    {
        newrect = CGRectMake(50, 10, 200, 30);

        [self.note.username drawInRect:newrect withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica Bold"  size:14]}];
    }
    

     newrect = CGRectMake(10, 30, 200, [_note getSize].height - 30);
    
    [_note.note drawInRect:newrect withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica"  size:17]}];

    CGPathRelease(outlinePath);
    CGGradientRelease(normalGradient);

}

- (CGRect)textRectForBounds:(CGRect)bounds
     limitedToNumberOfLines:(NSInteger)numberOfLines
{
    CGRect returnRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    
    returnRect.size = [self getSize];
    return returnRect;
}
-(CGSize ) getSize
{
    CGSize size = CGSizeZero;
    
    
        int widthValue = 200;
        
        if (_note)
        {
            CGRect frame = [self.note.note boundingRectWithSize:CGSizeMake(widthValue, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:[UIFont fontWithName:@"Helvetica"  size:17] } context:nil];
            size = CGSizeMake(frame.size.width, frame.size.height + 10);
        }
        
        size.height = size.height + 20 + 30;  //plus 30 for date
        size.width = size.width + 20 ;

        NSString *dateText = [_note.noteDate getDisplayTime];
    
        if (self.note != nil && [self.note isCurrentUserWithDatabase:nil] == NO)
        {
            dateText = [NSString stringWithFormat:@"%@ %@",dateText,self.note.username];
        }
    
        CGRect frame2 = [dateText boundingRectWithSize:CGSizeMake(widthValue, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:[UIFont fontWithName:@"Helvetica"  size:14] } context:nil];
            
        if (frame2.size.width + 20 > size.width)
        {
            size.width =frame2.size.width + 20;
        }
    
        return size;
    
}
@end

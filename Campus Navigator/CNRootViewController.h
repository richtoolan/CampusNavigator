//
//  CNViewController.h
//  Campus Navigator
//
//  Created by Rich on 26/11/2012.
//  Copyright (c) 2012 UCC. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "CNOpenEars.h"
#import <MapBox/MapBox.h>
@class CNMapViewController;

@protocol CNOpenEarsDelegate
-(void)giveStringLocation:(NSString *)text;

@end
@interface CNRootViewController : UIViewController<CNOpenEarsDelegate, RMMapViewDelegate>{
    //CNMapViewController *_mapView;
    CNOpenEars *openEars;
    NSArray *points;
    
}
@property (nonatomic, retain) CNOpenEars *openEars;
-(void)giveStringLocation:(NSString *)text;
@end

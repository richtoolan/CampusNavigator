//
//  CNViewController.h
//  Campus Navigator
//
//  Created by Rich on 26/11/2012.
//  Copyright (c) 2012 UCC. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "CNOpenEars.h"
#import "CNNavigator.h"
#import <MapBox/MapBox.h>
@class CNMapViewController;
@protocol CNOpenEarsDelegate
-(void)giveStringLocation:(NSString *)text;

@end
@protocol CNNavigatorDelegate
-(void)setPathObject:(NSArray *)pointsArray;

@end

@interface CNRootViewController : UIViewController<CNOpenEarsDelegate, RMMapViewDelegate, CNNavigatorDelegate>{
    //CNMapViewController *_mapView;
    CNOpenEars *openEars;
    NSArray *points;
    CNNavigator *navigator;
    CNMapViewController *mapView;

    
    
}
@property (nonatomic, retain) CNOpenEars *openEars;
@property (nonatomic, retain) CNNavigator *navigator;
-(void)giveStringLocation:(NSString *)text;
-(void)setPathObject:(NSArray *)pointsArray;
@end

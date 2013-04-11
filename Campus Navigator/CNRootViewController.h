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
-(void)generateVoiceForFiveNearest;
-(void)saveFavouriteWithName:(NSString *)name;

@end
@protocol CNNavigatorDelegate
-(void)setPathObject:(NSArray *)pointsArray;
-(void)giveStringLocation:(NSString *)text;
-(void)centreOnPoint:(CLLocation *)point;

@end
@protocol CNAnnotationDelegate
-(void)annotationClickedWithString:(NSString *)string;

@end
@interface CNRootViewController : UIViewController<CNOpenEarsDelegate, RMMapViewDelegate, CNNavigatorDelegate, UITableViewDataSource, UITableViewDelegate>{
    //CNMapViewController *_mapView;
    CNOpenEars *openEars;
    NSArray *points;
    NSArray *places;
    CNNavigator *navigator;
    //RMMapView =
    CNMapViewController *mapView;
    //BOOL userVIP;
    BOOL userIdentified;
    BOOL userVip;
    UIButton *actionButton;
    UILabel *buttonLabel;
    BOOL vibrateRequired;
    UIButton *yesAnswer;
    UITapGestureRecognizer *tapRecog;
    
}
@property (nonatomic, retain) CNOpenEars *openEars;
@property (nonatomic, retain) CNNavigator *navigator;
-(void)giveStringLocation:(NSString *)text;
-(void)setPathObject:(NSArray *)pointsArray;
@end

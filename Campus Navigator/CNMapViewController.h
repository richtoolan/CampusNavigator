//
//  CNMapViewController.h
//  Campus Navigator
//
//  Created by Rich on 27/11/2012.
//  Copyright (c) 2012 UCC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapBox/MapBox.h>
@interface CNMapViewController : UIView <RMMapViewDelegate>{
    RMMapView *_mapView;
    NSDictionary *pathsInView;
}
@property (nonatomic, retain) id parentPointer;
-(id)initWithFrame:(CGRect)frame;
-(void)addAnnotationForPoints:(NSArray *)points;
-(void)removePathAnnotation;
@end

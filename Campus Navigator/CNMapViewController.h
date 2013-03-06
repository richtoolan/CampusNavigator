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
}
-(id)initWithFrame:(CGRect)frame;
@end

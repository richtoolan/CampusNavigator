//
//  CNCustomAnnotation.h
//  Campus Navigator
//
//  Created by Rich on 20/12/2012.
//  Copyright (c) 2012 UCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapBox/MapBox.h>
@class CNAnnotationView;
@interface CNCustomAnnotation : RMAnnotation {
    NSString *_string;
    CNAnnotationView *_annoView;
    CLLocationCoordinate2D _cent;
}
@property(nonatomic, assign) NSString *string;
@property(nonatomic, assign) CNAnnotationView *annoView;
@property CLLocationCoordinate2D cent;
- (id)initWithMapView:(RMMapView *)mapview coordinate:(CLLocationCoordinate2D)coord andTitle:(NSString *)ttle andString:(NSString *)string andCentre:(CLLocationCoordinate2D)centre;

@end
@implementation CNCustomAnnotation
@synthesize string = _string;
@synthesize cent = _cent;
- (id) initWithMapView:(RMMapView *)mapview coordinate:(CLLocationCoordinate2D)coord andTitle:(NSString *)ttle andString:(NSString *)string andCentre:(CLLocationCoordinate2D)centre
{
    self = [[super initWithMapView:mapview coordinate:coord andTitle:title] retain];
    self.coordinate = coord;
    self.title = ttle;
    _cent = centre;
    _string = string;
    return self;
}




@end

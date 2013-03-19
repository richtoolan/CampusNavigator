//
//  CNMapViewController.m
//  Campus Navigator
//
//  Created by Rich on 27/11/2012.
//  Copyright (c) 2012 UCC. All rights reserved.
//

#import "CNMapViewController.h"
#import "CNCommon.h"
#import "CNCustomAnnotation.h"
#import "CNAnnotationView.h"
#import <QuartzCore/QuartzCore.h>
#define RED [UIColor colorWithRed:1.f green:0.f blue:0.f alpha:1.f]
#define GREEN [UIColor colorWithRed:0.f green:1.f blue:0.f alpha:1.f]
#define BLUE [UIColor colorWithRed:(6/255.0) green:(145/255.0) blue:(247/255.0) alpha:1.f]
#define BLACK [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:1.f]
#define WHITE [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:1.f]
#define YELLOW [UIColor colorWithRed:(244/255.0) green:(255/255.0) blue:(118/255.0) alpha:1.f]

@implementation CNMapViewController
@synthesize parentPointer;
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        pathsInView = [[[NSMutableDictionary alloc] init] retain];
        RMMBTilesSource *offlineSource = [[RMMBTilesSource alloc] initWithTileSetURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"FinalUCCMap" ofType:@"mbtiles"]]];
        
        _mapView = [[RMMapView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) andTilesource:offlineSource];
        [offlineSource release];
        _mapView.delegate = self;
        _mapView.zoom = 1;
        [_mapView setUserTrackingMode:RMUserTrackingModeFollowWithHeading];
        _mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _mapView.showsUserLocation = YES;
        [_mapView zoomWithLatitudeLongitudeBoundsSouthWest:CLLocationCoordinate2DMake(51.893153,-8.492285) northEast:CLLocationCoordinate2DMake(51.893749,-8.491856) animated:YES];
        _mapView.adjustTilesForRetinaDisplay = YES; // these tiles aren't designed specifically for retina, so make them legible

        [self addAnnotation];

        [self addSubview:_mapView];
    }
    return self;
}

-(void)mapViewRegionDidChange:(RMMapView *)mapView{
    [self hideVisibleAnnotationsWithAnnotation:nil];
}

- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation {
    if([annotation isKindOfClass:[RMUserLocation class]]){
        //user type loc
        return nil;
    }else if ([annotation isKindOfClass:[CNCustomAnnotation class]] ){
        NSPredicate * regexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES '^(?:|0|[1-9]\\d*)(?:\\.\\d*)?$'"];
        NSString *title = annotation.title;
        if([regexTest evaluateWithObject:title]){
            NSLog(@"annotation title is %@", annotation.title);
            return [self layerForPoints:[pathsInView objectForKey:annotation.title]];
        }
        
        RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"marker.png"] anchorPoint:CGPointMake(.5, .8)];
        return marker;
    }

    return annotation.layer;
    
    

}
-(void)removePathAnnotation{
    NSPredicate * regexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES '^(?:|0|[1-9]\\d*)(?:\\.\\d*)?$'"];
    for(RMAnnotation *annotation in _mapView.annotations){
    NSString *title = annotation.title;
    if([regexTest evaluateWithObject:title]){
        [_mapView removeAnnotation:annotation];
    }
    
    }
    
}
-(void)tapOnAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{
    
    //Check for visibile annotations
    
    CNCustomAnnotation *anno = (CNCustomAnnotation *)annotation;

    
    [map setCenterCoordinate:anno.cent animated:YES];
    
    
    //if(![anno.layer isKindOfClass:[RMShape class]]){
    [self hideVisibleAnnotationsWithAnnotation:anno];
    if(anno.annoView != nil && anno.annoView.view.alpha < 0.1){
        [UIView animateWithDuration:.5 animations:^(){
            anno.annoView.view.alpha = .9;
        }];
    }if(anno.annoView == nil){
        CNAnnotationView *view = [[[CNAnnotationView alloc] initWithFrame:CGRectMake(GRID_SIZE*2, GRID_SIZE*2, self.frame.size.width - (GRID_SIZE * 2), GRID_SIZE *2.4) andText:anno.string] retain];
        view.delegate = self.parentPointer;
        [self.superview addSubview:view.view];
        [UIView animateWithDuration:.5 animations:^(){
            view.view.alpha = .9;
        }
        ];
        anno.annoView = view;
        [view release];
    }
    //}else{
    //    NSLog(@"%@", NSStringFromCGRect(anno.layer.bounds)  );
    //}
}
-(void)hideVisibleAnnotationsWithAnnotation:(RMAnnotation *)anno{
    if(anno != nil){
    for(CNCustomAnnotation *cv in [_mapView annotations]){
        if ([cv isKindOfClass:[CNCustomAnnotation class]]) {
            
            if(![cv isEqual:(CNCustomAnnotation *)anno]){
                [UIView animateWithDuration:.5 animations:^(){
                    cv.annoView.view.alpha = 0.0;
                }
                 ];
            }
        }
    }
    }else{
        for(CNCustomAnnotation *cv in [_mapView annotations]){
            if ([cv isKindOfClass:[CNCustomAnnotation class]] && !cv.isAnnotationOnScreen) {
                
                if(cv.annoView && cv.annoView.view.alpha > 0.1){
                    [UIView animateWithDuration:.5 animations:^(){
                        cv.annoView.view.alpha = .0;
                    }
                     ];
                }
            }
        }
    }
}

-(void)addAnnotationForPoints:(NSArray *)points{
    if ([points count]>0) {
        NSString* title = [NSString stringWithFormat:@"%@", [[points objectAtIndex:0] objectForKey:@"PARENT"] ];
        [pathsInView setValue:points forKey:title];
        CLLocation *mid = [[points objectAtIndex:[points count]/2] objectForKey:@"pointCoordinate"];
   
        CLLocation *first = [[points objectAtIndex:0] objectForKey:@"pointCoordinate"];

        CNCustomAnnotation *anno = [[CNCustomAnnotation alloc] initWithMapView:_mapView coordinate:[mid coordinate] andTitle:title andString:title andCentre:[first coordinate]];
    
        anno.layer = [self layerForPoints:points];
    
        [_mapView addAnnotation:anno];
    
        //anno.coordinate = CLLocationCoordinate2DMake(51.893504,-8.492079);
    
        [anno release];
    
    }
}
-(RMShape *)layerForPoints:(NSArray *)points{
    RMShape *shape = [[[RMShape alloc] initWithView:_mapView] retain];;
    //NSString *title;
    CLLocation *first = [[points objectAtIndex:0] objectForKey:@"pointCoordinate"];
    
    [shape moveToCoordinate:[first coordinate]];
    
    for(NSDictionary *point in points){
        CLLocation *loc = [point objectForKey:@"pointCoordinate"];
        //51.893504,-8.492079
        
        
        //RMProjectedPoint point = RMProjectedPointMake;
        //[shape addLineToProjectedPoint:point];
        //[shape moveToCoordinate:CLLocationCoordinate2DMake(47.089634, 15.429118)];
        // point = RMProjectedPointMake();
        [shape addLineToCoordinate:[loc coordinate]];
        
    }
    int i = rand()%3;
    [shape setLineWidth:3.0];
    if(i == 0){
        [shape setLineColor:BLUE];
    }else if(i == 1){
        [shape setLineColor:BLUE];
        
        
    }else{
        [shape setLineColor:BLUE];
    }
    //CALayer *layer = shape;
    [shape setLineWidth:5];
    shape.shadowColor = [YELLOW CGColor];
    shape.shadowOffset = CGSizeMake(1, 1);
    shape.shadowOpacity = 1.0;
    shape.cornerRadius = 4;
    [shape setFillMode:kCAFillModeRemoved];
    //[shape moveToCoordinate:[mid coordinate]];
    return [shape autorelease];

}
-(void)addBuildings:(NSArray *)buildings{
    for(NSDictionary *building in buildings){
        CLLocation *location = [building objectForKey:@"pointCoordinate"];
        NSString *name = [building objectForKey:@"name"];
        CNCustomAnnotation *anno = [[CNCustomAnnotation alloc] initWithMapView:_mapView coordinate:location.coordinate andTitle:name andString:name andCentre:location.coordinate];
        
        [_mapView addAnnotation:anno];
        //[anno release];
    }
}
-(void)addAnnotation{
    /*
    //initWithMapView:(RMMapView *)mapview coordinate:(CLLocationCoordinate2D)coord andTitle:(NSString *)ttle andString:(NSString *)string
    //51.893036,-8.500505
    RMShape *shape = [[[RMShape alloc] initWithView:_mapView] retain];
    //51.893504,-8.492079
    
    [shape moveToCoordinate:CLLocationCoordinate2DMake(51.893117,-8.492541)];
    [shape setLineWidth:3.0];
    [shape setLineColor:[UIColor colorWithRed:1.f green:0.f blue:0.f alpha:1.f]];

    //RMProjectedPoint point = RMProjectedPointMake;
    //[shape addLineToProjectedPoint:point];
    //[shape moveToCoordinate:CLLocationCoordinate2DMake(47.089634, 15.429118)];
   // point = RMProjectedPointMake();
    [shape addLineToCoordinate:CLLocationCoordinate2DMake(51.893592,-8.492914)];
    
    [shape addLineToCoordinate:CLLocationCoordinate2DMake(51.893768,-8.492351)];
    
    
    //point = RMProjectedPointMake();
    [shape addLineToCoordinate:CLLocationCoordinate2DMake(51.893940,-8.492351)];
    [shape addLineToCoordinate:CLLocationCoordinate2DMake(51.894100,-8.491886)];//
    [shape addLineToCoordinate:CLLocationCoordinate2DMake(51.893470,-8.491341)];
    [shape addLineToCoordinate:CLLocationCoordinate2DMake(51.893430,-8.491505)];
    
    [shape addLineToCoordinate:CLLocationCoordinate2DMake(51.893825,-8.491822)];
    
    [shape addLineToCoordinate:CLLocationCoordinate2DMake(51.893575,-8.492667)];
    
    [shape addLineToCoordinate:CLLocationCoordinate2DMake(51.893163,-8.492376)];
    //[shape addLineToProjectedPoint:point];
    [shape setFillColor:[UIColor colorWithRed:1.f green:0.f blue:0.f alpha:0.5f]];
    [shape setLineColor:[UIColor colorWithRed:1.f green:0.f blue:0.f alpha:1.f]];
    [shape closePath];
    
    [shape moveToCoordinate:CLLocationCoordinate2DMake(51.893504,-8.492079)];
    CNCustomAnnotation *anno = [[CNCustomAnnotation alloc] initWithMapView:_mapView coordinate:CLLocationCoordinate2DMake(51.893504,-8.492079) andTitle:@"" andString:@"WestWing" andCentre:CLLocationCoordinate2DMake(51.893504,-8.492079)];
    
    anno.layer = shape;
    
    [_mapView addAnnotation:anno];
    
    //anno.coordinate = CLLocationCoordinate2DMake(51.893504,-8.492079);
    
    [anno release];
    [shape release];
    shape =nil;
    anno = [[CNCustomAnnotation alloc]initWithMapView:_mapView coordinate:CLLocationCoordinate2DMake(51.893036,-8.500505)  andTitle:@"WGB" andString:@"Western Gateway Building" andCentre:CLLocationCoordinate2DMake(51.893036,-8.500505)];
    
    shape = [[RMShape alloc] initWithView:_mapView] ;
    //51.893504,-8.492079
    
    [shape moveToCoordinate:CLLocationCoordinate2DMake(51.892603,-8.501133)];
    [shape setLineWidth:3.0];
    [shape setLineColor:[UIColor colorWithRed:1.f green:0.f blue:0.f alpha:1.f]];
    
    //RMProjectedPoint point = RMProjectedPointMake;
    //[shape addLineToProjectedPoint:point];
    //[shape moveToCoordinate:CLLocationCoordinate2DMake(47.089634, 15.429118)];
    // point = RMProjectedPointMake();
    [shape addLineToCoordinate:CLLocationCoordinate2DMake(51.893191,-8.501440)];
    
    [shape addLineToCoordinate:CLLocationCoordinate2DMake(51.893465,-8.499991)];
    
    
    //point = RMProjectedPointMake();
    [shape addLineToCoordinate:CLLocationCoordinate2DMake(51.892888,-8.499689)];
    //[shape addLineToCoordinate:CLLocationCoordinate2DMake(51.894100,-8.491886)];//
    //[shape addLineToCoordinate:CLLocationCoordinate2DMake(51.893470,-8.491341)];
    //[shape addLineToCoordinate:CLLocationCoordinate2DMake(51.893430,-8.491505)];
    
    //[shape addLineToCoordinate:CLLocationCoordinate2DMake(51.893825,-8.491822)];
    
    //[shape addLineToCoordinate:CLLocationCoordinate2DMake(51.893575,-8.492667)];
    
    //[shape addLineToCoordinate:CLLocationCoordinate2DMake(51.893163,-8.492376)];
    //[shape addLineToProjectedPoint:point];
    [shape setFillColor:[UIColor colorWithRed:1.f green:0.f blue:0.f alpha:0.5f]];
    [shape setLineColor:[UIColor colorWithRed:1.f green:0.f blue:0.f alpha:1.f]];
    [shape closePath];
    
    [shape moveToCoordinate:CLLocationCoordinate2DMake(51.893504,-8.492079)];
    anno.layer = shape;
    
    
    [_mapView addAnnotation:anno];
    
    //
    
    [anno release];
    [shape release];
    //[_mapView addAnnotation:[[CNCustomAnnotation alloc]initWithMapView:_mapView coordinate:CLLocationCoordinate2DMake(51.893504,-8.492079)  andTitle:@"Quad" andString:@"Quad Centre"]];
    //[[RMAnnotation alloc] initWithMapView:<#(RMMapView *)#> coordinate:(CLLocationCoordinate2D) andTitle:<#(NSString *)#>]
    //[mapView addAnnotation:[[CustomAnnotation alloc ] initWithMapView:mapView coordinate:CLLocationCoordinate2DMake(51.893504,-8.492079) andTtle:@"WGB" add]];
     */
}
-(void)testClick{
    
    NSLog(@"Click worked yo!"   );
}
@end

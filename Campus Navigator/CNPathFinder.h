//
//  CNPathFinder.h
//  Campus Navigator
//
//  Created by Rich on 10/01/2013.
//  Copyright (c) 2013 UCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@class CNDAO, PESGraph;
@interface CNPathFinder : NSObject{
    CNDAO *dao;
    PESGraph *graph;
    PESGraph *secondGraph;
    CLLocationCoordinate2D prevUserLoc;
    NSNumber *buildingNearPointID;
}
-(NSArray *)getNodesForPathFrom:(int)org toDest:(int)dest andUserLoc:(CLLocationCoordinate2D)userLoc;
-(NSDictionary *)getNearestPointForLat:(double)lat AndLon:(double)lon;
-(NSArray *)generateDirectionObjects:(NSArray *)paths;
-(NSArray *)compareAndUpdateCoordinates:(NSArray*)points;
-(NSDictionary *)getNearestBuidingForString:(NSString *)building;
-(NSArray *)getNearestBuildings:(CLLocationCoordinate2D)userLoc withBearing:(double)bearing;
@end

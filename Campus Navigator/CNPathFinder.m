//
//  CNPathFinder.m
//  Campus Navigator
//
//  Created by Rich on 10/01/2013.
//  Copyright (c) 2013 UCC. All rights reserved.
//
// Radians to Degrees. Usage: RADIANS_TO_DEGREES(0.785398)
#define RADIANS_TO_DEGREES(radians) ((radians) * 180.0 / M_PI)

// Degrees to radians. Usage: DEGREES_TO_RADIANS(45)
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#import "CNPathFinder.h"
#import "PESGraph.h"
#import "PESGraphEdge.h"
#import "PESGraphNode.h"
#import "PESGraphRoute.h"
#import "PESGraphRouteStep.h"
#import "CNDAO.h"
#import "CNPathAction.h"
#import <CoreLocation/CoreLocation.h>
#import "UtilitiesGeo.h"
@implementation CNPathFinder
-(id)init{
    if(self = [super init]){
        dao = [[[CNDAO alloc] init] retain];
        [self generatePathGraph];
    }
  return self;
}
//helpful methods used during development
-(float)radiandsToDegrees:(float)x{
    return (x * 180.0 / M_PI);
}
-(float)degreesToRadians:(float)x{
    return (M_PI * x / 180.0);
}
//wrappers for DAO method
-(NSDictionary *)getNearestPointForLat:(double)lat AndLon:(double)lon{
    return [dao getNearestPointForLat:lat AndLon:lon];
}
//same
-(NSDictionary *)getApproachingWarnings:(double)lat AndLon:(double)lon{
    return [dao getApproachingWarnings:lat AndLon:lon];
}
//same
-(NSDictionary *)getNearestBuidingForString:(NSString *)building{
    NSDictionary *returnDict = [dao getNearestBuidingForString:building];
    buildingNearPointID = [returnDict objectForKey:@"ID"];
    //get the co-ordinate
    return returnDict;
}
/*************
 -(NSArray *)generateDirectionObjects:(NSArray *)paths 
 Returns an array of CNPathAction objects for the paths in the array paths
 ************/
-(NSArray *)generateDirectionObjects:(NSArray *)paths{
    NSMutableArray *pathAction = [[NSMutableArray alloc] init];
    for(int index = 1; index < [paths count]; index ++){
        NSArray *previousPath = [paths objectAtIndex:index-1];
        NSArray *path = [paths objectAtIndex:index];
        if(!([path count]<= 1 || [previousPath count] <=1)){
        NSString *ppParent = [(NSDictionary *)[previousPath objectAtIndex:0] objectForKey:@"PARENT"];
        CLLocation *ppCoord1 = [(NSDictionary *)[previousPath objectAtIndex:(([previousPath count])-1)] objectForKey:@"pointCoordinate"];
        CLLocation *ppCoord2 = [(NSDictionary *)[previousPath objectAtIndex:(([previousPath count])-2)] objectForKey:@"pointCoordinate"];
        NSString *pParent = [(NSDictionary *)[path objectAtIndex:(([path count])-1)] objectForKey:@"PARENT"];
      
        CLLocation *pCoord1 = [(NSDictionary *)[path objectAtIndex:0] objectForKey:@"pointCoordinate"];
        CLLocation *pCoord2 = [(NSDictionary *)[path objectAtIndex:1] objectForKey:@"pointCoordinate"];
            if([pCoord1 distanceFromLocation:ppCoord1] > [pCoord2 distanceFromLocation:ppCoord1]){
                pCoord2 = pCoord1;
                pCoord1 = [(NSDictionary *)[path objectAtIndex:(([path count])-2)] objectForKey:@"pointCoordinate"];
            }
        float angle ;
        float ppBearing = [self getHeadingForDirectionFromCoordinate:ppCoord2 toCoordinate:ppCoord1];
        float pBearing = [self getHeadingForDirectionFromCoordinate:pCoord2 toCoordinate:pCoord1];
        angle = pBearing - ppBearing;
        angle = angle <0?angle+=360:angle;
       [pathAction addObject:[[CNPathAction alloc] initWithFromPath:ppParent toPath:pParent withAngle:angle andLocation: ppCoord1]];
       
        }
    }
    return [pathAction autorelease];
}
/*************
 -(NSArray *)generateDirectionObjects:(NSArray *)paths
 Returns an array of CNPathAction objects for the paths in the array paths
 ************/
-(NSArray *)getNearestBuildings:(CLLocationCoordinate2D)userLoc withBearing:(double)bearing{
    NSArray *array = [dao get:4 NearBuildingsWithLat:userLoc.latitude andLon:userLoc.longitude];
    for (NSMutableDictionary *dict in array) {
        NSNumber *number = [dict objectForKey:@"Angle"];
        //if (bearing > [number floatValue]) {
        float bring = ([number floatValue]-bearing);
        if (bring < 0) {
            bring = 360 + bring;
        }else if(bring > 360){
            bring -= 360;
        }
    
        [dict setValue:[NSNumber numberWithFloat:bring] forKey:@"Angle"];
        
        //}else{
        //    [dict setValue:[NSNumber numberWithFloat:([number floatValue]-bearing)] forKey:@"Angle"];
            
        //}
    }
    return [array autorelease];
}
/*************
 -(NSArray *)generateDirectionObjects:(NSArray *)paths
 Returns an array of CNPathAction objects for the paths in the array paths
 ************/
-(NSArray *)compareAndUpdateCoordinates:(NSArray*)points{
    if([points count] > 0 && [[points objectAtIndex:0]count]> 0){
    NSMutableArray *pointM = [[NSMutableArray alloc] initWithArray:points];
    assert([points isEqual:pointM]);
    CLLocation *firstPPath= [[[points objectAtIndex:0] objectAtIndex:0] objectForKey:@"pointCoordinate"];
    CLLocation *lastPPath= [[[points objectAtIndex:0] objectAtIndex:[[points objectAtIndex:0] count]-1] objectForKey:@"pointCoordinate"];
    CLLocation *userLoc = [[CLLocation alloc]initWithLatitude:prevUserLoc.latitude longitude:prevUserLoc.longitude];
    if([firstPPath distanceFromLocation:userLoc] > [lastPPath distanceFromLocation:userLoc]){
        [pointM replaceObjectAtIndex:0 withObject:[[[points objectAtIndex:0] reverseObjectEnumerator] allObjects]];
        
    }
    for(int index = 1; index < [points count]; index ++){
        if([[points objectAtIndex:index] count]> 0 && [[points objectAtIndex:index-1] count]> 0){
        int previousPathPointCount = [[points objectAtIndex:index-1] count];
        int currentPathCount = [[points objectAtIndex:index] count];
        
        //CLLocation *firstPPath= [[[points objectAtIndex:index-1] objectAtIndex:0] objectForKey:@"pointCoordinate"];
        CLLocation *lastPPath= [[[points objectAtIndex:index-1] objectAtIndex:previousPathPointCount-1] objectForKey:@"pointCoordinate"];
        CLLocation *firstCPath= [[[points objectAtIndex:index] objectAtIndex:0]objectForKey:@"pointCoordinate"];
        CLLocation *lastCPath= [[[points objectAtIndex:index] objectAtIndex:currentPathCount-1]objectForKey:@"pointCoordinate"];
        double lPToFC, lpToLC;
        lPToFC = [lastPPath distanceFromLocation:firstCPath];
        lpToLC = [lastPPath distanceFromLocation:lastCPath];
        
        if(lPToFC < lpToLC  ){
            //do nothing this is OK.

        }
        else{
            [pointM replaceObjectAtIndex:index withObject:[[[points objectAtIndex:index] reverseObjectEnumerator] allObjects]];
        }
        
    
}
    }
    points = nil;
    points = pointM;
    return pointM;
    }
    return nil;
}


- (float)getHeadingForDirectionFromCoordinate:(CLLocation *)fromLoc toCoordinate:(CLLocation *)toLoc
{
    float fLat = [self degreesToRadians:fromLoc.coordinate.latitude];
    float fLng = [self degreesToRadians:fromLoc.coordinate.longitude];
    float tLat = [self degreesToRadians:toLoc.coordinate.latitude];
    float tLng = [self degreesToRadians:toLoc.coordinate.longitude];
    
    float degree = [self radiandsToDegrees:(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)))];
    
    if (degree >= 0) {
        return degree;
    } else {
        return 360+degree;
    }
}




/*************
 -(NSArray*)getNodesForPathFrom:(int)org toDest:(int)dest
 
 Returns all nodes(paths of coordinates) for a journey from org to dest, using DJiakstras algorithm implemented in PESGRaph
 
 ************/
-(NSArray*)getNodesForPathFrom:(int)org toDest:(int)dest andUserLoc:(CLLocationCoordinate2D)userLoc{
    prevUserLoc = userLoc;
    NSMutableArray *pointsArr = [[NSMutableArray alloc] init];
    NSArray *nodes =  [self pathFrom:org to:dest];
    //if([nodes count >)
    for(int index = 0; index < [nodes count]; index ++){
        //[dao getPathNodesForParent:[step.node.identifier intValue]];
        int till = -1;
        int from = -1;
        if(index + 1 < [nodes count]){
            till = [((PESGraphRouteStep *)[nodes objectAtIndex:index+1]).node.identifier intValue];
        }
        if(index - 1 >= 0){
            from = [((PESGraphRouteStep *)[nodes objectAtIndex:index-1]).node.identifier intValue];
        }
            [pointsArr addObject:[self getPathNodesForParent:[((PESGraphRouteStep *)[nodes objectAtIndex:index]).node.identifier intValue] tillNode:till fromNode:from]];
            
        }
    pointsArr = (NSMutableArray *)[self compareAndUpdateCoordinates:pointsArr];
    return [[self compareAndUpdateCoordinates:pointsArr] retain];
}

//wrapper method for PESGraph method
-(NSArray *)pathFrom:(int)node to:(int)endNode{
    return [[graph shortestRouteFromNode:[graph nodeInGraphWithIdentifier:[NSString stringWithFormat:@"%iX", node]] toNode:[graph nodeInGraphWithIdentifier:[NSString stringWithFormat:@"%iX", endNode]]] steps];
    
}
/*************
 -(void)generatePathGraph
 Queries DB and populates PESGraph with all paths starts and ends, then finds connections and add the necessary edges
 ************/
-(void)generatePathGraph{
    PESGraphNode *parentNodeX;
    PESGraphNode *parentNodeY;

    
    PESGraphNode *connectionNodeX;
    PESGraphNode *connectionNodeY;
    graph = [[[PESGraph alloc] init] retain];
    
    FMResultSet *rs = [dao executeQuery:@"SELECT * FROM pathNode WHERE ID IN (SELECT MIN(ID) FROM pathNode GROUP BY PARENT_ID) GROUP BY PARENT_ID UNION SELECT * FROM pathNode WHERE ID >= ID GROUP BY PARENT_ID ORDER BY PARENT_ID"];
    //populate graph with all nodes in the database, adding X for the start of the path and Y for the end of the path.
    while([rs next]){
        parentNodeX = [PESGraphNode nodeWithIdentifier:[NSString stringWithFormat:@"%iX",[rs intForColumn:@"PARENT_ID"]]];
        parentNodeX.coordinate = [[CLLocation alloc] initWithLatitude:[rs doubleForColumn:@"LAT"] longitude:[rs doubleForColumn:@"LON"]];
        [rs next];
        parentNodeY = [PESGraphNode nodeWithIdentifier:[NSString stringWithFormat:@"%iY",[rs intForColumn:@"PARENT_ID"]]];
        parentNodeY.coordinate = [[CLLocation alloc] initWithLatitude:[rs doubleForColumn:@"LAT"] longitude:[rs doubleForColumn:@"LON"]];
       // [graph add]
        [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:[NSString stringWithFormat:@"%iX-%iY", [rs intForColumn:@"PARENT_ID"], [rs intForColumn:@"PARENT_ID"]] andWeight:[NSNumber numberWithDouble:[parentNodeX.coordinate distanceFromLocation:parentNodeY.coordinate]]]  fromNode:parentNodeX toNode:parentNodeY ];

    }
    //Get every connection in the  database and add a connection from the node nearest to the path it's connecting to
    rs = [dao executeQuery:@"select * from pathNode WHERE CONNECTIONS != 0 ORDER BY PARENT_ID ASC"];
    while([rs next]){
        parentNodeX = [graph nodeInGraphWithIdentifier:[NSString stringWithFormat:@"%iX",[rs intForColumn:@"PARENT_ID"]]];
        parentNodeY = [graph nodeInGraphWithIdentifier:[NSString stringWithFormat:@"%iY",[rs intForColumn:@"PARENT_ID"]]];
        connectionNodeX = [graph nodeInGraphWithIdentifier:[NSString stringWithFormat:@"%iX",[rs intForColumn:@"CONNECTIONS"]]];
        connectionNodeY = [graph nodeInGraphWithIdentifier:[NSString stringWithFormat:@"%iY",[rs intForColumn:@"CONNECTIONS"]]];
        CLLocation *conLoc = [[CLLocation alloc] initWithLatitude:[rs doubleForColumn:@"LAT"] longitude:[rs doubleForColumn:@"LON"]];
        if([connectionNodeX.coordinate distanceFromLocation:conLoc] < [connectionNodeY.coordinate distanceFromLocation:conLoc]  ){
            [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:[NSString stringWithFormat:@"%iX-%iX", [rs intForColumn:@"PARENT_ID"], [rs intForColumn:@"CONNECTIONS"]]  andWeight:[NSNumber numberWithDouble:[parentNodeX.coordinate distanceFromLocation:conLoc]]]
            fromNode:parentNodeX toNode:connectionNodeX ];
            [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:[NSString stringWithFormat:@"%iY-%iX", [rs intForColumn:@"PARENT_ID"], [rs intForColumn:@"CONNECTIONS"]]  andWeight:[NSNumber numberWithDouble:[parentNodeY.coordinate distanceFromLocation:conLoc]] ]
                               fromNode:parentNodeY toNode:connectionNodeX ];
         }else{
            
            [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:[NSString stringWithFormat:@"%iX-%iY", [rs intForColumn:@"PARENT_ID"], [rs intForColumn:@"CONNECTIONS"]]  andWeight:[NSNumber numberWithDouble:[parentNodeX.coordinate distanceFromLocation:conLoc]]  ]
                               fromNode:parentNodeX toNode:connectionNodeY ];
            [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:[NSString stringWithFormat:@"%iY-%iY", [rs intForColumn:@"PARENT_ID"], [rs intForColumn:@"CONNECTIONS"]]  andWeight:[NSNumber numberWithDouble:[parentNodeY.coordinate distanceFromLocation:conLoc]]  ]
                               fromNode:parentNodeY toNode:connectionNodeY ];
        }
        
    }

}
/*************
 -(NSArray *)getPathNodesForParent:(int)parent tillNode:(int)tillNode fromNode:(int)fromNode
 Returns an array for only the nodes required (between tileNode and fromNode)within a path with parent,
 ************/
-(NSArray *)getPathNodesForParent:(int)parent tillNode:(int)tillNode fromNode:(int)fromNode{

    NSMutableArray *allPoints = [[NSMutableArray alloc] init];
    if(fromNode == -1 ){
        if(dao){
            NSNumber *pID;
            if(prevUserLoc.latitude != 0){
                pID = [[dao getNearestPointForLat:prevUserLoc.latitude AndLon:prevUserLoc.longitude] objectForKey:@"ID"];
                fromNode = [pID intValue];
            }
            BOOL fromFound = NO;
            BOOL tillFound = NO;
            NSString *query = [NSString stringWithFormat:@"SELECT  * FROM pathNode WHERE PARENT_ID = %i ORDER BY ID DESC", parent];
            FMResultSet *rs = [dao executeQuery:query];
            while([rs next]){
                NSMutableDictionary *correctDict = [[NSMutableDictionary alloc] init];
                [correctDict setValue:[[[CLLocation alloc] initWithLatitude:[rs doubleForColumn:@"LAT"] longitude:[rs doubleForColumn:@"LON"]] autorelease] forKey:@"pointCoordinate"];
                [correctDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"CONNECTIONS"]]forKey:@"CONNECTIONS"];
                [correctDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"PARENT_ID"]] forKey:@"PARENT"];
                
                if ([rs intForColumn:@"CONNECTIONS"] == tillNode && fromNode == -1) {
                    rs = nil;
                }else if([rs intForColumn:@"ID"] == fromNode && tillNode == -1){
                    rs = nil;
                }else if([rs intForColumn:@"CONNECTIONS"] == tillNode && fromNode != -1){
                    tillFound = YES;
                    if(fromFound)rs = nil;
                }else if([rs intForColumn:@"ID"] == fromNode && tillNode != -1){
                    fromFound = YES;
                    if(tillFound)rs = nil;
                }
                if(fromFound || tillFound){
                    [allPoints addObject:correctDict];
                }
                [correctDict release];
                
                
            }
    }
    }else if(tillNode == -1){
        tillNode = [buildingNearPointID intValue];
        if(dao){
            NSString *query = [NSString stringWithFormat:@"SELECT  * FROM pathNode WHERE PARENT_ID = %i", parent];
            FMResultSet *rs = [dao executeQuery:query];
            BOOL fromFound = NO;
            BOOL tillFound = NO;
            while([rs next]){
                NSMutableDictionary *correctDict = [[NSMutableDictionary alloc] init];
                [correctDict setValue:[[[CLLocation alloc] initWithLatitude:[rs doubleForColumn:@"LAT"] longitude:[rs doubleForColumn:@"LON"]] autorelease] forKey:@"pointCoordinate"];
                [correctDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"CONNECTIONS"]]forKey:@"CONNECTIONS"];
                [correctDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"PARENT_ID"]] forKey:@"PARENT"];
                
                if ([rs intForColumn:@"ID"] == tillNode && fromNode == -1) {
                    rs = nil;
                }else if([rs intForColumn:@"CONNECTIONS"] == fromNode && tillNode == -1){
                    rs = nil;
                }else if([rs intForColumn:@"ID"] == tillNode && fromNode != -1){
                    tillFound = YES;
                    if(fromFound)rs = nil;
                }else if([rs intForColumn:@"CONNECTIONS"] == fromNode && tillNode != -1){
                    fromFound = YES;
                    if(tillFound)rs = nil;
                }
                if(fromFound || tillFound){
                    [allPoints addObject:correctDict];
                }
                [correctDict release];
                
            }
        }
    }else{
        if(dao){
            BOOL fromFound = NO;
            BOOL tillFound = NO;
            NSString *query = [NSString stringWithFormat:@"SELECT  * FROM pathNode WHERE PARENT_ID = %i ORDER BY ID DESC", parent];
            FMResultSet *rs = [dao executeQuery:query];
            while([rs next]){
                NSMutableDictionary *correctDict = [[NSMutableDictionary alloc] init];
                [correctDict setValue:[[[CLLocation alloc] initWithLatitude:[rs doubleForColumn:@"LAT"] longitude:[rs doubleForColumn:@"LON"]] autorelease] forKey:@"pointCoordinate"];
                [correctDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"CONNECTIONS"]]forKey:@"CONNECTIONS"];
                [correctDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"PARENT_ID"]] forKey:@"PARENT"];
                
                if ([rs intForColumn:@"CONNECTIONS"] == tillNode && fromNode == -1) {
                    rs = nil; 
                }else if([rs intForColumn:@"CONNECTIONS"] == fromNode && tillNode == -1){
                    rs = nil;
                }else if([rs intForColumn:@"CONNECTIONS"] == tillNode && fromNode != -1){
                    tillFound = YES;
                    if(fromFound)rs = nil;
                }else if([rs intForColumn:@"CONNECTIONS"] == fromNode && tillNode != -1){
                    fromFound = YES;
                    if(tillFound)rs = nil;
                }
                if(fromFound || tillFound){
                    [allPoints addObject:correctDict];
                }
                [correctDict release];
                
                
            }
        }
    }
    return [allPoints autorelease];
}
/*************
 -(NSNumber *)distanceBetweenPath:(int)pathOne andPath:(int)PathTwo
 Returns a NSNumber of the distance between two paths with IDs pathOne and pathTwo
 ************/
-(NSNumber *)distanceBetweenPath:(int)pathOne andPath:(int)PathTwo{
    FMResultSet *rs = [dao executeQuery:[NSString stringWithFormat:@"select * from pathNode WHERE parent_ID = %i ORDER BY ID ASC LIMIT 1", pathOne]];
    double p1Lat, p1Lon, p2Lat, p2Lon;
    while([rs next]){
        p1Lat = [rs doubleForColumn:@"LAT"];
        p1Lon = [rs doubleForColumn:@"LON"];
    }
    rs = [dao executeQuery:[NSString stringWithFormat:@"select * from pathNode WHERE parent_ID = %i AND CONNECTIONS = %i ORDER BY ID ASC LIMIT 1", pathOne, PathTwo]];
    while([rs next]){
        p2Lat = [rs doubleForColumn:@"LAT"];
        p2Lon = [rs doubleForColumn:@"LON"];
    }
    
    CLLocation *p1 = [[[CLLocation alloc]initWithLatitude:p1Lat longitude:p1Lon] autorelease];
    CLLocation *p2 = [[[CLLocation alloc]initWithLatitude:p2Lat longitude:p2Lon] autorelease];
    
    CLLocationDistance dist = [p1 distanceFromLocation:p2] ;
    return [NSNumber numberWithDouble:dist];
}
CGFloat RadiansToDegrees(CGFloat radians)
{
    return radians * 180 / M_PI;
};

-(void)dealloc{
    [super dealloc];
    [dao release];
    dao = nil;
}
@end

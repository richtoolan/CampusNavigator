//
//  CNPathFinder.m
//  Campus Navigator
//
//  Created by Rich on 10/01/2013.
//  Copyright (c) 2013 UCC. All rights reserved.
//


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
//-(NSDictionary*)generatePathAndDirectionsDictionary:(int)org toDest:(int)dest andUserLoc:(CLLocationCoordinate2D)userLoc{
//    NSArray *points = [self getNodesForPathFrom:org toDest:dest an];
    //check for correct ordering of objects in array

       


    
    
    
    
    
 //   return nil;
//}
-(float)radiandsToDegrees:(float)x{
    return (x * 180.0 / M_PI);
}
-(float)degreesToRadians:(float)x{
    return (M_PI * x / 180.0);
}
-(NSDictionary *)getNearestPointForLat:(double)lat AndLon:(double)lon{
    return [dao getNearestPointForLat:lat AndLon:lon];
}
-(NSDictionary *)getNearestBuidingForString:(NSString *)building{
    NSDictionary *returnDict = [dao getNearestBuidingForString:building];
    buildingNearPointID = [returnDict objectForKey:@"ID"];
    //get the co-ordinate
    return returnDict;
}
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
        //float anglePath1Radians = atan(ppCoord2.coordinate.longitude - ppCoord1.coordinate.longitude / ppCoord2.coordinate.latitude - ppCoord1.coordinate.latitude);
        //float anglePath2Radians = atan(pCoord2.coordinate.longitude - pCoord1.coordinate.longitude / pCoord2.coordinate.latitude - pCoord1.coordinate.latitude);
        //angle = 180-angle;
        float angle ;
        //float deltaY = pCoord2.coordinate.longitude - ppCoord2.coordinate.longitude;
        //float deltaX = pCoord2.coordinate.latitude - ppCoord2.coordinate.latitude;
        
        float ppBearing = [self getHeadingForDirectionFromCoordinate:ppCoord2 toCoordinate:ppCoord1];
        float pBearing = [self getHeadingForDirectionFromCoordinate:pCoord2 toCoordinate:pCoord1];
        angle = pBearing - ppBearing;
        angle = angle <0?angle+=360:angle;
        
       // float anglePath1Radians = atan2f(ppCoord2.coordinate.longitude - ppCoord1.coordinate.longitude , ppCoord2.coordinate.latitude - ppCoord1.coordinate.latitude);
       // float anglePath2Radians = atan2f(pCoord2.coordinate.longitude - pCoord1.coordinate.longitude , pCoord2.coordinate.latitude - pCoord1.coordinate.latitude);
        
                   float anglePath1Radians = atan2f( ppCoord1.coordinate.longitude -ppCoord2.coordinate.longitude,   ppCoord1.coordinate.latitude- ppCoord2.coordinate.latitude);
             float anglePath2Radians = atan2f( pCoord1.coordinate.longitude - pCoord2.coordinate.longitude , pCoord1.coordinate.latitude -pCoord2.coordinate.latitude);
             
        
        //float path1Dx =  ppCoord2.coordinate.latitude - ppCoord1.coordinate.latitude;
        //float path1Dy =  ppCoord2.coordinate.longitude - ppCoord1.coordinate.longitude;
        
        //float path2Dx =  pCoord2.coordinate.latitude - pCoord1.coordinate.latitude;
        //float path2Dy =  pCoord2.coordinate.longitude - pCoord1.coordinate.longitude;
        
        //float path1Magnitude = sqrt(path1Dx * path1Dx + path1Dy * path1Dy);
        //float path2Magnitude = sqrt(path2Dx * path2Dx + path2Dy * path2Dy);
        
        //float dotProduct = path1Dx * path2Dx + path1Dy * path2Dy;
        
        //float angleDifferenceRadians = [self radiandsToDegrees:( acos(dotProduct / (path1Magnitude * path2Magnitude)))];
        
        float angleDifferenceRadians =  [self radiandsToDegrees:(anglePath1Radians - anglePath2Radians)];
            if(angleDifferenceRadians< 0){
                angleDifferenceRadians=-angleDifferenceRadians;
                
            }
            //angleDifferenceRadians += ppBearing;
        NSLog(@"Bearing of path line are %@ %f %@ %f with turn angle %f Other angle is %f",ppParent , ppBearing, pParent, pBearing, angle, angleDifferenceRadians);
        //float angle;
        //if(ppBearing > pBearing){
        //    angle =ppBearing - pBearing;
        //}else{
        //    angle = pBearing - ppBearing;
        //}
        //angle  = headingInDegrees(ppCoord2.coordinate.latitude, ppCoord2.coordinate.longitude, pCoord2.coordinate.latitude, ppCoord2.coordinate.longitude);
        //NSLog(@"Turn angle is: %f and path bearing is %f and previos path bearing is %f", angle, pBearing, ppBearing);
            [pathAction addObject:[[CNPathAction alloc] initWithFromPath:ppParent toPath:pParent withAngle:angle andLocation: ppCoord1]];
       
        }
    }
    return [pathAction autorelease];
}
-(NSArray *)getNearestBuildings:(CLLocationCoordinate2D)userLoc withBearing:(double)bearing{
    return [dao get:4 NearBuildingsWithLat:userLoc.latitude andLon:userLoc.longitude];
}
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
    
    //[[points reverseObjectEnumerator] allObjects];
    for(int index = 1; index < [points count]; index ++){
        if([[points objectAtIndex:index] count]> 0 && [[points objectAtIndex:index-1] count]> 0){
        int previousPathPointCount = [[points objectAtIndex:index-1] count];
        int currentPathCount = [[points objectAtIndex:index] count];
        
        //CLLocation *firstPPath= [[[points objectAtIndex:index-1] objectAtIndex:0] objectForKey:@"pointCoordinate"];
        CLLocation *lastPPath= [[[points objectAtIndex:index-1] objectAtIndex:previousPathPointCount-1] objectForKey:@"pointCoordinate"];
        CLLocation *firstCPath= [[[points objectAtIndex:index] objectAtIndex:0]objectForKey:@"pointCoordinate"];
        CLLocation *lastCPath= [[[points objectAtIndex:index] objectAtIndex:currentPathCount-1]objectForKey:@"pointCoordinate"];
        double lPToFC, lpToLC;
        //fpToFC = [firstPPath distanceFromLocation:firstCPath];
        //fpToLC = [firstPPath distanceFromLocation:lastCPath];
        lPToFC = [lastPPath distanceFromLocation:firstCPath];
        lpToLC = [lastPPath distanceFromLocation:lastCPath];
        
        if(lPToFC < lpToLC  ){
            //do nothing this is OK.
            //NSArray* reversedArray = [[startArray reverseObjectEnumerator] allObjects];
            //[pointM replaceObjectAtIndex:index withObject:[[[points objectAtIndex:index] reverseObjectEnumerator] allObjects]];
            //if(index == 1){
            //[pointM replaceObjectAtIndex:index-1 withObject:[[[points objectAtIndex:index-1] reverseObjectEnumerator] allObjects]];
        }
        else{
            //assert([[points objectAtIndex:index] isEqual:[pointM objectAtIndex:index]]);
            //NSLog(@"PM %@", [pointM objectAtIndex:index]);
            [pointM replaceObjectAtIndex:index withObject:[[[points objectAtIndex:index] reverseObjectEnumerator] allObjects]];
            
            //assert(![[points objectAtIndex:index] isEqual:[pointM objectAtIndex:index]]);
            //NSLog(@"PM %@", [pointM objectAtIndex:index]);
            //assert([[points objectAtIndex:index] isEqual:[pointM objectAtIndex:index]]);
        }
        
    
}
    }
    //assert([points isEqual:pointM]);
    points = nil;
    points = pointM;
    return pointM;
    }
    return nil;
}
//test

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



//test
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
    //NSLog(@"PM %@", [pointsArr objectAtIndex:[pointsArr count]-1]);
    
    //NSArray *array = [self generateDirectionObjects:pointsArr];
    //for(CNPathAction *vin in array){
        
        //NSLog(@"%@", [vin info]);
        
    //}
    return [[self compareAndUpdateCoordinates:pointsArr] retain];
}


-(NSArray *)pathFrom:(int)node to:(int)endNode{
    NSLog(@"DEGUB PATH %@", [graph shortestRouteFromNode:[graph nodeInGraphWithIdentifier:[NSString stringWithFormat:@"%iX", node]] toNode:[graph nodeInGraphWithIdentifier:[NSString stringWithFormat:@"%iX", endNode]]]);
//NSLog(@"DEGUB PATH %@", [secondGraph shortestRouteFromNode:[secondGraph nodeInGraphWithIdentifier:[[NSNumber numberWithInt:node] stringValue]] toNode:[secondGraph nodeInGraphWithIdentifier:[[NSNumber numberWithInt:endNode] stringValue]]]);
    
    return [[graph shortestRouteFromNode:[graph nodeInGraphWithIdentifier:[NSString stringWithFormat:@"%iX", node]] toNode:[graph nodeInGraphWithIdentifier:[NSString stringWithFormat:@"%iX", endNode]]] steps];
    
}

-(void)generatePathGraph{
    //NSMutableArray *nodeArray = [[NSMutableArray alloc] initWithCapacity:50];
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
        //NSLog(@"ID",)
        parentNodeX = [graph nodeInGraphWithIdentifier:[NSString stringWithFormat:@"%iX",[rs intForColumn:@"PARENT_ID"]]];
        parentNodeY = [graph nodeInGraphWithIdentifier:[NSString stringWithFormat:@"%iY",[rs intForColumn:@"PARENT_ID"]]];
        connectionNodeX = [graph nodeInGraphWithIdentifier:[NSString stringWithFormat:@"%iX",[rs intForColumn:@"CONNECTIONS"]]];
        connectionNodeY = [graph nodeInGraphWithIdentifier:[NSString stringWithFormat:@"%iY",[rs intForColumn:@"CONNECTIONS"]]];
        CLLocation *conLoc = [[CLLocation alloc] initWithLatitude:[rs doubleForColumn:@"LAT"] longitude:[rs doubleForColumn:@"LON"]];
        NSLog(@"Distances are %f %f", [parentNodeY.coordinate distanceFromLocation:conLoc],[parentNodeX.coordinate distanceFromLocation:conLoc]);
        //if the connection is closest to the connectionNodeX then we're nearer to the X node.
        if([connectionNodeX.coordinate distanceFromLocation:conLoc] < [connectionNodeY.coordinate distanceFromLocation:conLoc]  ){
            //we're dealing with con node x
            
            [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:[NSString stringWithFormat:@"%iX-%iX", [rs intForColumn:@"PARENT_ID"], [rs intForColumn:@"CONNECTIONS"]]  andWeight:[NSNumber numberWithDouble:[parentNodeX.coordinate distanceFromLocation:conLoc]]]
            fromNode:parentNodeX toNode:connectionNodeX ];
            [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:[NSString stringWithFormat:@"%iY-%iX", [rs intForColumn:@"PARENT_ID"], [rs intForColumn:@"CONNECTIONS"]]  andWeight:[NSNumber numberWithDouble:[parentNodeY.coordinate distanceFromLocation:conLoc]] ]
                               fromNode:parentNodeY toNode:connectionNodeX ];
             /*
            [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:[NSString stringWithFormat:@"%iX-%iX", [rs intForColumn:@"PARENT_ID"], [rs intForColumn:@"CONNECTIONS"]]  andWeight:[NSNumber numberWithInt:1]]
                               fromNode:parentNodeX toNode:connectionNodeX ];
            [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:[NSString stringWithFormat:@"%iY-%iX", [rs intForColumn:@"PARENT_ID"], [rs intForColumn:@"CONNECTIONS"]]  andWeight:[NSNumber numberWithInt:1] ]
                               fromNode:parentNodeY toNode:connectionNodeX ];
            */
        }else{
            
            [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:[NSString stringWithFormat:@"%iX-%iY", [rs intForColumn:@"PARENT_ID"], [rs intForColumn:@"CONNECTIONS"]]  andWeight:[NSNumber numberWithDouble:[parentNodeX.coordinate distanceFromLocation:conLoc]]  ]
                               fromNode:parentNodeX toNode:connectionNodeY ];
            [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:[NSString stringWithFormat:@"%iY-%iY", [rs intForColumn:@"PARENT_ID"], [rs intForColumn:@"CONNECTIONS"]]  andWeight:[NSNumber numberWithDouble:[parentNodeY.coordinate distanceFromLocation:conLoc]]  ]
                               fromNode:parentNodeY toNode:connectionNodeY ];
             /*
            [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:[NSString stringWithFormat:@"%iX-%iY", [rs intForColumn:@"PARENT_ID"], [rs intForColumn:@"CONNECTIONS"]]  andWeight:[NSNumber numberWithInt:1]  ]
                               fromNode:parentNodeX toNode:connectionNodeY ];
            [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:[NSString stringWithFormat:@"%iY-%iY", [rs intForColumn:@"PARENT_ID"], [rs intForColumn:@"CONNECTIONS"]]  andWeight:[NSNumber numberWithInt:1]]
                               fromNode:parentNodeY toNode:connectionNodeY ];
             */
           //we're dealing with con node y
        }
        
    }
            //[nodeArray insertObject:parentNode atIndex:[rs intForColumn:@"PARENT_ID"]-1];
          
        ////parentNode = [graph nodeInGraphWithIdentifier:[NSString stringWithFormat:@"%i",[rs intForColumn:@"PARENT_ID"]]];
        
        /*if([graph nodeInGraphWithIdentifier:[NSString stringWithFormat:@"%i",[rs intForColumn:@"CONNECTIONS"]]] == nil){
            connectionNode = [PESGraphNode nodeWithIdentifier:[NSString stringWithFormat:@"%i",[rs intForColumn:@"CONNECTIONS"]]];
            parentNode.coordinate = [[CLLocation alloc] initWithLatitude:0.0 longitude:0.0];
            //[nodeArray insertObject:connectionNode atIndex:[rs intForColumn:@"CONNECTIONS"]-1];
            
        }else{
            connectionNode = [graph nodeInGraphWithIdentifier:[NSString stringWithFormat:@"%i",[rs intForColumn:@"CONNECTIONS"]]];
        }
        [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:[NSString stringWithFormat:@"%i-%i", [rs intForColumn:@"PARENT_ID"], [rs intForColumn:@"CONNECTIONS"]] andWeight:[self distanceBetweenPath:[rs intForColumn:@"PARENT_ID"] andPath:[rs intForColumn:@"CONNECTIONS"]]]  fromNode:parentNode toNode:connectionNode ];
        
        
    }
    rs = [dao executeQuery:@"select * from pathNode WHERE CONNECTIONS != 0 ORDER BY PARENT_ID DESC"];
    while([rs next]){
        PESGraphNode *parentNode;
        PESGraphNode *connectionNode;
        if([secondGraph nodeInGraphWithIdentifier:[NSString stringWithFormat:@"%i",[rs intForColumn:@"PARENT_ID"]]] == nil){
            parentNode = [PESGraphNode nodeWithIdentifier:[NSString stringWithFormat:@"%i",[rs intForColumn:@"PARENT_ID"]]];
            //[nodeArray insertObject:parentNode atIndex:[rs intForColumn:@"PARENT_ID"]-1];
        }else{
            
            parentNode = [graph nodeInGraphWithIdentifier:[NSString stringWithFormat:@"%i",[rs intForColumn:@"PARENT_ID"]]];
        }
        if([secondGraph nodeInGraphWithIdentifier:[NSString stringWithFormat:@"%i",[rs intForColumn:@"CONNECTIONS"]]] == nil){
            connectionNode = [PESGraphNode nodeWithIdentifier:[NSString stringWithFormat:@"%i",[rs intForColumn:@"CONNECTIONS"]]];
            //[nodeArray insertObject:connectionNode atIndex:[rs intForColumn:@"CONNECTIONS"]-1];
            
        }else{
            connectionNode = [graph nodeInGraphWithIdentifier:[NSString stringWithFormat:@"%i",[rs intForColumn:@"CONNECTIONS"]]];
        }
        [secondGraph addBiDirectionalEdge:[PESGraphEdge edgeWithName:[NSString stringWithFormat:@"%i-%i", [rs intForColumn:@"PARENT_ID"], [rs intForColumn:@"CONNECTIONS"]] andWeight:[self distanceBetweenPath:[rs intForColumn:@"PARENT_ID"] andPath:[rs intForColumn:@"CONNECTIONS"]]]  fromNode:parentNode toNode:connectionNode ];
        
        
    }
    rs = [dao executeQuery:@"select * from pathNode WHERE CONNECTIONS != 0 ORDER BY RANDOM()"];
    while([rs next]){
        PESGraphNode *parentNode;
        PESGraphNode *connectionNode;
        if([graph nodeInGraphWithIdentifier:[NSString stringWithFormat:@"%i",[rs intForColumn:@"PARENT_ID"]]] == nil){
            parentNode = [PESGraphNode nodeWithIdentifier:[NSString stringWithFormat:@"%i",[rs intForColumn:@"PARENT_ID"]]];
            //[nodeArray insertObject:parentNode atIndex:[rs intForColumn:@"PARENT_ID"]-1];
        }else{
            
            parentNode = [graph nodeInGraphWithIdentifier:[NSString stringWithFormat:@"%i",[rs intForColumn:@"PARENT_ID"]]];
        }
        if([graph nodeInGraphWithIdentifier:[NSString stringWithFormat:@"%i",[rs intForColumn:@"CONNECTIONS"]]] == nil){
            connectionNode = [PESGraphNode nodeWithIdentifier:[NSString stringWithFormat:@"%i",[rs intForColumn:@"CONNECTIONS"]]];
            //[nodeArray insertObject:connectionNode atIndex:[rs intForColumn:@"CONNECTIONS"]-1];
            
        }else{
            connectionNode = [graph nodeInGraphWithIdentifier:[NSString stringWithFormat:@"%i",[rs intForColumn:@"CONNECTIONS"]]];
        }
        [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:[NSString stringWithFormat:@"%i-%i", [rs intForColumn:@"PARENT_ID"], [rs intForColumn:@"CONNECTIONS"]] andWeight:[self distanceBetweenPath:[rs intForColumn:@"PARENT_ID"] andPath:[rs intForColumn:@"CONNECTIONS"]]]  fromNode:parentNode toNode:connectionNode ];
        
        
    }
    rs = [dao executeQuery:@"select * from pathNode WHERE CONNECTIONS != 0 ORDER BY RANDOM()"];
    while([rs next]){
        PESGraphNode *parentNode;
        PESGraphNode *connectionNode;
        if([secondGraph nodeInGraphWithIdentifier:[NSString stringWithFormat:@"%i",[rs intForColumn:@"PARENT_ID"]]] == nil){
            parentNode = [PESGraphNode nodeWithIdentifier:[NSString stringWithFormat:@"%i",[rs intForColumn:@"PARENT_ID"]]];
            //[nodeArray insertObject:parentNode atIndex:[rs intForColumn:@"PARENT_ID"]-1];
        }else{
            
            parentNode = [graph nodeInGraphWithIdentifier:[NSString stringWithFormat:@"%i",[rs intForColumn:@"PARENT_ID"]]];
        }
        if([secondGraph nodeInGraphWithIdentifier:[NSString stringWithFormat:@"%i",[rs intForColumn:@"CONNECTIONS"]]] == nil){
            connectionNode = [PESGraphNode nodeWithIdentifier:[NSString stringWithFormat:@"%i",[rs intForColumn:@"CONNECTIONS"]]];
            //[nodeArray insertObject:connectionNode atIndex:[rs intForColumn:@"CONNECTIONS"]-1];
            
        }else{
            connectionNode = [graph nodeInGraphWithIdentifier:[NSString stringWithFormat:@"%i",[rs intForColumn:@"CONNECTIONS"]]];
        }
        [secondGraph addBiDirectionalEdge:[PESGraphEdge edgeWithName:[NSString stringWithFormat:@"%i-%i", [rs intForColumn:@"PARENT_ID"], [rs intForColumn:@"CONNECTIONS"]] andWeight:[self distanceBetweenPath:[rs intForColumn:@"PARENT_ID"] andPath:[rs intForColumn:@"CONNECTIONS"]]]  fromNode:parentNode toNode:connectionNode ];
        
        
    }
    //for(PESGraphRouteStep *node in graph.nodes){
    //    NSLog(@"Graph is: %@", node.additionalData );
    //}
     */
    NSLog(@"%@", graph.description);

}

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
            //NSLog(@"%@", [db lastErrorMessage]);
            //[query release];
            NSLog(@"From node %i Till Node %i", fromNode, tillNode);
            
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
        //NSLog(@"%@", [d databasePath]);
        tillNode = [buildingNearPointID intValue];
        if(dao){
            NSString *query = [NSString stringWithFormat:@"SELECT  * FROM pathNode WHERE PARENT_ID = %i", parent];
            FMResultSet *rs = [dao executeQuery:query];
            BOOL fromFound = NO;
            BOOL tillFound = NO;
            //NSLog(@"%@", [db lastErrorMessage]);
            //[query release];
            NSLog(@"From node %i Till Node %i", fromNode, tillNode);
            
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
            //parse results into array
        }
    }else{
        if(dao){
            BOOL fromFound = NO;
            BOOL tillFound = NO;
            NSString *query = [NSString stringWithFormat:@"SELECT  * FROM pathNode WHERE PARENT_ID = %i ORDER BY ID DESC", parent];
            FMResultSet *rs = [dao executeQuery:query];
            //NSLog(@"%@", [db lastErrorMessage]);
            //[query release];
            NSLog(@"From node %i Till Node %i", fromNode, tillNode);
            
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
            //parse results into array
        }
    }
    
    
    
    //NSDate *methodFinish = [NSDate date];
    //bNSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:start];
    
    //NSLog(@"Query took: %f", executionTime);
    //[queryTime]
    return [allPoints autorelease];
}
-(NSNumber *)distanceBetweenPath:(int)pathOne andPath:(int)PathTwo{
    //get pathOne first node;
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
    //[rs release];
    //[p1 release];
    //[p2 release];
    return [NSNumber numberWithDouble:dist];
    //get pathTwo first node;
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

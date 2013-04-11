//
//  CNNavigator.m
//  Campus Navigator
//
//  Created by Rich on 08/02/2013.
//  Copyright (c) 2013 UCC. All rights reserved.
//

#import "CNNavigator.h"
#import "CNOpenEars.h"
#import "CNPathFinder.h"
#import "CNRootViewController.h"
#import "CNPathAction.h"
#import "CNLanguageModel.h"
#define NEAR_DISTANCE 7
#define ACTION_DISTNACE 5
@implementation CNNavigator
@synthesize langMod;
@synthesize delegate;
@synthesize openears;
@synthesize man;
@synthesize pathFinder;

-(id)init{
    self = [super init];
    if(self){
        self.pathFinder = [[CNPathFinder alloc] init];
        self.man = [[CLLocationManager alloc] init];

        self.man.delegate = self;
        mostRecentLocation = [[CLLocation alloc] init];
        waitingForLoc = NO;
        isNavigating = NO;
        isApproachingTurn = NO;
        notifiedAboutApproachingTurn = NO;
        currentPathIndex = 0;
        userWarnedAboutDest = NO;
        detectedUserPassedTurn = NO;
        [self.man startUpdatingLocation];
        [self.man startUpdatingHeading];
    
    }
    return self;
}
/***********************
 *
 * beginNavigation - performs a DB lookup for a location and
 * returns the nearest co-ords for that and then navigates to
 * it
 *
***********************/
-(void)beginNavigationToLocation:(NSString *)location{
    [self.man startUpdatingLocation];
    [self.man startUpdatingHeading];
    
    self.langMod = [[CNLanguageModel alloc] initWithLevel:1 andOE:self.openears andIndex:currentPathIndex];
    timeSinceLastTurn = [[NSDate date] timeIntervalSince1970];
    locationString = location;
    if(mostRecentLocation.coordinate.latitude != 0 && mostRecentLocation.coordinate.longitude != 0){
        //NSLog(@"%@", [[[self.pathFinder getNearestPointForLat:mostRecentLocation.coordinate.latitude AndLon:mostRecentLocation.coordinate.longitude] objectAtIndex:0] objectForKey:@"parentID"] );
        pathsArray = [[self.pathFinder getNodesForPathFrom:[[[self.pathFinder getNearestPointForLat:mostRecentLocation.coordinate.latitude AndLon:mostRecentLocation.coordinate.longitude]  objectForKey:@"parentID"] integerValue] toDest:[[[self.pathFinder getNearestBuidingForString:location] objectForKey:@"parentID"] integerValue] andUserLoc:mostRecentLocation.coordinate] retain];
        pathsArray = [self.pathFinder compareAndUpdateCoordinates:pathsArray];
        if([pathsArray count] > 0){
            [self.delegate setPathObject:pathsArray];
            turnActionsArray = [[[NSMutableArray alloc]initWithArray:[self.pathFinder generateDirectionObjects:pathsArray]]retain];
            NSDictionary *lastPath = [[pathsArray objectAtIndex:([pathsArray count] -1)]
                                  objectAtIndex:[[pathsArray objectAtIndex:([pathsArray count] -1)] count]-1 ];
            [turnActionsArray addObject:[[CNPathAction alloc] initWithFromPathDestandLocation:[lastPath objectForKey:@"pointCoordinate"]]];
            for (CNPathAction *path in turnActionsArray){
                //NSLog(@"%@",[path info]);
            }
            upComingAction = [turnActionsArray objectAtIndex:currentPathIndex];
            currentPath = [pathsArray objectAtIndex:currentPathIndex];
            isNavigating = YES;
            detectedUserPassedTurn = NO;
        }else{
            [self.openears speakSentence:@"Fatal Error Occured"];
        }
    }else{
        locationString = location;
        waitingForLoc = YES;
    }
}
/***********************
 *
 * 
 * Delegate method
 * 
 *
 ***********************/
- (void)locationManager:(CLLocationManager *)manager
didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    mostRecentLocation = [newLocation retain];
    if(waitingForLoc){
        waitingForLoc = NO;
        [self beginNavigationToLocation:locationString];
    }
    if(isNavigating){
        //handle potential checks here.
        [self navigationLoop];
    }
    if(isApproachingTurn){
        [self handleApproachingTurn];
    }

    
}
/***********************
 *
 *
 * Delegate method
 *
 *
 ***********************/
- (void) locationManager:(CLLocationManager *)manager
        didUpdateHeading:(CLHeading *)newHeading{
    //NSLog(@"HEading is %f", newHeading.trueHeading);
    mostRecentHeading = [newHeading retain];
}
/***********************
 *
 * navigtionLoop - called everytime a new location is returned to 
 * the delegate method. It performs checks for location, bearing
 * and upcoming turnings.
 *
 ***********************/
-(void)navigationLoop{
    
    //NSLog(@"Distnace is %f", distance );
    //check user is going the correct way/
    //use compass
    //get path heading
    //mostRecentHeading;
    
    //Check user hasn't gone off course
    //check how close user is to destination/next action
   
    //mostRecentLocation;
    //check distance between points and path
    //NSLog(@"cur time%f prev time %f sum %f", [[NSDate date] timeIntervalSince1970],timeSinceLastTurn, [[NSDate date] timeIntervalSince1970] - timeSinceLastTurn);
    //check how close user is to destination/next action
    NSLog(@"Comparing path %i and %i", [[[self.pathFinder getNearestPointForLat:mostRecentLocation.coordinate.latitude AndLon:mostRecentLocation.coordinate.longitude] objectForKey:@"parentID"] intValue], [upComingAction.fromPath intValue]);
    if([[[self.pathFinder getNearestPointForLat:mostRecentLocation.coordinate.latitude AndLon:mostRecentLocation.coordinate.longitude] objectForKey:@"parentID"] intValue] != [upComingAction.fromPath intValue] && ![upComingAction.turnString isEqualToString:@"DEST"]){
        if(detectedUserPassedTurn ){
            //currentPathIndex ++;
            detectedUserPassedTurn = NO;
            //if(currentPathIndex > [pathsArray count]){
                //we've reached our dest
                //[self stopNav];
                
            //}else{
            //    upComingAction = [turnActionsArray objectAtIndex:currentPathIndex];
            //    currentPath = [pathsArray objectAtIndex:currentPathIndex];
            //}
        }else{
            detectedUserPassedTurn = YES;
        }
        NSLog(@"Paths don't match progress user to next turning.");
    }else{
        NSLog(@"Paths match all is OK");
    }
    CLLocationDistance distance= [upComingAction.turnLocation distanceFromLocation:mostRecentLocation];
    
    [self.langMod updateToUserLoc:distance andTurnString:upComingAction.turnString andIndex:currentPathIndex];
    if(distance <= NEAR_DISTANCE && !isApproachingTurn && ![upComingAction.turnString isEqualToString:@"DEST"]){
        isApproachingTurn = YES;

        //let user know they're approaching a turning
        //let them know the distance
        //set up seperate turning loop
    }
    else if(distance <= NEAR_DISTANCE && [upComingAction.turnString isEqual:@"DEST"]){
        if(!userWarnedAboutDest){
            userWarnedAboutDest = YES;
            isApproachingTurn = YES;
        //[self.openears speakSentence:[NSString stringWithFormat:@"You are now %.0f meters or less from the %@, continue following the path.", distance, locationString]];
        }
    }
    
    
}
/***********************
 *
 * handleApproachingTurn - If a turn is approaching this will be called
 * checks how close the user is to the turn and update variables/gives
 * voice feedback accordingly
 *
 ***********************/
-(void)handleApproachingTurn{
    //handle potential race condition
    if(isApproachingTurn){
        CLLocationDistance distance= [upComingAction.turnLocation distanceFromLocation:mostRecentLocation];
        if(distance <= ACTION_DISTNACE){
            if(isApproachingTurn){
                timeSinceLastTurn = [[NSDate date] timeIntervalSince1970];
                isApproachingTurn = NO;
                currentPathIndex ++;
                
            }
            //[self.openears speakSentence:[NSString stringWithFormat:@"Go %@ now.", upComingAction.turnString]];
            
            notifiedAboutApproachingTurn = NO;
            if(userWarnedAboutDest){
                [self.openears speakSentence:@"You've arrived"];
                [self stopNav];
                
            }
            if(currentPathIndex >= [pathsArray count]){
                //we've reached our dest
                [self.openears speakSentence:@"You've arrived."];
                [self stopNav];
            
            }else{
                upComingAction = [turnActionsArray objectAtIndex:currentPathIndex];
                currentPath = [pathsArray objectAtIndex:currentPathIndex];
            }
            
            
            //tell user to now turn left
            //
        }else if(distance <= NEAR_DISTANCE){
            if(!notifiedAboutApproachingTurn){
                notifiedAboutApproachingTurn = YES;
                if([upComingAction.turnString isEqual:@"STRAIGHT"]){
                    //[self.openears speakSentence:[NSString stringWithFormat:@"You're less than %.0f meters from an intersection, continue straight", distance]];
                }else{
                    //[self.openears speakSentence:[NSString stringWithFormat:@"You're less than %.0f meters from a %@ turn.", distance, upComingAction.turnString]];
                }
            }
            //check if user has been told
            //tell them if not
        }
    }
}
/***********************
 *
 *
 * Returns a bool on whether the navigator is navigating
 *
 *
 ***********************/
-(BOOL)isNavigating{
    return isNavigating;
}
-(void)voiceStringFromUser:(NSString *)voice{
    //handle voice strings from user once in navagition
    //possibly cancel stop
    //re navigite
}

-(NSString *)getFourNearestWithDirections{
    NSArray *values;
    NSString *sentence = [@"The four nearest buildings are" retain];
    if(mostRecentLocation){
         values = (NSArray *)[self.pathFinder getNearestBuildings:mostRecentLocation.coordinate withBearing:mostRecentHeading.trueHeading];
    
    }else{
         values = (NSArray *)[self.pathFinder getNearestBuildings:CLLocationCoordinate2DMake(51.89348,-8.492082) withBearing:mostRecentHeading.trueHeading];
        
    }
    for(NSDictionary *value in values) {
        sentence = [NSString stringWithFormat:@"%@ %@ %.0f meters",sentence, [value objectForKey:@"buildingName"],ceil([[value objectForKey:@"buildingDistance"] doubleValue]) ];
    }
    return sentence;
}

/***********************
 *
 * stopNav - Handles stopping of navigation and location services
 * updates variables accordingly.
 *
 *
 ***********************/
-(void)stopNav{
    //disable timers
    //empty arrays
    //
    [self.openears speakTerminationSentence:@"Navigation stopped"];
    [self.man stopUpdatingLocation];
    [self.man stopUpdatingHeading];
    [self.langMod reset];
    waitingForLoc = NO;
    isNavigating = NO;
    isApproachingTurn = NO;
    notifiedAboutApproachingTurn = NO;
    userWarnedAboutDest = NO;
    
}
/***********************
 *
 * getUserLocation - Returns a CLLocation of the users most recent
 * geographic location.
 *
 *
 ***********************/
-(CLLocation *)getUserLocation{
    if(mostRecentLocation){
        return mostRecentLocation;
    }else{
        //center of quad
        return [[[CLLocation alloc] initWithLatitude:51.893483 longitude:-8.492083] autorelease];
    }
    
}
@end

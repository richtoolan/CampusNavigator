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
#define STAIR_CASE 1
#define ROAD_CROSSING 2
#define NEAR_DISTANCE 20
#define ACTION_DISTNACE 12
@implementation CNNavigator
@synthesize langMod;
@synthesize delegate;
@synthesize openears;
@synthesize locationManager;
@synthesize pathFinder;
int warningNodeID;
-(id)init{
    self = [super init];
    if(self){
        self.pathFinder = [[CNPathFinder alloc] init];
        self.locationManager = [[CLLocationManager alloc] init];

        self.locationManager.delegate = self;
        mostRecentLocation = [[CLLocation alloc] init];
        waitingForLoc = NO;
        isNavigating = NO;
        isApproachingTurn = NO;
        notifiedAboutApproachingTurn = NO;
        currentPathIndex = 0;
        userWarnedAboutDest = NO;
        detectedUserPassedTurn = NO;
        warnedAboutApprochingDanger = NO;
        warningNodeID = 0;
        //DEMO CODE
        debug = NO;
        //
        //
        [self.locationManager startUpdatingLocation];
        [self.locationManager startUpdatingHeading];
    
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
    if(!debug){
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
    }else if(!timer){
        //timer = [[NSTimer scheduledTimerWithTimeInterval: 8.0 target: self
                                               //selector: @selector(mockLocation) userInfo: nil repeats: YES] retain];
    }
    self.langMod = [[CNLanguageModel alloc] initWithLevel:2 andOE:self.openears andIndex:currentPathIndex];
    timeSinceLastTurn = [[NSDate date] timeIntervalSince1970];
    locationString = location;
    if(mostRecentLocation.coordinate.latitude != 0 && mostRecentLocation.coordinate.longitude != 0){
        pathsArray = [[self.pathFinder getNodesForPathFrom:[[[self.pathFinder getNearestPointForLat:mostRecentLocation.coordinate.latitude AndLon:mostRecentLocation.coordinate.longitude]  objectForKey:@"parentID"] integerValue] toDest:[[[self.pathFinder getNearestBuidingForString:location] objectForKey:@"parentID"] integerValue] andUserLoc:mostRecentLocation.coordinate] retain];
        pathsArray = [self.pathFinder compareAndUpdateCoordinates:pathsArray];
        if([pathsArray count] > 0){
            [self.delegate setPathObject:pathsArray];
            turnActionsArray = [[[NSMutableArray alloc]initWithArray:[self.pathFinder generateDirectionObjects:pathsArray]]retain];
            NSDictionary *lastPath = [[pathsArray objectAtIndex:([pathsArray count] -1)]
                                  objectAtIndex:[[pathsArray objectAtIndex:([pathsArray count] -1)] count]-1 ];
            [turnActionsArray addObject:[[CNPathAction alloc] initWithFromPathDestandLocation:[lastPath objectForKey:@"pointCoordinate"]]];
            
            for (CNPathAction *path in turnActionsArray){
                
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
 * DEMO method
 *
 *
 ***********************/
- (void)mockLocation{
    if(currentPath != nil ){
        if(innerArray < [currentPath count]){
    [self locationManager:self.locationManager
      didUpdateToLocation:[[currentPath objectAtIndex:innerArray] objectForKey:@"pointCoordinate"]
             fromLocation:nil];
        [self.delegate centreOnPoint:[[currentPath objectAtIndex:innerArray] objectForKey:@"pointCoordinate"]];
    innerArray ++;
        }else{
            innerArray = 0;
            currentPathIndex ++;
            [self locationManager:self.locationManager
              didUpdateToLocation:[[currentPath objectAtIndex:innerArray] objectForKey:@"pointCoordinate"]
                     fromLocation:nil];
            
        }
    }else{
        if(currentPath == nil){
            [self locationManager:self.locationManager
              didUpdateToLocation:[[CLLocation alloc] initWithLatitude:51.893621 longitude:-8.499789]
                     fromLocation:nil];
        }
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
    ////NSLog(@"HEading is %f", newHeading.trueHeading);
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
    
    //check user is going the correct way/
    //use compass
    //get path heading
    //mostRecentHeading;
    
    //Check user hasn't gone off course
    //check how close user is to destination/next action
   
   int warning;
    NSLog(@"%@", [self.pathFinder getApproachingWarnings:mostRecentLocation.coordinate.latitude AndLon:mostRecentLocation.coordinate.longitude]);
    if((warning = [[[self.pathFinder getApproachingWarnings:mostRecentLocation.coordinate.latitude AndLon:mostRecentLocation.coordinate.longitude] objectForKey:@"WARNING"] intValue])  != 0 && warningNodeID != [[[self.pathFinder getApproachingWarnings:mostRecentLocation.coordinate.latitude AndLon:mostRecentLocation.coordinate.longitude] objectForKey:@"ID"] intValue]){
        warningNodeID = [[[self.pathFinder getApproachingWarnings:mostRecentLocation.coordinate.latitude AndLon:mostRecentLocation.coordinate.longitude] objectForKey:@"ID"] intValue];
        if (warnedAboutApprochingDanger) {
            warnedAboutApprochingDanger = NO;
        }else{
        if(warning == STAIR_CASE){
            warnedAboutApprochingDanger = YES;
            
            [self.openears speakWarningSentence:@"WARNING YOU're APPROACHING STAIRS"];
        }else if (warning == ROAD_CROSSING){
            warnedAboutApprochingDanger = YES;
             [self.openears speakWarningSentence:@"WARNING YOU'RE APPROACHING A ROAD CROSSING"];
        }
        }
    }
    detectedUserPassedTurn = NO;

    CLLocationDistance distance= [upComingAction.turnLocation distanceFromLocation:mostRecentLocation];
    
    [self.langMod updateToUserLoc:distance andTurnString:upComingAction.turnString andIndex:currentPathIndex];
    if(distance <= NEAR_DISTANCE && !isApproachingTurn && ![upComingAction.turnString isEqualToString:@"DEST"]){
        isApproachingTurn = YES;
        
    }
    else if(distance <= NEAR_DISTANCE && [upComingAction.turnString isEqual:@"DEST"]){
        if(!userWarnedAboutDest){
            userWarnedAboutDest = YES;
            isApproachingTurn = YES;
        
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
                warnedAboutApprochingDanger = NO;
                currentPathIndex ++;
                //DEMO CODE
                innerArray = 0;
                
            }
            //[self.openears speakSentence:[NSString stringWithFormat:@"Go %@ now.", upComingAction.turnString]];
            
            notifiedAboutApproachingTurn = NO;
            if(userWarnedAboutDest){
                [self.openears speakSentence:@"You've arrived"];
                
                [self stopNav];
                
            }
            if(currentPathIndex >= [pathsArray count] ){
                //we've reached our dest
                [self.openears speakSentence:@"You've arrived."];
                [self stopNav];
            
            }else{
                if([upComingAction.turnString isEqualToString:@"DEST"]){
                    [self.openears speakSentence:@"You've arrived."];
                    [self stopNav];
                }else{
                    upComingAction = [turnActionsArray objectAtIndex:currentPathIndex];
                    currentPath = [pathsArray objectAtIndex:currentPathIndex];
                }
            }
            
            
            //tell user to now turn left
            //
        }else if(distance <= NEAR_DISTANCE){
            if(!notifiedAboutApproachingTurn){
                notifiedAboutApproachingTurn = YES;
                if([upComingAction.turnString isEqual:@"STRAIGHT"]){
                    [self.openears speakSentence:[NSString stringWithFormat:@"You're less than %.0f meters from an intersection, continue straight", distance]];
                }else{
                    [self.openears speakSentence:[NSString stringWithFormat:@"You're less than %.0f meters from a %@ turn.", distance, upComingAction.turnString]];
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
        NSString *direction = @"Direction Unknown";
        if ([[value objectForKey:@"Angle"] floatValue] > 330 || [[value objectForKey:@"Angle"] floatValue] < 30) {
            direction = @"In Front of you.";
        }else  if ([[value objectForKey:@"Angle"] floatValue] < 150 && [[value objectForKey:@"Angle"] floatValue] > 30) {
            direction = @"To your Right.";
        }else  if ([[value objectForKey:@"Angle"] floatValue] < 210 && [[value objectForKey:@"Angle"] floatValue] > 150) {
            direction = @"Behind you.";
        }else  if ([[value objectForKey:@"Angle"] floatValue] > 210 && [[value objectForKey:@"Angle"] floatValue] < 330) {
            direction = @"To your Left.";
        }
        sentence = [NSString stringWithFormat:@"%@ %@ %.0f meters and %@",sentence, [value objectForKey:@"buildingName"],ceil([[value objectForKey:@"buildingDistance"] doubleValue]), direction ];
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
    [timer invalidate];
    timer = nil;
    innerArray = 0;
    [self.openears speakSentence:@"Navigation stopped"];
    [self.delegate giveStringLocation:@"STOP"];
    //[self.locationManager stopUpdatingLocation];
    //[self.locationManager stopUpdatingHeading];
    [self.langMod reset];
    waitingForLoc = NO;
    isNavigating = NO;
    isApproachingTurn = NO;
    notifiedAboutApproachingTurn = NO;
    userWarnedAboutDest = NO;
    warnedAboutApprochingDanger = NO;
    mostRecentLocation = nil;
    
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

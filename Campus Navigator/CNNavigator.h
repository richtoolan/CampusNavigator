//
//  CNNavigator.h
//  Campus Navigator
//
//  Created by Rich on 08/02/2013.
//  Copyright (c) 2013 UCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@class CNNavigatorDelegate ,CNPathFinder, CNOpenEars, CNPathAction, CNLanguageModel;

@interface CNNavigator : NSObject<CLLocationManagerDelegate>{
    NSArray *pathsArray;
    NSMutableArray *turnActionsArray;
    CNNavigatorDelegate *delegate;
    CNOpenEars *openears;
    CNPathFinder *pathFinder;
    CNLanguageModel *langMod;

    CLLocationManager *man;
    
    BOOL waitingForLoc;
    BOOL isNavigating;
    BOOL isApproachingTurn;
    BOOL notifiedAboutApproachingTurn;
    BOOL userWarnedAboutDest;
    BOOL detectedUserPassedTurn;
    NSString *locationString;
    CLLocation *mostRecentLocation;
    CLHeading *mostRecentHeading;
    CNPathAction *upComingAction;
    NSArray *currentPath;
    int currentPathIndex;
    NSTimeInterval timeSinceLastTurn;
}
@property(nonatomic, retain) CNNavigatorDelegate *delegate;
@property(nonatomic, retain) CNOpenEars *openears;
@property(nonatomic, retain) CNLanguageModel *langMod;
@property(nonatomic, retain) CNPathFinder *pathFinder;
@property(nonatomic, retain) CLLocationManager *man;
-(void)beginNavigationToLocation:(NSString *)location;
-(void)voiceStringFromUser:(NSString *)voice;
-(NSString *)getFourNearestWithDirections;
-(BOOL)isNavigating;
-(void)stopNav;
-(CLLocation *)getUserLocation;
@end


//
//  CNLanguageModel.h
//  Campus Navigator
//
//  Created by Rich on 16/02/2013.
//  Copyright (c) 2013 UCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class CNOpenEars;
@interface CNLanguageModel : NSObject{
    int level;
    int notificationCount;
    int currentPathIndex;
    CLLocationDistance previousDistance;
    NSString *previousTurnString;
    CNOpenEars *openEars;
    BOOL warnedAboutTurn;
    NSDate *speakTimer;
    
}
@property(nonatomic, retain) CNOpenEars *openEars;

-(id)initWithLevel:(int)lvl andOE:(CNOpenEars *)OE andIndex:(int)index;
-(void)updateToUserLoc:(CLLocationDistance)distance andTurnString:(NSString *)turn andIndex:(int)index;
-(void)reset;
@end

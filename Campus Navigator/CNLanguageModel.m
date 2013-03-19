//
//  CNLanguageModel.m
//  Campus Navigator
//
//  Created by Rich on 16/02/2013.
//  Copyright (c) 2013 UCC. All rights reserved.
//

#import "CNLanguageModel.h"
#import "CNOpenEars.h"
#import <CoreLocation/CoreLocation.h>
#define LEVEL1_DISTNACE 50
#define LEVEL2_DISTNACE 25
#define LEVEL3_DISTNACE 10
#define NEAR_DISTANCE 7
@implementation CNLanguageModel
@synthesize openEars;
-(id)initWithLevel:(int)lvl andOE:(CNOpenEars *)OE andIndex:(int)index{
    self = [super init];
    if(self){
        level = lvl;
        warnedAboutTurn = false;
        self.openEars = OE;
        currentPathIndex = index;
        //CLLocationDistance = [CLLocationDistance i]
    }
    return self;
}

-(void)reset{
    speakTimer = nil;
    currentPathIndex = 0;
    notificationCount = 0;
}

-(void)updateToUserLoc:(CLLocationDistance)distance  
         andTurnString:(NSString *)turn andIndex:(int)index{
    if(speakTimer == nil){
        speakTimer = [[[NSDate alloc] init] retain];
        //Speak timer started depending on levels we'll either speak a lot or very little.
        [self speakStatusSentence:turn andDistance:distance];
        notificationCount ++;
    }else{
        [self checkForNeedToReport:distance andTurnString:turn andIndex:index];
        notificationCount ++;
    }
    
    
}
-(void)checkForNeedToReport:(CLLocationDistance)distance
              andTurnString:(NSString *)turn
                   andIndex:(int)index{
    //[distance ]
    NSDate *localDate = [[NSDate alloc] init];
    NSTimeInterval timeElapsed = [localDate timeIntervalSinceDate:speakTimer];
    switch (level) {
        case 1:
            //Level 1 very quiet
            if (currentPathIndex == index) {
                //make sure we've not moved on a new path
                if(distance <= NEAR_DISTANCE && !warnedAboutTurn){
                    warnedAboutTurn = YES;
                    [self speakTurnApproachSentence:turn andDistance:distance];
                    //User is near turn let them know
                }else{
                    if(timeElapsed/LEVEL1_DISTNACE > notificationCount){
                        notificationCount ++;
                        previousDistance = distance;
                        previousTurnString = turn;
                        [self speakStatusSentence:turn andDistance:distance];
                    }
                }
            }else{
                speakTimer = [[NSDate alloc] init];
                currentPathIndex ++;
                notificationCount = 0;
                [self speakNewPath:distance andTurnString:turn];
                //we've moved onto a new path let the user know
            }

            break;
            
        case 2:
            //level 2 fairly chatty
            if (currentPathIndex == index) {
                //make sure we've not moved on a new path
                if(distance <= NEAR_DISTANCE && !warnedAboutTurn){
                    warnedAboutTurn = YES;
                    
                    [self speakTurnApproachSentence:turn andDistance:distance];
                    //User is near turn let them know
                }else{
                    if(timeElapsed/LEVEL2_DISTNACE > notificationCount){
                        notificationCount ++;
                        previousDistance = distance;
                        previousTurnString = turn;
                        [self speakStatusSentence:turn andDistance:distance];
                    
        
                    }
                }
            }else{
                speakTimer = [[NSDate alloc] init];
                currentPathIndex ++;
                [self speakNewPath:distance andTurnString:turn];
                
                //we've moved onto a new path let the user know
            }

            break;
            
        case 3:
            //level 3 very chatty
            if (currentPathIndex == index) {
                if(distance <= NEAR_DISTANCE && !warnedAboutTurn){
                    warnedAboutTurn = YES;
                    
                    [self speakTurnApproachSentence:turn andDistance:distance];
                  //User is near turn let them know
                }else{
                //make sure we've not moved on a new path
                    if(timeElapsed/LEVEL2_DISTNACE > notificationCount){
                        notificationCount ++;
                        previousDistance = distance;
                        previousTurnString = turn;
                        [self speakStatusSentence:turn andDistance:distance];
                    
                    }
                }
            }else{
                speakTimer = [[NSDate alloc] init];
                currentPathIndex ++;
                [self speakNewPath:distance andTurnString:turn];
                
            }

            break;
            
        default:
            break;
    }
    
}
-(void)speakStatusSentence:(NSString *)turnString andDistance:(CLLocationDistance)distance{
    if([turnString isEqualToString:@"STRAIGHT"]){
        [self.openEars speakSentence:[NSString stringWithFormat:@"You're %.0f meters from going straight at a intersection.",distance]];
        
    }else if([turnString isEqualToString:@"DEST"]){
        [self.openEars speakSentence:[NSString stringWithFormat:@"You're %.0f meters from your destination, continue following the path.",distance]];
        
    }else{
        [self.openEars speakSentence:[NSString stringWithFormat:@"You're %.0f meters from a %@ turn",distance, turnString]];
    }
}
-(void)speakTurnApproachSentence:(NSString *)turnString andDistance:(CLLocationDistance)distance{
    if([turnString isEqualToString:@"STRAIGHT"]){
        [self.openEars speakSentence:[NSString stringWithFormat:@"You're %.0f meter from the intersection, continue straight.",distance]];
        
    }else if([turnString isEqualToString:@"DEST"]){
        [self.openEars speakSentence:[NSString stringWithFormat:@"You're %.0f meter from the destination, continue straight.",distance]];
        
    }else{
        [self.openEars speakSentence:[NSString stringWithFormat:@"You're %.0f meters from the %@ turn, be ready to go %@.",distance, turnString, turnString]];
    }
}
-(void)speakNewPath:(CLLocationDistance)distance andTurnString:(NSString *)turnString{
    if([turnString isEqualToString:@"DEST"]){
    [self.openEars speakSentence:[NSString stringWithFormat:@"Continue following the path for %.0f meters until reaching your destination", distance]];
    }else{
    [self.openEars speakSentence:[NSString stringWithFormat:@"Continue following the path for %.0f meters until reaching a %@ turn", distance, turnString]];
    }
}
-(void)dealloc{
    [super dealloc];
}
@end

//
//  CNPathAction.m
//  Campus Navigator
//
//  Created by Rich on 28/01/2013.
//  Copyright (c) 2013 UCC. All rights reserved.
//

#import "CNPathAction.h"

@implementation CNPathAction
@synthesize turnAngle;
@synthesize fromPath;
@synthesize toPath;
@synthesize turnString;
@synthesize turnLocation;
#define LEFT @"LEFT"
#define RIGHT @"RIGHT"
#define STRAIGHT @"STRAIGHT"

-(id)initWithFromPath:(NSString *)from toPath:(NSString *)to withAngle:(double)angle andLocation:(CLLocation*)turnLoc{
    self = [super init];
    if(self){
        self.fromPath = from;
        self.toPath = to;
        self.turnAngle = angle;
        self.turnLocation = turnLoc;
        [self setTurnStringFromAngle];
    }
    return self;
}
-(id)initWithFromPathDestandLocation:(CLLocation*)turnLoc{
    self = [super init];
    if(self){
        //self.fromPath = from;
        //self.toPath = to;
        //self.turnAngle = angle;
        self.turnLocation = turnLoc;
        self.turnString = @"DEST";
        //[self setTurnStringFromAngle];
    }
    return self;
}
-(void)setTurnStringFromAngle {
    // do your extra stuff here
    //  ...
    //[super setTurnAngle:turnAngle];
    if(self.turnAngle <= 165){
        self.turnString = LEFT;
    }else if( self.turnAngle >= 160 && self.turnAngle <= 200 ){
        self.turnString = STRAIGHT;
    }else if( self.turnAngle >= 205 ){
        self.turnString = RIGHT;
    }else{
        //error case.
        NSLog(@"The turn angle has caused an error the angle is : %f", turnAngle);
    }
    
    //[self setTurnAngle:turnAngle];
}
-(NSString *)info{
    return [NSString stringWithFormat:@"Turn of direction %@ from the path %@ to %@", self.turnString, self.fromPath, self.toPath];
}
-(void)dealloc{
    [super dealloc];
    [self.fromPath release];
    [self.toPath release];
    [self.turnString release];
    [self.turnLocation release];
    self.fromPath = nil;
    self.toPath = nil;
    self.turnString = nil;
    self.turnAngle = 0;
    self.turnLocation = 0;
}
@end

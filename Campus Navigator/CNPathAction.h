//
//  CNPathAction.h
//  Campus Navigator
//
//  Created by Rich on 28/01/2013.
//  Copyright (c) 2013 UCC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CLLocation;
@interface CNPathAction : NSObject{
    
}
@property (nonatomic, retain)NSString *fromPath;
@property (nonatomic, retain)NSString *toPath;
@property (nonatomic) double turnAngle;
@property (nonatomic, retain) NSString *turnString;
@property (nonatomic, retain) CLLocation *turnLocation;
-(id)initWithFromPath:(NSString *)from toPath:(NSString *)to withAngle:(double)angle andLocation:(CLLocation*)turnLoc;
-(id)initWithFromPathDestandLocation:(CLLocation*)turnLoc;
-(NSString *)info;
@end

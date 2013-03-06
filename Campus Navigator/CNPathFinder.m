//
//  CNPathFinder.m
//  Campus Navigator
//
//  Created by Rich on 10/01/2013.
//  Copyright (c) 2013 UCC. All rights reserved.
//

#import "CNPathFinder.h"
@implementation CNPathFinder
-(id)init{
    if(self = [super init]){
        visitedPaths = [[[NSMutableArray alloc] init] retain];
    }
    return self;
}
-(void)dealloc{
    [super dealloc];
    [visitedPaths release];
    visitedPaths = nil;
}
@end

//
//  CNGetNearestPath.h
//  Campus Navigator
//
//  Created by Rich on 10/01/2013.
//  Copyright (c) 2013 UCC. All rights reserved.
//  Gets the nearest path to the users current location
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface CNGetNearestPath : NSObject
+(int)getNearestPath:(CLLocationCoordinate2D)coords;
@end

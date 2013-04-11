//
//  CNDAO.m
//  Campus Navigator
//
//  Created by Rich on 10/01/2013.
//  Copyright (c) 2013 UCC. All rights reserved.
//
// Radians to Degrees. Usage: RADIANS_TO_DEGREES(0.785398)
#define RADIANS_TO_DEGREES(radians) ((radians) * 180.0 / M_PI)

// Degrees to radians. Usage: DEGREES_TO_RADIANS(45)
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#import "CNDAO.h"
#import "CNUtils.h"
#import <CoreLocation/CoreLocation.h>
#define DEG2RAD(degrees) (degrees * 0.01745327) // degrees * pi over 180
#define d2r (M_PI / 180.0)
static void distanceFunc(sqlite3_context *context, int argc, sqlite3_value **argv)
{
    assert(argc == 4);
    if (sqlite3_value_type(argv[0]) == SQLITE_NULL || sqlite3_value_type(argv[1]) == SQLITE_NULL || sqlite3_value_type(argv[2]) == SQLITE_NULL || sqlite3_value_type(argv[3]) == SQLITE_NULL) {
        sqlite3_result_null(context);
        return;
    }
    double lat1 = sqlite3_value_double(argv[0]);
    double lon1 = sqlite3_value_double(argv[1]);
    double lat2 = sqlite3_value_double(argv[2]);
    double lon2 = sqlite3_value_double(argv[3]);
    
    double dlong = (lon2 - lon1) * d2r;
    double dlat = (lat2 - lat1) * d2r;
    double a = pow(sin(dlat/2.0), 2) + cos(lat1*d2r) * cos(lat2*d2r) * pow(sin(dlong/2.0), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1-a));
    double d = 6367 * c;
    
    
    sqlite3_result_double(context, d);
}
@implementation CNDAO

-(id)init{
    if(self = [super init]){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"appData.sqlite"];
        
        db = [[FMDatabase databaseWithPath:writableDBPath ]retain];
        [db open];
        
        sqlite3_create_function(db.sqliteHandle, "distance", 4, SQLITE_UTF8, NULL, &distanceFunc, NULL, NULL);
   
    }
    
    return self;
}


- (float) headingFromCoordinate:(CLLocationCoordinate2D)fromLoc
                   toCoordinate:(CLLocationCoordinate2D)toLoc {
    float fLat = DEGREES_TO_RADIANS(fromLoc.latitude);
    float fLng = DEGREES_TO_RADIANS(fromLoc.longitude);
    float tLat = DEGREES_TO_RADIANS(toLoc.latitude);
    float tLng = DEGREES_TO_RADIANS(toLoc.longitude);
    float angle = atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng));
    angle = RADIANS_TO_DEGREES(angle);
    if (angle<0){
        return (180+(180+angle));
    }
    else{
        return angle;
    }
    
}
/*************
 -(NSArray *)getBuildingNodes
 
 Returns an array of building NSDictionarys
 ************/
-(NSArray *)getBuildingNodes{
    NSMutableArray *buildingList = [[NSMutableArray alloc] init];
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM buildingNodes"];
    FMResultSet *rs = [[db executeQuery:query] retain];
    
    
    while([rs next]){
        NSMutableDictionary *buildingObject = [[NSMutableDictionary alloc] init];
        [buildingObject setValue:[rs stringForColumn:@"name"] forKey:@"name"];
        [buildingObject setValue:[[[CLLocation alloc] initWithLatitude:[rs doubleForColumn:@"buildingLat"] longitude:[rs doubleForColumn:@"buildingLon"]] autorelease] forKey:@"pointCoordinate"];
        [buildingList addObject:buildingObject];
        [buildingObject release];
    }
    [rs release];
    return [buildingList autorelease];
   
}
/*************
 -(NSArray *)getBuildingNames
 
 returns an array of all buildings
 ************/
-(NSArray *)getBuildingNames{
    NSMutableArray *buildingList = [[NSMutableArray alloc] init];
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM buildingNodes"];
    FMResultSet *rs = [[db executeQuery:query] retain];
    
    
    while([rs next]){
        [buildingList addObject:[rs stringForColumn:@"name"]];
    }
    [rs release];
    return [buildingList autorelease];
    
}
/*************
 -(void)saveFavouriteWithName:(NSString *)name AndLocation:(CLLocation*)location
 
 Inserts a new entry in the DB with name and location
 ************/
-(void)saveFavouriteWithName:(NSString *)name AndLocation:(CLLocation*)location{
    [db executeUpdate:[NSString stringWithFormat:@"INSERT INTO buildingNodes VALUES(NULL,'%@','',0,0,%f,%f)", name, location.coordinate.latitude, location.coordinate.longitude]];
    [db commit];
    
}

/*************
 -(NSArray *)getNearestPointForLat:(double)lat AndLon:(double)lon
 
 Returns a valid node nearest to the passed in co-ordinates not taking into account any paths etc 
 ************/
-(NSDictionary *)getNearestPointForLat:(double)lat AndLon:(double)lon{
    //NSDate *start = [NSDate date];
    //////NSLog(@"%@", [db databasePath]);
    NSMutableDictionary *correctDict = [[NSMutableDictionary alloc] init];
    
    if([db open]){
        NSString *query = [NSString stringWithFormat:@"SELECT distance(LAT, LON, %f, %f) as DISTANCE, * FROM pathNode ORDER BY distance(LAT, LON, %f, %f) LIMIT 1", lat, lon , lat, lon];
    FMResultSet *rs = [[db executeQuery:query] retain];
           ////NSLog(@"%@", [db lastErrorMessage]);
    //[query release];

    while([rs next]){
        [correctDict setValue:[[[CLLocation alloc] initWithLatitude:[rs doubleForColumn:@"LAT"] longitude:[rs doubleForColumn:@"LON"]] autorelease] forKey:@"pointCoordinate"];

        
        [correctDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"PARENT_ID"]]  forKey:@"parentID"];
        [correctDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"CONNECTIONS"]]forKey:@"CONNECTIONS"];
        [correctDict setValue:[NSNumber numberWithDouble:[rs doubleForColumn:@"DISTANCE"]] forKey:@"DISTANCE"];
        [correctDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"WARNING"]] forKey:@"WARNING"];
        [correctDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"ID"]] forKey:@"ID"];
        
    }
    //parse results into array
    }
    
    
    
    //NSDate *methodFinish = [NSDate date];
    //NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:start];
    
    //////NSLog(@"Query took: %f", executionTime);
    //[queryTime]
    return [correctDict autorelease];
}
/*************
 --(NSDictionary *)getApproachingWarnings:(double)lat AndLon:(double)lon
 
 Gets the three nearest nodes to the user(only if on the same path and checks for any warnings
 ************/
-(NSDictionary *)getApproachingWarnings:(double)lat AndLon:(double)lon{
    //NSDate *start = [NSDate date];
    //////NSLog(@"%@", [db databasePath]);
    NSMutableDictionary *correctDict = [[NSMutableDictionary alloc] init];
    int parentPath = 0;
    if([db open]){
        NSString *query = [NSString stringWithFormat:@"SELECT distance(LAT, LON, %f, %f) as DISTANCE, * FROM pathNode ORDER BY distance(LAT, LON, %f, %f) LIMIT 3 ", lat, lon , lat, lon];
        FMResultSet *rs = [[db executeQuery:query] retain];
        ////NSLog(@"%@", [db lastErrorMessage]);
        //[query release];
        
        while([rs next]){
            if(parentPath == 0){
                parentPath = [rs intForColumn:@"PARENT_ID"];
            }
            if([rs intForColumn:@"WARNING" ] != 0 && [rs intForColumn:@"PARENT_ID"] == parentPath){
            [correctDict setValue:[[[CLLocation alloc] initWithLatitude:[rs doubleForColumn:@"LAT"] longitude:[rs doubleForColumn:@"LON"]] autorelease] forKey:@"pointCoordinate"];
            
            
            [correctDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"PARENT_ID"]]  forKey:@"parentID"];
            [correctDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"CONNECTIONS"]]forKey:@"CONNECTIONS"];
            [correctDict setValue:[NSNumber numberWithDouble:[rs doubleForColumn:@"DISTANCE"]] forKey:@"DISTANCE"];
            [correctDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"WARNING"]] forKey:@"WARNING"];
            [correctDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"ID"]] forKey:@"ID"];
            }
            
        }
        //parse results into array
    }
    return [correctDict autorelease];
}
/*************
 -(NSArray *)getNearestBuidingForString:(NSString *)building
 
 Returns a valid node for the string passed in, First look up is direct failing that second is using Leivenstein.
 
 ************/
-(NSDictionary *)getNearestBuidingForString:(NSString *)building{
    NSString *potential;
    int eDS = 200;
    NSMutableDictionary *correctDict = [[[NSMutableDictionary alloc] init] autorelease];
    if([db open]){
        
        NSString *query = [NSString stringWithFormat:@"SELECT  * FROM buildingNodes WHERE name = %@", building];
        FMResultSet *rs = [db executeQuery:query];
        if ([[rs resultDictionary ] count] > 0) {
            return [self getNearestPointForLat:[rs doubleForColumn:@"buildingLAT"] AndLon:[rs doubleForColumn:@"buildingLON"]];

        }else{
            NSString *query = [NSString stringWithFormat:@"SELECT  * FROM buildingNodes"];
            FMResultSet *rs = [db executeQuery:query];
            while ([rs next]) {
                NSString *possibleName = [rs stringForColumn:@"name"];
                potential = possibleName;
                int possibleDist = [self getEditDistanceWithStringOne:building andStringTwo:possibleName];
                if(eDS > possibleDist){
                    eDS = possibleDist;
                    potential = possibleName;
                    [correctDict setValue:[[[CLLocation alloc] initWithLatitude:[rs doubleForColumn:@"buildingLAT"] longitude:[rs doubleForColumn:@"buildingLON"]] autorelease] forKey:@"pointCoordinate"];
                    
                    NSDictionary *nearestPoint = [[self getNearestPointForLat:[rs doubleForColumn:@"buildingLAT"] AndLon:[rs doubleForColumn:@"buildingLON"]] retain];
                    [correctDict setValue:[nearestPoint objectForKey:@"parentID"]  forKey:@"parentID"];
                    [correctDict setValue:[nearestPoint  objectForKey:@"ID"]  forKey:@"ID"];
                    
                }else if (eDS == possibleDist){
                    ////NSLog(@"%@ vs %@", possibleName, potential);
                }
                
            };
        }
        
        return correctDict;
    }
    return nil;
}

//test
+(float)angleFromCoordinate:(CLLocationCoordinate2D)first
               toCoordinate:(CLLocationCoordinate2D)second {
    
	float deltaLongitude = second.longitude - first.longitude;
	float deltaLatitude = second.latitude - first.latitude;
	float angle = (M_PI * .5f) - atan(deltaLatitude / deltaLongitude);
    
	if (deltaLongitude > 0)      return angle;
	else if (deltaLongitude < 0) return angle + M_PI;
	else if (deltaLatitude < 0)  return M_PI;
    
	return 0.0f;
}
/*************
 -(int)getEditDistanceWithStringOne:(NSString *)stringOne andStringTwo:(NSString *)stringTwo
 
 Returns the Leivenstein edit distance of the stringOne and stringTwo
 
 ************/
-(int)getEditDistanceWithStringOne:(NSString *)stringOne andStringTwo:(NSString *)stringTwo{
    if(stringOne.length > 0 && stringTwo.length > 0){
        const char *str1Char = [stringTwo UTF8String];
        const char *str2Char = [stringOne UTF8String];
        if(stringOne.length >= stringTwo.length){
            str1Char = [stringOne UTF8String];
            str2Char = [stringTwo UTF8String];
        }
        
        
        int size1 = strlen(str1Char);
        int size2 = strlen(str2Char);
        int m[size1 +1][size2 +1];
        
        for(int i = 0; i <= size1; i++){
            m[i][0]= i;
        }
        for(int j = 0; j <= size2; j++){
            m[0][j]= j;
        }
        
        for(int i = 1; i <= size1; i++){
            for(int j = 1; j <= size2; j++){
                if(str1Char[i-1] == str2Char[j-1]){
                    m[i][j] = MIN(m[i-1][j]+1, MIN(m[i][j-1]+1, m[i-1][j-1]));
                }else{
                    m[i][j] = MIN(m[i-1][j]+1, MIN(m[i][j-1]+1, m[i-1][j-1]+1));
                }
            }
        }
        return m[size1][size2];
    }else if(stringOne.length > 0){
        return stringOne.length;
    }else{
        return stringTwo.length;
    }
    
    return -1;
}
/*************
 -(NSArray *)getPathNodesForParent:(int)parent
 
 Returns an array of nodes for the Path ID
 
 ************/
-(NSArray *)getPathNodesForParent:(int)parent{
    NSMutableArray *allPoints = [[NSMutableArray alloc] init];
    if([db open]){
        NSString *query = [NSString stringWithFormat:@"SELECT  * FROM pathNode WHERE PARENT_ID = %i", parent];
        FMResultSet *rs = [db executeQuery:query];
        
        
        while([rs next]){
            NSMutableDictionary *correctDict = [[NSMutableDictionary alloc] init];
            [correctDict setValue:[[[CLLocation alloc] initWithLatitude:[rs doubleForColumn:@"LAT"] longitude:[rs doubleForColumn:@"LON"]] autorelease] forKey:@"pointCoordinate"];
            [correctDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"CONNECTIONS"]]forKey:@"CONNECTIONS"];
            [correctDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"PARENT_ID"]] forKey:@"PARENT"];
            [correctDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"WARNINGS"]] forKey:@"WARNINGS"];
            
            [allPoints addObject:correctDict];
            [correctDict release];
            
        }
        //parse results into array
    }
    return [allPoints autorelease];
}
/*************
 -(void)updateDatabaseConnections
 
 Updates the path connections in the database.
 
 ************/
-(void)updateDatabaseConnections{
    double accuracy = 0.001000000000;
    NSString *string = @"";
    FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM pathNode WHERE PARENT_ID = 1"]];
    while ([rs next]) {
        NSNumber *LAT = [[rs resultDictionary] objectForKey:@"lat"] ;
        NSNumber *LON = [[rs resultDictionary] objectForKey:@"lon"];
        FMResultSet *innerRS = [db executeQuery:[NSString stringWithFormat:@"SELECT distance(LAT, LON, %@, %@) as DISTANCE, * FROM pathNode WHERE PARENT_ID = 2 ORDER BY DISTANCE ASC", LAT, LON]];
        while([innerRS next]){
            ////NSLog(@"Distance between %i and %i is %f", [rs intForColumn:@"ID"], [innerRS intForColumn:@"ID"], [innerRS doubleForColumn:@"DISTANCE"]);
        }
    }
    //
    rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM pathNode"]];
    
        while ([rs next]) {
            if([rs intForColumn:@"PARENT_ID"] == 2){
                ////NSLog(@"YO");
            }
            NSNumber *LAT = [[rs resultDictionary] objectForKey:@"lat"] ;
            NSNumber *LON = [[rs resultDictionary] objectForKey:@"lon"];
            int parent = [rs intForColumn:@"PARENT_ID"];
            
            FMResultSet *innerRS = [db executeQuery:[NSString stringWithFormat:@"SELECT distance(LAT, LON, %@, %@) as DISTANCE, * FROM pathNode WHERE DISTANCE < %f AND PARENT_ID != %i", LAT, LON , accuracy, parent]];
            while([innerRS next]){
                if([innerRS intForColumn:@"PARENT_ID"] != parent ){
                    string = [NSString stringWithFormat:@"%@%@",[NSString stringWithFormat:@"UPDATE pathNode SET CONNECTIONS = %i WHERE ID = %i;", parent, [innerRS intForColumn:@"ID"]], string];
                    if([db executeQuery:[NSString stringWithFormat:@"UPDATE pathNode SET CONNECTIONS = %i WHERE ID = %i", parent, [innerRS intForColumn:@"ID"]]]){
                    
                                    }
                }
            }
        
    }
}
//debug method used for testing.
-(NSMutableArray *)testPathID:(int)val :(NSMutableArray *)arr dest:(int)dest{
    ////NSLog(@"Path id is %i and arr is %@", val, arr);
    if(val == dest){
        return arr;
    }
    if(arr == nil){
        arr = [[[NSMutableArray alloc] init] retain];
    }
    [arr addObject:[NSNumber numberWithInt:val]];
    FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM pathNode WHERE PARENT_ID = %i AND CONNECTIONS != 0", val]];
    while([rs next]){
        if([rs intForColumn:@"CONNECTIONS"] != val && ![arr containsObject:[NSNumber numberWithInt:[rs intForColumn:@"CONNECTIONS"]]]) {
            [arr addObject:[self testPathID:[rs intForColumn:@"CONNECTIONS"]:arr dest:dest]];
           
        }
    }
    
    return nil;
}
-(FMResultSet *)executeQuery:(NSString *)query{
    return [db executeQuery:query];
}
/*************
 -(NSArray *)get:(int)count NearBuildingsWithLat:(double)lat andLon:(double)lon
 
 Returns an array of count objects, containing the nearest building to the lat and lon. 
 ************/
-(NSArray *)get:(int)count NearBuildingsWithLat:(double)lat andLon:(double)lon{
    NSMutableArray *buildings = [[NSMutableArray alloc] init];
    FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT distance(buildingLat, buildingLon, %f, %f) as DISTANCE, * FROM buildingNodes ORDER BY DISTANCE ASC LIMIT %i", lat, lon, count]];
    while([rs next]){
        NSMutableDictionary *correctDict = [[NSMutableDictionary alloc] init];
        CLLocation *buildingLoc = [[[CLLocation alloc] initWithLatitude:[rs doubleForColumn:@"buildingLat"] longitude:[rs doubleForColumn:@"buildingLon"]] autorelease];
        [correctDict setValue:buildingLoc forKey:@"buildingCoordinate"];
        [correctDict setValue:[rs stringForColumn:@"name"] forKey:@"buildingName"];
        [correctDict setValue:[NSNumber numberWithDouble:([rs doubleForColumn:@"distance"]/0.0010000)]forKey:@"buildingDistance"];
        [correctDict setValue:[NSNumber numberWithFloat:[self headingFromCoordinate:CLLocationCoordinate2DMake(lat, lon) toCoordinate:buildingLoc.coordinate ]] forKey:@"Angle"];
        [buildings addObject:correctDict];
        [correctDict release];
        
    }
    return buildings;
    
}

-(void)dealloc{
    [super dealloc];
    [db release];
    db = nil;
}
@end

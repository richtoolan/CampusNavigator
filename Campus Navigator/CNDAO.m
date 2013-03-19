//
//  CNDAO.m
//  Campus Navigator
//
//  Created by Rich on 10/01/2013.
//  Copyright (c) 2013 UCC. All rights reserved.
//

#import "CNDAO.h"
#import "CNUtils.h"
#import <CoreLocation/CoreLocation.h>
#define DEG2RAD(degrees) (degrees * 0.01745327) // degrees * pi over 180
#define d2r (M_PI / 180.0)
static void distanceFunc(sqlite3_context *context, int argc, sqlite3_value **argv)
{
    // check that we have four arguments (lat1, lon1, lat2, lon2)
    assert(argc == 4);
    // check that all four arguments are non-null
    if (sqlite3_value_type(argv[0]) == SQLITE_NULL || sqlite3_value_type(argv[1]) == SQLITE_NULL || sqlite3_value_type(argv[2]) == SQLITE_NULL || sqlite3_value_type(argv[3]) == SQLITE_NULL) {
        sqlite3_result_null(context);
        return;
    }
    // get the four argument values
    double lat1 = sqlite3_value_double(argv[0]);
    double lon1 = sqlite3_value_double(argv[1]);
    double lat2 = sqlite3_value_double(argv[2]);
    double lon2 = sqlite3_value_double(argv[3]);
    
    double dlong = (lon2 - lon1) * d2r;
    double dlat = (lat2 - lat1) * d2r;
    double a = pow(sin(dlat/2.0), 2) + cos(lat1*d2r) * cos(lat2*d2r) * pow(sin(dlong/2.0), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1-a));
    double d = 6367 * c;
    
    
    // apply the spherical law of cosines to our latitudes and longitudes, and set the result appropriately
    // 6378.1 is the approximate radius of the earth in kilometres
    sqlite3_result_double(context, d);
}
@implementation CNDAO

//selects the tuple 'data' from the DB 'table' with a limit of 'limit' 0 being none optional ordering by ID if 'order' is set
-(id)init{
    if(self = [super init]){
        //[CNDAO createEditableCopyOfDatabaseIfNeeded];
        //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        //NSString *documentsDirectory = [paths objectAtIndex:0];
        //NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"appData.sqlite"];
        //db = [[[FMDatabase alloc] initWithPath:writableDBPath ] retain];
        //[db open];
        NSArray *paths;
        NSString *docsPath;
        if([CNUtils createEditableCopyOfDatabaseIfNeeded]){
            paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            docsPath = [[paths objectAtIndex:0]  stringByAppendingPathComponent:@"appData.sqlite"];
        }else{
            //paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            docsPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"appData.sqlite"];
            
            
        }
        
        db = [[FMDatabase databaseWithPath:docsPath ]retain];
        //db = [[[FMDatabase alloc] initWithPath:writableDBPath ] retain];
        [db open];
        
        sqlite3_create_function(db.sqliteHandle, "distance", 4, SQLITE_UTF8, NULL, &distanceFunc, NULL, NULL);
        NSLog(@"DB Error %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        
        //array = [[[NSMutableArray alloc] init] retain];
        
        //51.89550934837755, -8.488927903875878
        //51.89550941509977, -8.488927888326694
        
        //51.89332984511339, -8.489108775346079
        //51.89337052546859, -8.495068330777073
        
        //51.89550905827314, -8.488928430087951
        //51.89550934837755, -8.488927903875878,
        
        /*double lat1 = 51.895436545;
        double lon1 = -8.48901558343811;
        double lat2 = 51.89550934837755;
        double lon2 = -8.488927903875878;
        FMResultSet *test = [db executeQuery:[NSString stringWithFormat:@"SELECT distance(LAT, LON, %f, %f) AS DISTANCE FROM pathNode WHERE ID = 121 ", lat1, lon1]];
        while ([test next]) {
            //
            NSLog(@"Distance between %i and %i is %f", [test intForColumn:@"ID"], 1, [test doubleForColumn:@"DISTANCE"]);
            //
        }
        
         INSERT INTO pathNode ( LAT, LON, PARENT_ID, CONNECTIONS) VALUES ( 51.89550905827314, -8.488928430087951, 9, 0);
         INSERT INTO pathNode ( LAT, LON, PARENT_ID, CONNECTIONS) VALUES ( 51.89550934837755, -8.488927903875878, 9, 0);
         
        
        double dlong = (lon2 - lon1) * d2r;
        double dlat = (lat2 - lat1) * d2r;
        double a = pow(sin(dlat/2.0), 2) + cos(lat1*d2r) * cos(lat2*d2r) * pow(sin(dlong/2.0), 2);
        double c = 2 * atan2(sqrt(a), sqrt(1-a));
        double d = 6367 * c;
        //acos(sin(lat1rad) * sin(lat2rad) + cos(lat1rad) * cos(lat2rad) * cos(DEG2RAD(lon2) - DEG2RAD(lon1))) * 6378.1)
        double lat1rad = DEG2RAD(51.89550905827314);
        double lat2rad = DEG2RAD(51.89550934837755);
        
 
        
        NSLog(@"Tiny distance is: %f other func is %f",(acos(sin(lat1rad) * sin(lat2rad) + cos(lat1rad) * cos(lat2rad) * cos(DEG2RAD(8.488927888326694) - DEG2RAD(8.488927903875878))) * 6378.1), d);
        */
        //[self updateDatabaseConnections];
         
        //NSLog(@"%@", [self getNearestBuidingForString:@"Western"]);

        

        
    }
    
    return self;
}

-(NSDictionary *)selectData:(NSString *)data fromTable:(NSString *)table withLimit:(int)limit andOrdering:(BOOL)order{
    return nil;
}
//updates
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
-(BOOL)updateData:(NSString *)data fromTable:(NSString *)table{
    //[db beginTransaction];
    //[db executeUpdate:@"INSERT INTO buildingNodes VALUES(8,'ATM','',0,0,50.0,8.0)"];
    //[db commit];
    return YES;
}
-(BOOL)removeData:(NSString *)data fromTable:(NSString *)table{
    return NO;
}
/*************
 -(NSArray *)getNearestPointForLat:(double)lat AndLon:(double)lon
 
 Returns a valid node nearest to the passed in co-ordinates not taking into account any paths etc 
 ************/
-(NSDictionary *)getNearestPointForLat:(double)lat AndLon:(double)lon{
    //NSDate *start = [NSDate date];
    //NSLog(@"%@", [db databasePath]);
    NSMutableDictionary *correctDict = [[NSMutableDictionary alloc] init];
    
    if([db open]){
        NSString *query = [NSString stringWithFormat:@"SELECT distance(LAT, LON, %f, %f) as DISTANCE, * FROM pathNode ORDER BY distance(LAT, LON, %f, %f) LIMIT 1", lat, lon , lat, lon];
    FMResultSet *rs = [[db executeQuery:query] retain];
           NSLog(@"%@", [db lastErrorMessage]);
    //[query release];

    while([rs next]){
        [correctDict setValue:[[[CLLocation alloc] initWithLatitude:[rs doubleForColumn:@"LAT"] longitude:[rs doubleForColumn:@"LON"]] autorelease] forKey:@"pointCoordinate"];

        
        [correctDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"PARENT_ID"]]  forKey:@"parentID"];
        [correctDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"CONNECTIONS"]]forKey:@"CONNECTIONS"];
        [correctDict setValue:[NSNumber numberWithDouble:[rs doubleForColumn:@"DISTANCE"]] forKey:@"DISTANCE"];
        [correctDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"ID"]] forKey:@"ID"];
        
    }
    //parse results into array
    }
    
    
    
    //NSDate *methodFinish = [NSDate date];
    //NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:start];
    
    //NSLog(@"Query took: %f", executionTime);
    //[queryTime]
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
                    NSLog(@"%@ vs %@", possibleName, potential);
                }
                
            };
        }
        
        return correctDict;
    }
    return nil;
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
        //int** m;
        //m = (int**) malloc((size1+1)*sizeof(int*));
        //for (int i = 0; i < size1; i++){
        //    m[i] = (int*) malloc(size2+1*sizeof(int));
        //}
        //for(int i = 0; i <= size1; i ++){
        //    m[i][0] = int z[size2 +1];
        //}
        
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
        /*debug
         for (int i = 0; i < m.length; i++) {
         for (int j = 0; j < m[i].length; j++) {
         System.out.print(m[i][j] + " ");
         }
         System.out.print("\n");
         }
         */		
        return m[size1][size2];
    }else if(stringOne.length > 0){
        return stringOne.length;
    }else{
        return stringTwo.length;
    }
    
    return -1;
}
-(NSArray *)getPathNodesForParent:(int)parent{
    //NSDate *start = [NSDate date];
    NSMutableArray *allPoints = [[NSMutableArray alloc] init];
    //NSLog(@"%@", [db databasePath]);
    if([db open]){
        NSString *query = [NSString stringWithFormat:@"SELECT  * FROM pathNode WHERE PARENT_ID = %i", parent];
        FMResultSet *rs = [db executeQuery:query];
        //NSLog(@"%@", [db lastErrorMessage]);
        //[query release];
        
        while([rs next]){
            NSMutableDictionary *correctDict = [[NSMutableDictionary alloc] init];
            [correctDict setValue:[[[CLLocation alloc] initWithLatitude:[rs doubleForColumn:@"LAT"] longitude:[rs doubleForColumn:@"LON"]] autorelease] forKey:@"pointCoordinate"];
            [correctDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"CONNECTIONS"]]forKey:@"CONNECTIONS"];
            [correctDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"PARENT_ID"]] forKey:@"PARENT"];
            [allPoints addObject:correctDict];
            [correctDict release];
            
        }
        //parse results into array
    }
    
    
    
    //NSDate *methodFinish = [NSDate date];
    //bNSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:start];
    
    //NSLog(@"Query took: %f", executionTime);
    //[queryTime]
    return [allPoints autorelease];
}
-(void)updateDatabaseConnections{
    double accuracy = 0.001000000000;
    NSString *string = @"";
       //NSLog(@"On number %i", i);
    //test 1 and 2
    FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM pathNode WHERE PARENT_ID = 1"]];
    while ([rs next]) {
        NSNumber *LAT = [[rs resultDict] objectForKey:@"lat"] ;
        NSNumber *LON = [[rs resultDict] objectForKey:@"lon"];
        FMResultSet *innerRS = [db executeQuery:[NSString stringWithFormat:@"SELECT distance(LAT, LON, %@, %@) as DISTANCE, * FROM pathNode WHERE PARENT_ID = 2 ORDER BY DISTANCE ASC", LAT, LON]];
        while([innerRS next]){
            NSLog(@"Distance between %i and %i is %f", [rs intForColumn:@"ID"], [innerRS intForColumn:@"ID"], [innerRS doubleForColumn:@"DISTANCE"]);
        }
    }
    //
    rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM pathNode"]];
    
        while ([rs next]) {
            if([rs intForColumn:@"PARENT_ID"] == 2){
                NSLog(@"YO");
            }
            NSNumber *LAT = [[rs resultDict] objectForKey:@"lat"] ;
            NSNumber *LON = [[rs resultDict] objectForKey:@"lon"];
            int parent = [rs intForColumn:@"PARENT_ID"];
            
            FMResultSet *innerRS = [db executeQuery:[NSString stringWithFormat:@"SELECT distance(LAT, LON, %@, %@) as DISTANCE, * FROM pathNode WHERE DISTANCE < %f AND PARENT_ID != %i", LAT, LON , accuracy, parent]];
            
            // NSLog(@"DB LAst error %@", [db lastErrorMessage]);
            while([innerRS next]){
            
                //[innerRS resultDictionary]
                if([innerRS intForColumn:@"PARENT_ID"] != parent ){
                    NSLog(@"We have a hit with distance %f for parents %i and %i", [innerRS doubleForColumn:@"DISTANCE"], parent, [innerRS intForColumn:@"PARENT_ID"]);
                    
                    string = [NSString stringWithFormat:@"%@%@",[NSString stringWithFormat:@"UPDATE pathNode SET CONNECTIONS = %i WHERE ID = %i;", parent, [innerRS intForColumn:@"ID"]], string];
                    if([db executeQuery:[NSString stringWithFormat:@"UPDATE pathNode SET CONNECTIONS = %i WHERE ID = %i", parent, [innerRS intForColumn:@"ID"]]]){
                    //NSLog(@"SUCCESS!! %@", [db lastErrorMessage]);
                        //FMResultSet *anotherRS = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM pathNode WHERE ID = %i", [innerRS intForColumn:@"ID"]]];
                        //NSLog(@"RS %i", [anotherRS intForColumn:@"CONNECTIONS"]);
                                    }
                }
            }
        
    }
    NSLog(@"%@", string);
}
-(NSMutableArray *)testPathID:(int)val :(NSMutableArray *)arr dest:(int)dest{
    NSLog(@"Path id is %i and arr is %@", val, arr);
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


//-(void)allpaths(path,node){
//cycle = path.substring(path.lastIndex(node)) + node
//if path.contains(cycle)
//return
//path = path + node
//if node.isEndNode
//print path
//return
//for child in node.children
//allpaths(path, child)
//    



//}
//-(NSArray *)testPathID:(int)path{
//    SELECT * FROM  category WHERE parent_id = path
//    SELECT * FROM category WHERE parent_id = [result from prev iterations until the leaf node is hit]
//    
//  /*      Node root = NULL;
//        Node head;
//        Node branch = ;
//    
//        treeInsert(&root, 4);
//        treeInsert(&root, 2);
//        treeInsert(&root, 1);
//        treeInsert(&root, 3);
//        treeInsert(&root, 5);
//    
//    treeInsert(&branch, 9);
//    treeInsert(&branch, 9);
//    treeInsert(&branch, 9);
//    treeInsert(&branch, 9);
//    treeInsert(&branch, 9);
//        
//    //treeInsert(&root, branch);
//        head = treeToList(root);
//    
//
//    
//        printList(head);    prints: 1 2 3 4 5  */
//    

-(void)dealloc{
    [super dealloc];
    [db release];
    db = nil;
}
@end

//
//  CNDAO.m
//  Campus Navigator
//
//  Created by Rich on 10/01/2013.
//  Copyright (c) 2013 UCC. All rights reserved.
//

#import "CNDAO.h"
#import <CoreLocation/CoreLocation.h>
@implementation CNDAO

//selects the tuple 'data' from the DB 'table' with a limit of 'limit' 0 being none optional ordering by ID if 'order' is set
-(id)init{
    if(self = [super init]){
        db = [[[FMDatabase alloc] initWithPath:
               [[NSBundle mainBundle] pathForResource:@"appData" ofType:@"sqlite"]] retain];
        NSLog(@"DB OPen? %i",[db open]);
        
        sqlite3_load_extension(db.sqliteHandle, [[NSBundle mainBundle] pathForResource:@"appData" ofType:@"sqlite"]);
    }
    
    return self;
}
-(NSDictionary *)selectData:(NSString *)data fromTable:(NSString *)table withLimit:(int)limit andOrdering:(BOOL)order{
    return nil;
}
//updates
-(BOOL)updateData:(NSString *)data fromTable:(NSString *)table{
    return YES;
}
-(BOOL)removeData:(NSString *)data fromTable:(NSString *)table{
    return NO;
}
-(NSArray *)returnAllPoints{
    NSMutableArray *allPoints = [[NSMutableArray alloc] init];
    NSLog(@"%@", [db databasePath]);
    if([db open]){
    NSString *query = @"select * from pathNode ORDER BY LAT DESC";
    FMResultSet *rs = [db executeQuery:query];
            NSLog(@"%@", [db lastErrorMessage]);
    [query release];

    while([rs next]){
        NSMutableDictionary *correctDict = [[NSMutableDictionary alloc] init];
        [correctDict setValue:[[[CLLocation alloc] initWithLatitude:[rs doubleForColumn:@"LAT"] longitude:[rs doubleForColumn:@"LON"]] autorelease] forKey:@"pointCoordinate"];

        
        [correctDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"PARENT_ID"]]  forKey:@"parentID"];
        [correctDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"CONNECTIONS"]]forKey:@"CONNECTIONS"];
        [allPoints addObject:correctDict];
        [correctDict release];
        
    }
    //parse results into array
    }
    //NSLog(@"")
    return [allPoints autorelease];
}

-(void)dealloc{
    [super dealloc];
    [db release];
    db = nil;
}
@end

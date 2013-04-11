//
//  CNDAO.h
//  Campus Navigator
//
//  Created by Rich on 10/01/2013.
//  Copyright (c) 2013 UCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "sqlite3.h"
@class CLLocation;
@interface CNDAO : NSObject{
    FMDatabase *db;
    NSMutableArray *array;
}
-(FMResultSet *)executeQuery:(NSString *)query;
-(NSArray *)selectData:(NSString *)data fromTable:(NSString *)table withLimit:(int)limit andOrdering:(BOOL)order;
-(BOOL)updateData:(NSString *)data fromTable:(NSString *)table;
-(BOOL)removeData:(NSString *)data fromTable:(NSString *)table;
-(NSDictionary *)getNearestPointForLat:(double)lat AndLon:(double)lon;
-(NSDictionary *)getApproachingWarnings:(double)lat AndLon:(double)lon;
-(NSArray *)getPathNodesForParent:(int)parent;
-(void)updateDatabaseConnections;
-(NSMutableArray *)testPathID:(int)val :(NSMutableArray *)arr dest:(int)dest;
-(NSDictionary *)getNearestBuidingForString:(NSString *)building;
-(NSArray *)getBuildingNodes;
-(NSArray *)getBuildingNames;
-(NSArray *)get:(int)count NearBuildingsWithLat:(double)lat andLon:(double)lon;
-(void)saveFavouriteWithName:(NSString *)name AndLocation:(CLLocation*)location;
@end

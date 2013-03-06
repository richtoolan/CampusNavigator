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
@interface CNDAO : NSObject{
    FMDatabase *db;
}
-(NSArray *)selectData:(NSString *)data fromTable:(NSString *)table withLimit:(int)limit andOrdering:(BOOL)order;
-(BOOL)updateData:(NSString *)data fromTable:(NSString *)table;
-(BOOL)removeData:(NSString *)data fromTable:(NSString *)table;
-(NSArray *)returnAllPoints;
@end

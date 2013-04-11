//
//  CNUtils.m
//  Campus Navigator
//
//  Created by Rich on 27/11/2012.
//  Copyright (c) 2012 UCC. All rights reserved.
//

#import "CNUtils.h"
#import <AudioToolbox/AudioServices.h>
@implementation CNUtils
//Easily display an alertview with no delegate
+(void)displayAlertWithTitle:(NSString *)title andText:(NSString *)bodyText andButtonText:(NSString *)bText{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:bodyText delegate:nil cancelButtonTitle:bText otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}
// credit: http://www.icodeblog.com/2008/08/19/iphone-programming-tutorial-creating-a-todo-list-using-sqlite-part-1/#create-db
+ (BOOL)createEditableCopyOfDatabaseIfNeeded {
    // First, test for existence.
    BOOL success;
    BOOL newInstallation;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"appData.sqlite"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    newInstallation = !success;
    if (success) {
        [fileManager release];
        return newInstallation;
    }
    // The writable database does not exist, so copy the default to the appropriate location.
    //////NSLog(@"database does not exist");
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"appData.sqlite"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    [fileManager release];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
    return newInstallation;
}
//credit :http://www.icodeblog.com/2008/08/19/iphone-programming-tutorial-creating-a-todo-list-using-sqlite-part-1/#create-db
+ (BOOL)createEditableCopyOfVolcabIfNeeded {
    // First, test for existence.
    BOOL success;
    BOOL newInstallation;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"volcab.gram"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    newInstallation = !success;
    if (success) {
        [fileManager release];
        return newInstallation;
    }
    // The writable database does not exist, so copy the default to the appropriate location.
    //////NSLog(@"database does not exist");
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"volcab.gram"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    [fileManager release];
    if (!success) {
        NSAssert1(0, @"Failed to create writable volcab file with message '%@'.", [error localizedDescription]);
    }
    return newInstallation;
}
//credit: http://www.icodeblog.com/2008/08/19/iphone-programming-tutorial-creating-a-todo-list-using-sqlite-part-1/#create-db
+ (BOOL)createEditableCopyOfSecondVolcabIfNeeded {
    // First, test for existence.
    BOOL success;
    BOOL newInstallation;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"speech.gram"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    newInstallation = !success;
    if (success) {
        [fileManager release];
        return newInstallation;
    }
    // The writable database does not exist, so copy the default to the appropriate location.
    //////NSLog(@"database does not exist");
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"speech.gram"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    [fileManager release];
    if (!success) {
        NSAssert1(0, @"Failed to create writable volcab file with message '%@'.", [error localizedDescription]);
    }
    return newInstallation;
}
@end

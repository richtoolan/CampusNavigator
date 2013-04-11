//
//  CNUtils.h
//  Campus Navigator
//
//  Created by Rich on 27/11/2012.
//  Copyright (c) 2012 UCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface CNUtils : NSObject
+(void)displayAlertWithTitle:(NSString *)title andText:(NSString *)bodyText andButtonText:(NSString *)bText;
-(void)isHeadsetPluggedIn;
+ (BOOL)createEditableCopyOfDatabaseIfNeeded;
+ (BOOL)createEditableCopyOfVolcabIfNeeded;
@end

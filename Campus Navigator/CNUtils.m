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
//Detect if earphones are plugged into the device, this should be polled ocassionaly and change audio output if there's a change
- (void)isHeadsetPluggedIn {
    [[AVAudioSession sharedInstance] setDelegate: self];
    


    AudioSessionAddPropertyListener (
                                     kAudioSessionProperty_AudioRouteChange,
                                     audioRouteChangeListenerCallback,
                                     self);
}
void audioRouteChangeListenerCallback (
                                           void *inUserData,
                                           AudioSessionPropertyID inPropertyID,
                                           UInt32 inPropertyValueSize,
                                           const void *inPropertyValue) 
    {
        CFDictionaryRef routeChangeDictionary = inPropertyValue;
        CFNumberRef routeChangeReasonRef =
        CFDictionaryGetValue (
                              routeChangeDictionary,
                              CFSTR (kAudioSession_AudioRouteChangeKey_Reason));
        
        SInt32 routeChangeReason;
        
        CFNumberGetValue (
                          routeChangeReasonRef,
                          kCFNumberSInt32Type,
                          &routeChangeReason);
        

        //NSString *oldRouteString = (NSString *)oldRouteRef;
        
        
        //****************
        // kAudioSession_AudioRouteChangeKey_PreviousRouteDescription -> Previous route
        // kAudioSession_AudioRouteChangeKey_CurrentRouteDescription -> Current route
        
        CFDictionaryRef newRouteRef = CFDictionaryGetValue(routeChangeDictionary, kAudioSession_AudioRouteChangeKey_CurrentRouteDescription);
        NSDictionary *newRouteDict = (NSDictionary *)newRouteRef;
        
        // RouteDetailedDescription_Outputs -> Output
        // RouteDetailedDescription_Outputs -> Input
        
        NSArray * paths = [[newRouteDict objectForKey: @"RouteDetailedDescription_Outputs"] count] ? [newRouteDict objectForKey: @"RouteDetailedDescription_Outputs"] : [newRouteDict objectForKey: @"RouteDetailedDescription_Inputs"];
        
        NSString * newRouteString = [[paths objectAtIndex: 0] objectForKey: @"RouteDetailedDescription_PortType"];
        NSLog(@" route is %@", newRouteString);
        // newRouteString -> MicrophoneWired, Speaker, LineOut, Headphone
        
        //**************
        
    

}
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
    //NSLog(@"database does not exist");
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"appData.sqlite"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    [fileManager release];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
    return newInstallation;
}
@end

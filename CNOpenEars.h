//
//  CNOpenEars.h
//  Campus Navigator
//
//  Created by Rich on 20/12/2012.
//  Copyright (c) 2012 UCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenEars/OpenEarsEventsObserver.h>
#import <Slt/Slt.h>
#import <AVFoundation/AVFoundation.h>
@class PocketsphinxController;
@class FliteController;
@class CNOpenEarsDelegate;

@interface CNOpenEars : NSObject <OpenEarsEventsObserverDelegate, AVAudioPlayerDelegate>{
    NSString *pathToDynamicallyGeneratedGrammar;
	NSString *pathToDynamicallyGeneratedDictionary;
    NSMutableArray *queue;
    AVAudioPlayer *player;
  
    
	
	// Our NSTimer that will help us read and display the input and output levels without locking the UI
    Slt *slt;
	// These three are important OpenEars classes that ViewController demonstrates the use of. There is a fourth important class (LanguageModelGenerator) demonstrated
	// inside the ViewController implementation in the method viewDidLoad.

	OpenEarsEventsObserver *openEarsEventsObserver; // A class whose delegate methods which will allow us to stay informed of changes in the Flite and Pocketsphinx statuses.
	PocketsphinxController *pocketsphinxController; // The controller for Pocketsphinx (voice recognition).
	FliteController *fliteController; // The controller for Flite (speech).
    bool confirmNav;
    NSString* stringLocation;
    CNOpenEarsDelegate* delegate;
    
}
@property (nonatomic) BOOL isListening;
@property (nonatomic, copy) NSString *pathToDynamicallyGeneratedGrammar;
@property (nonatomic, copy) NSString *pathToDynamicallyGeneratedDictionary;

@property (nonatomic, strong) Slt *slt;
@property (nonatomic, strong) OpenEarsEventsObserver *openEarsEventsObserver;
@property (nonatomic, strong) PocketsphinxController *pocketsphinxController;
@property (nonatomic, strong) FliteController *fliteController;
@property (nonatomic, retain) CNOpenEarsDelegate* delegate;
-(id)initWithDelegate:(id)delegate;
-(void)listen;
-(void)speakSentence:(NSString *)sentence;
-(void)setUp;
-(void)stopListen;
-(void)resumeRecognition;
-(void)suspendRecoginition;
@end

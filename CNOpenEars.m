//
//  CNOpenEars.m
//  Campus Navigator
//
//  Created by Rich on 20/12/2012.
//  Copyright (c) 2012 UCC. All rights reserved.
//

#import "CNOpenEars.h"
#import <OpenEars/PocketsphinxController.h> // Please note that unlike in previous versions of OpenEars, we now link the headers through the framework.
#import <OpenEars/FliteController.h>
#import <OpenEars/LanguageModelGenerator.h>
#import <OpenEars/OpenEarsLogging.h>
#import "CNUtils.h"
#import "CNRootViewController.h"
@implementation CNOpenEars
@synthesize openEarsEventsObserver;
@synthesize fliteController;
@synthesize pathToDynamicallyGeneratedDictionary;
@synthesize pathToDynamicallyGeneratedGrammar;
@synthesize pocketsphinxController;
@synthesize slt;
@synthesize delegate;
@synthesize isListening;


- (void)dealloc {
    //Set delegate to nil;
	openEarsEventsObserver.delegate = nil;
    [super dealloc];
}
- (PocketsphinxController *)pocketsphinxController {
	if (pocketsphinxController == nil) {
		pocketsphinxController = [[PocketsphinxController alloc] init];
        pocketsphinxController.verbosePocketSphinx = TRUE; // Uncomment me for verbose debug output
	}
	return pocketsphinxController;
}

// Lazily allocated slt voice.
- (Slt *)slt {
	if (slt == nil) {
		slt = [[Slt alloc] init];
	}
	return slt;
}
// Lazily allocated FliteController.
- (FliteController *)fliteController {
	if (fliteController == nil) {
		fliteController = [[FliteController alloc] init];
        
	}
	return fliteController;
}

// Lazily allocated OpenEarsEventsObserver.
- (OpenEarsEventsObserver *)openEarsEventsObserver {
	if (openEarsEventsObserver == nil) {
		openEarsEventsObserver = [[OpenEarsEventsObserver alloc] init];
        
	}
	return openEarsEventsObserver;
}

-(id)initWithDelegate:(id)delegate{
    self = [super init];
    
    if(self){
        
    }
    return self;
}
-(void)setUp{
    queue = [[[NSMutableArray alloc] init] retain];
    confirmNav = NO;
    [self speakSentence:@"Setting up voice."];
    NSLog(@"SET UP CALLED");
    if(! self.pathToDynamicallyGeneratedDictionary){
    //player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
        
    LanguageModelGenerator *lmGenerator = [[LanguageModelGenerator alloc] init];
    NSArray *languageArray = [[NSArray alloc] initWithArray:[NSArray arrayWithObjects: // All capital letters.
                                                             @"ORB",
                                                             @"O",
                                                             @"RAHILY",
                                                             @"WESTERN GATEWAY",
                                                             @"CASTLEWHITE",
                                                             @"WEST WING",
                                                             @"EAST WING",
                                                             @"NORTH WING",
                                                             @"DEVERE HALL",
                                                             @"STUDENT CENTRE",
                                                             @"KANE",
                                                             @"LIBRARY",
                                                             @"BOOLE BASEMENT",
                                                             @"BUILDING",
                                                             @"GLUCKSMAN GALLERY",
                                                             @"WHATS NEAR ME",
                                                             @"WGB",
                                                             @"WW",
                                                             @"TAKE ME TO THE",
                                                             @"STOP",
                                                             @"YES",
                                                             @"NO",
                                                             nil]];
    NSString *name = @"LocationsNames";
        
    NSError *err = [lmGenerator generateLanguageModelFromArray:languageArray withFilesNamed:name];

        //[languageArray release];
    NSDictionary *languageGeneratorResults = nil;
    
    //[lmGenerator release];
    if([err code] == noErr) {
        
        languageGeneratorResults = [err userInfo];
        
        self.pathToDynamicallyGeneratedGrammar = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"volcab.gram"];
        self.pathToDynamicallyGeneratedDictionary = [languageGeneratorResults objectForKey:@"DictionaryPath"];
   } else {
        NSLog(@"Error: %@",[err localizedDescription]);
    }
        [self.openEarsEventsObserver setDelegate:self];
    }
    //[self listen];
    //[self stopListen];
}
-(void)listen{
    self.isListening = YES;
    [self.pocketsphinxController startListeningWithLanguageModelAtPath:self.pathToDynamicallyGeneratedGrammar dictionaryAtPath:self.pathToDynamicallyGeneratedDictionary languageModelIsJSGF:YES];
}

-(void)stopListen{
    self.isListening = NO;
    [self.pocketsphinxController stopListening];
}
-(void)suspendRecognition{
    
    [self.pocketsphinxController suspendRecognition];
    
}
-(void)resumeRecognition{
    if(!self.isListening){
        [self listen];
    }
    //this is also really really bad but will work for now.
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"StartBeep" ofType:@"mp3"];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    if(player != nil) [player release];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    player.numberOfLoops = 1; //Infinite
    player.delegate = self;
    [player play];
    //[self.pocketsphinxController resumeRecognition];
}

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"FinBeep2" ofType:@"mp3"];
    [self suspendRecognition];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    player = nil;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    player.numberOfLoops = 1; //Infinite
    
    [player play];
    //[hypothesis retain];
    if([hypothesis isEqualToString:@"(null)"]|| [hypothesis length] < 3 ){
        //Theres an error the sentence is either incomplete of we can't recognise what the user is saying
        [self speakSentence:@"Sorry I couldn't understand that."];
        [self resumeRecognition];
    }else{
        if(confirmNav){
            confirmNav = NO;
            if ([hypothesis isEqualToString:@"YES"]) {
                //correct answer
                //[self speakSentence:@""]
            
                [delegate giveStringLocation:stringLocation];
                [self suspendRecognition];
            }else if([hypothesis isEqualToString:@"NO"]){
                //incorrect place try again
                [self speakSentence:@"Speak command now"];
                [self resumeRecognition];
                
            }else{
                //error please repeat
                confirmNav = YES;
                [self speakSentence:[NSString stringWithFormat:@"Sorry I didn't get that. Confirm Navigation to %@ ", stringLocation]];
                [self resumeRecognition];
            }
        }
       else if ([hypothesis rangeOfString:@"TAKE ME"].location != NSNotFound ) {
           stringLocation = [[hypothesis stringByReplacingOccurrencesOfString:@"TAKE ME" withString:@""]retain];
           stringLocation = [stringLocation stringByReplacingOccurrencesOfString:@"TO" withString:@""];
           
           stringLocation = [stringLocation stringByReplacingOccurrencesOfString:@"THE" withString:@""];
           [stringLocation retain];
            [self speakSentence:[NSString stringWithFormat:@"Confirm Navigation to. %@", stringLocation]];
           confirmNav = YES;
           [self resumeRecognition];
           //[delegate giveStringLocation:[hypothesis stringByReplacingOccurrencesOfString:@"TAKE ME" withString:@""]];
            //[self stopListen];
       }else{
           [self speakSentence:@"Sorry I didn't get that."];
           [self resumeRecognition];
       }
        
        //[CNUtils displayAlertWithTitle:@"YOU SAID" andText:hypothesis andButtonText:@"OK"];
        //[delegate giveStringLocation:hypothesis];
    }
	NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
}

- (void) pocketsphinxDidStartCalibration {
	NSLog(@"Pocketsphinx calibration has started.");
}

- (void) pocketsphinxDidCompleteCalibration {


}

- (void) pocketsphinxDidStartListening {
    //[self.pocketsphinxController suspendRecognition];

	NSLog(@"Pocketsphinx is now listening.");
}

- (void) pocketsphinxDidDetectSpeech {
	NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
    
	NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
	NSLog(@"Pocketsphinx has stopped listening.");
}

- (void) pocketsphinxDidSuspendRecognition {
	NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
	NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
	NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFail { // This can let you know that something went wrong with the recognition loop startup. Turn on OPENEARSLOGGING to learn why.
	NSLog(@"Setting up the continuous recognition loop has failed for some reason, please turn on OpenEarsLogging to learn more.");
}
-(void)speakSentence:(NSString *)sentence{
    if(! [self.fliteController speechInProgress]){
        self.fliteController.speechInProgress = NO;
    [self.fliteController say:sentence withVoice:self.slt];
    }else{
        [queue addObject:sentence];
    }
    

}
-(void)fliteDidFinishSpeaking{
    if([queue count] > 0){
        [self speakSentence:[queue objectAtIndex:0]];
        [queue removeObject:[queue objectAtIndex:0]];
    }
}


#pragma AV PLayer Delegate methods
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"PLayer dur %f", player.duration);
    //This is really really bad but a quick fix for now
    if(player.duration <= 0.38){
        [self.pocketsphinxController resumeRecognition];
    }
}

@end

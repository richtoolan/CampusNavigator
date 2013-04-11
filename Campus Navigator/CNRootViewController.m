//
//  CNViewController.m
//  Campus Navigator
//
//  Created by Rich on 26/11/2012.
//  Copyright (c) 2012 UCC. All rights reserved.
//

#import "CNRootViewController.h"
#import "CNCommon.h"
#import "CNDAO.h"
#import <MapKit/MapKit.h>
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>
#import "CNUtils.h"
#import "CNMapViewController.h"
#import <MapBox/MapBox.h>
@interface CNRootViewController ()

@end

@implementation CNRootViewController
BOOL debug = NO;
@synthesize openEars;
@synthesize navigator;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.openEars = [[[CNOpenEars alloc] init] retain];
        self.openEars.delegate = (CNOpenEarsDelegate *)self;
        [self.openEars speakSentence:@"If you're visually impaired please press the bottom of the screen"];
        self.navigator = [[CNNavigator alloc] init];
        userVip = NO;
        vibrateRequired = NO;
        userIdentified = NO;
        self.navigator.delegate = (CNNavigatorDelegate *)self;
        self.navigator.openears = self.openEars;
        CNDAO *dao = [[CNDAO alloc] init];
        places = [[dao getBuildingNames] retain];
        [self.openEars updateVolcabWithPlaceNames:places];
        tapRecog = [[UITapGestureRecognizer alloc] init];
        tapRecog.numberOfTapsRequired = 1;
        tapRecog.numberOfTouchesRequired = 1;
        [self.view addGestureRecognizer:tapRecog];
}
    return self;
}
/**
 *
 *  touchBegan is called when the view is touched
 *  used to handle the bounds of the yes button
 *
 *
***/
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
  if(touchPoint.y >= yesAnswer.frame.origin.y){
        [self didClickButton:yesAnswer];
    }else{
        [self.nextResponder touchesBegan:touches withEvent:event];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    for (UIView *views in self.view.subviews) {
        [views removeFromSuperview];
    }
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    if(!userIdentified){
        UILabel *welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(BUTTON_GRID_SIZE, BUTTON_GRID_SIZE, self.view.frame.size.width - (BUTTON_GRID_SIZE *2), self.view.frame.size.width /3)];
        [welcomeLabel setText:@"Welcome."];
        [welcomeLabel setTextAlignment:NSTextAlignmentRight];
        [welcomeLabel setFont:[UIFont fontWithName:@"GillSans" size:50.0]];
        [welcomeLabel setTextColor:[UIColor whiteColor]];
        [welcomeLabel setBackgroundColor:[UIColor clearColor]];
        
        
        [self.view addSubview:welcomeLabel];
        [welcomeLabel setAlpha:0.0];
        welcomeLabel.transform = CGAffineTransformMakeScale(.7, .7);
        [welcomeLabel release];
        
        UILabel *questionLabel = [[UILabel alloc] initWithFrame:CGRectMake( BUTTON_GRID_SIZE,BUTTON_GRID_SIZE + self.view.frame.size.width /3, self.view.frame.size.width - (BUTTON_GRID_SIZE *2), self.view.frame.size.width /3)];
        [questionLabel setText:@"Are you visually impaired?"];
        [questionLabel setTextAlignment:NSTextAlignmentLeft];
        [questionLabel setNumberOfLines:3];
        [questionLabel setFont:[UIFont fontWithName:@"GillSans" size:40.0]];
        [questionLabel setTextColor:[UIColor whiteColor]];
        [questionLabel setBackgroundColor:[UIColor clearColor]];
        
        
        
        [self.view addSubview:questionLabel];
        [questionLabel setAlpha:0.0];
        questionLabel.transform = CGAffineTransformMakeScale(.7, .7);
        [questionLabel release];
        
        UIButton *noAnswer = [UIButton buttonWithType:UIButtonTypeCustom];
        noAnswer.layer.cornerRadius = 10.0;
        [noAnswer setBackgroundColor:[UIColor redColor]];
        [noAnswer setFrame:CGRectMake(self.view.frame.size.width/2+(BUTTON_GRID_SIZE *1.6),self.view.frame.size.width/2 + BUTTON_GRID_SIZE, (self.view.frame.size.width/2 - (BUTTON_GRID_SIZE *2)), BUTTON_GRID_SIZE * 2)];
        [noAnswer setTitle:@"No" forState:UIControlStateNormal];
        [noAnswer setTintColor:[UIColor blackColor]];
        [[noAnswer titleLabel] setFont:[UIFont fontWithName:@"GillSans" size:30.0]];
        [noAnswer addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventAllTouchEvents];
        
        [noAnswer setAlpha:0.0];
        noAnswer.tag = 0;
        [self.view addSubview:noAnswer];
        noAnswer.transform = CGAffineTransformMakeScale(0.7, 0.7);
        yesAnswer = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        yesAnswer.layer.cornerRadius = 10.0;
        yesAnswer.tag = 1;
        [yesAnswer addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventAllTouchEvents];
        [yesAnswer setBackgroundColor:[UIColor redColor]];
    
        [yesAnswer setFrame:CGRectMake(BUTTON_GRID_SIZE, self.view.frame.size.height/2 +BUTTON_GRID_SIZE , (self.view.frame.size.width - (BUTTON_GRID_SIZE *2)), self.view.frame.size.height/2-(BUTTON_GRID_SIZE * 2))];
        [yesAnswer setTitle:@"Yes" forState:UIControlStateNormal];
        [yesAnswer setTintColor:[UIColor blackColor]];
        [[yesAnswer titleLabel]setFont:[UIFont fontWithName:@"GillSans" size:30.0]];
        
        [yesAnswer setAlpha:0.0];
        
        [self.view addSubview:yesAnswer];
        yesAnswer.transform = CGAffineTransformMakeScale(0.7, 0.7);
        [UIView animateWithDuration:.5 animations:^{
            [welcomeLabel setAlpha:1.0];
            welcomeLabel.transform = CGAffineTransformIdentity;
            } completion:^(BOOL c){
            [UIView animateWithDuration:.5 animations:^{
                [questionLabel setAlpha:1.0];
                questionLabel.transform = CGAffineTransformIdentity;
            } completion:^(BOOL c){
                [UIView animateWithDuration:.5 animations:^{
                    [noAnswer setAlpha:1.0];
                    noAnswer.transform = CGAffineTransformIdentity;
                    [yesAnswer setAlpha:1.0];
                    yesAnswer.transform = CGAffineTransformIdentity;
                    
                } completion:^(BOOL c){
                    
                }];
            }];
        }];
        
    }else{
        [self setUpView];
    }
    [self.openEars setUp];
}
/**
 *
 *  didClickButtons:sender
 *  Object listener for when a button is clicked
 *
 *
 ***/
-(void)didClickButton:(id)sender{
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    UIButton *button = (UIButton *)sender;
    if (button.tag) {
        if(!userIdentified){
            userIdentified = YES;
            userVip = YES;
            
            [self.openEars speakSentence:@"Thanks, now touch the centre of the screen to activate voice commands, press it again to stop."];
        }
        
        
    }else{
        userVip = NO;
    }
    [UIView animateWithDuration:.5 animations:^(){
        for (UIView *sv in [self.view subviews]){
            sv.transform = CGAffineTransformMakeScale(.3, .3);
            [sv setAlpha:0.0];
            
        }
    } completion:^(BOOL c){
        for (UIView *sv in [self.view subviews]){
            [sv removeFromSuperview];
        }
        [self setUpView];
        }
     ];
    
}
-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}
/**
 *
 *  trebleTap
 *  Was called trebleTap to handle a trebleTap gesture on the screen
 *  This was later removed for a better approach
 *
 ***/
-(void)trebleTap
{
    if(userVip){
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
        if([self.navigator isNavigating]){

            if(debug){
                [self.navigator stopNav];
                [mapView removePathAnnotation];
            }else{
                if (userVip) {
                    [self.openEars stopListen];
                    
                    [self.navigator stopNav];
                    [mapView removePathAnnotation];
                    
                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                }else{
                    [self.navigator stopNav];
                    [mapView removePathAnnotation];
                    [actionButton setBackgroundColor:[UIColor grayColor]];
                    
                    [actionButton setTitle:@"NOT NAVIGATING" forState:UIControlStateDisabled];
                    actionButton.enabled = NO;
                }
            }
        }else{
            if (debug) {
                [self.navigator beginNavigationToLocation:@"Student Centre"];
            }else{
                if(userVip){
                    if(self.openEars.isListening){
                        [self.openEars speakSentence:@"Voice control stopped."];
                        [self.openEars stopListenAndVibrate];
                        [buttonLabel setText:@"START VOICE CONTROL"];
                        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    }else{
                        [self.openEars listen];
                        [buttonLabel setText:@"STOP VOICE CONTROL"];
                        
                    }
                }else{
                }
            }
        }
        
    
}
/**
 *
 *  setUpView 
 *  Called once the application has detrermined if the user is VIP or not.
 *
 *
 ***/
- (void)setUpView{
    
    CGRect parentFrame = self.view.frame;
    CGFloat buttonSize = 50.0f;
    //userVIP = YES;
    [self.view removeGestureRecognizer:tapRecog];
    if(userVip){
    
        actionButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [actionButton setBackgroundColor:VIP_COLOUR];
        [actionButton addTarget:self action:@selector(trebleTap) forControlEvents:UIControlEventTouchDown];
        [actionButton setFrame:CGRectMake(BUTTON_GRID_SIZE , BUTTON_GRID_SIZE, parentFrame.size.width -( BUTTON_GRID_SIZE *2), parentFrame.size.height -( BUTTON_GRID_SIZE *2)  )];
         buttonLabel = [[UILabel alloc] initWithFrame:CGRectOffset(actionButton.frame, -BUTTON_GRID_SIZE, -BUTTON_GRID_SIZE) ];
        [buttonLabel setBackgroundColor:[UIColor clearColor]];
        [buttonLabel setText:@"START VOICE CONTROL"];
        [buttonLabel setNumberOfLines:3];
        [buttonLabel setFont:[UIFont fontWithName:@"GillSans-Bold" size:40.0]];
        [buttonLabel setTextColor:[UIColor whiteColor]];
        //[buttonLabel set]
        [actionButton addSubview:buttonLabel];
        [buttonLabel setTextAlignment:NSTextAlignmentCenter];
         [buttonLabel release];
        actionButton.layer.cornerRadius = 10.0;
        actionButton.tag = 0;
        [actionButton setAlpha:0.0];
        actionButton.transform = CGAffineTransformMakeScale(0.7, 0.7);
        UIButton *backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [backButton addTarget:self action:@selector(reset) forControlEvents:UIControlEventAllTouchEvents];
        [backButton setFrame:CGRectMake(0, 0, 20, 20)];
        backButton.layer.cornerRadius = 3.0;
        [backButton setBackgroundColor:[UIColor whiteColor]];
        [backButton setTitle:@"<" forState:UIControlStateNormal];
        [[backButton titleLabel] setTextColor:[UIColor blackColor]];
        [self.view addSubview:backButton];
        [backButton release];
        
        [self.view addSubview:actionButton];
    }
    else{
    
        
        actionButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        actionButton.enabled = NO;
        actionButton.layer.cornerRadius = 10.0;
        [actionButton setBackgroundColor:[UIColor grayColor]];
        [actionButton setFrame:CGRectMake( GRID_SIZE, self.view.frame.size.height - buttonSize-BUTTON_GRID_SIZE  , (self.view.frame.size.width - (GRID_SIZE *2)), buttonSize)];
        [actionButton setTitle:@"STOP" forState:UIControlStateNormal];
        [actionButton setTitle:@"NOT NAVIGATING" forState:UIControlStateDisabled];
        [actionButton setTintColor:[UIColor blackColor]];
        [[actionButton titleLabel]setFont:[UIFont fontWithName:@"GillSans" size:30.0]];
        [actionButton addTarget:self action:@selector(trebleTap) forControlEvents:UIControlEventAllTouchEvents];
        
        [actionButton setAlpha:0.0];
        actionButton.transform  = CGAffineTransformMakeScale(0.7, 0.7);
        UIButton *backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [backButton addTarget:self action:@selector(reset) forControlEvents:UIControlEventAllTouchEvents];
        [backButton setFrame:CGRectMake(0, self.view.frame.size.height-20, 20, 20)];
        backButton.layer.cornerRadius = 3.0;
        [backButton setBackgroundColor:[UIColor whiteColor]];
        [backButton setTitle:@"<" forState:UIControlStateNormal];
        [[backButton titleLabel] setTextColor:[UIColor blackColor]];
        [self.view addSubview:backButton];
        [backButton release];
        [self.view addSubview:actionButton];

    mapView = [[CNMapViewController alloc] initWithFrame:CGRectMake(GRID_SIZE, GRID_SIZE, parentFrame.size.width - GRID_SIZE*2, parentFrame.size.height - buttonSize-BUTTON_GRID_SIZE *2 - GRID_SIZE)];
   [self.view addSubview:mapView];
        [mapView setAlpha:0.0];
        mapView.transform = CGAffineTransformMakeScale(0.7, 0.7);
}
    [UIView animateWithDuration:0.5 animations:^(){
        for (UIView *sv in [self.view subviews]){
            sv.transform = CGAffineTransformIdentity;
            [sv setAlpha:1.0];
            
        }
        
        
    }];
    CNDAO *dao = [[CNDAO alloc] init];
    NSArray *buildings = [[dao getBuildingNodes] retain];
    [mapView addBuildings:buildings];
    [dao release];
    [buildings release];
}
/**
 *
 *  reset 
 *  Used during demoing to reset view and allow user to pick again
 *
 *
 ***/

-(void)reset{
    userIdentified = NO;
    [self viewDidLoad];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/**
 *
 *  setPathObject:pointArray
 *  Keep point to pointsArray and displays path on the map.
 *
 *
 ***/
-(void)setPathObject:(NSArray *)pointsArray{
    
    points = [pointsArray retain];
    for(NSArray *path in points){
        if ([path count] >= 1) {
            
            
            [mapView addAnnotationForPoints:path];
        }
    }
    
}
/**
 *
 *  debug
 *  used for enabling and disablin debug
 *
 *
 ***/
-(void)debug{
    debug = !debug;
}
/**
 *
 *  giveStringLocation:text
 *  text is passed to navigator if it's not "STOP"
 *
 *
 ***/
-(void)giveStringLocation:(NSString *)text{
    if([text isEqualToString:@"STOP"]){
        actionButton.enabled = NO;
        [mapView removePathAnnotation];
        [actionButton setBackgroundColor:[UIColor grayColor]];
        [self.openEars stopListen];
    }else if(![self.navigator isNavigating]){
        actionButton.enabled = YES;
        [actionButton setBackgroundColor:[UIColor redColor]];
        [self.navigator beginNavigationToLocation:text];
        [buttonLabel setText:@"STOP NAVIGATION"];
    }
}
/**
 *
 *  saveFavouriteWithName:name
 *  saves the favourite name to the users Database
 *
 *
 ***/
-(void)saveFavouriteWithName:(NSString *)name{
    CNDAO *dao = [[CNDAO alloc] init];
    [dao saveFavouriteWithName:[[name stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"SPACE" withString:@" "] AndLocation:[self.navigator getUserLocation]];
    [self.openEars updateVolcabWithString:[[name stringByReplacingOccurrencesOfString:@" " withString:@""]stringByReplacingOccurrencesOfString:@"SPACE" withString:@" "]];
    [dao release];
}
/**
 *
 *  generateVoiceForFiveNearest
 *  Called the voice controller with the navigators array of strings.
 *
 *
 ***/
-(void)generateVoiceForFiveNearest{
    [self.openEars speakSentence:[self.navigator getFourNearestWithDirections]];
}
/**
 *
 *  centreOnPoint:point
 *  Tells the map view to centre on a coordinate
 *
 *
 ***/
-(void)centreOnPoint:(CLLocation *)point{
    [mapView centreOnPoint:point];
}
/**
 *
 *  annotationClickedWithString:strin 
 *  String is passed to the navigator to being navigation
 *
 *
 ***/
-(void)annotationClickedWithString:(NSString *)string{
    if([self.navigator isNavigating]){
       [self.navigator stopNav];
        [mapView removePathAnnotation];
    
    }
    [self giveStringLocation:string];

}

-(void)dealloc{
    
    self.openEars = nil;
    [points release];
    [super dealloc];
}
@end





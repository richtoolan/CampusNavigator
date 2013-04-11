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
        //pathFinder = [[[CNPathFinder alloc] init] retain];
        self.navigator = [[CNNavigator alloc] init];
        userVip = NO;
        vibrateRequired = NO;
        userIdentified = NO;
        self.navigator.delegate = (CNNavigatorDelegate *)self;
        self.navigator.openears = self.openEars;
        CNDAO *dao = [[CNDAO alloc] init];
        places = [[dao getBuildingNames] retain];
        [self.openEars updateVolcabWithPlaceNames:places];
        //UITapGestureRecognizer *tapRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(trebleTap)];
        //tapRecog.numberOfTapsRequired = 3;
        //[self.view addGestureRecognizer:tapRecog];
        //[tapRecog release];

        //points = [[dao getNearestPointForLat:51.893677 AndLon:-8.49219] retain];
        //NSLog(@"Point test: %@",[dao getNearestPointForLat:51.89367322618882 AndLon:-8.493998441763681]);
        ////NSLog(@"Points are %@",points);
        //NSMutableArray *arr = [dao testPathID:1:nil dest:12];
        //[dao testPathID:5];
        //NSLog(@"%@", arr);
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
        UIButton *yesAnswer = [UIButton buttonWithType:UIButtonTypeCustom];
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

    // Do any additional setup after loading the view.
}
-(void)didClickButton:(id)sender{
    
    UIButton *button = (UIButton *)sender;
    if (button.tag) {
        if(!userIdentified){
            userIdentified = YES;
            userVip = YES;
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            [self.openEars speakSentence:@"Thanks, now touch the centre of the screen to activate voice commands, press it again to stop."];
            
            //[self saveFavouriteWithName:@"Trial"];
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
                    //[self.navigator stopNav];
                    //[mapView removePathAnnotation];
                    
                }
            }
            //[self.navigator beginNavigationToLocation:@"Western Gateway Building"];
        }
        //[openEars listen];
        
        //[self test];
                //AudioServicesPlaySystemSoundWithVibration(4095,nil,dict);
        //[CNUtils displayAlertWithTitle:@"Detected Shake" andText:@"Wait for prompt before speaking." andButtonText:@"OK"];
       
    
}
- (void)setUpView{
    
    CGRect parentFrame = self.view.frame;
    CGFloat buttonSize = 50.0f;
    //userVIP = YES;
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
        [self.view addSubview:actionButton];
        /*
    mapView = [[CNMapViewController alloc] initWithFrame:CGRectMake(GRID_SIZE, GRID_SIZE, parentFrame.size.width - GRID_SIZE*2, parentFrame.size.height - buttonSize-BUTTON_GRID_SIZE *2 - GRID_SIZE)];
    [mapView setContentSize:CGSizeMake(TILE_WIDTH/2 * 10, TILE_HEIGHT/2 * 10)];
    [mapView setContentOffset:CGPointMake(TILE_WIDTH/2 * 5.5, TILE_HEIGHT/2 *5.5)];
    //[]

    //[mapView setZoomScale:2.0 animated:YES];
    for (int i = 0; i <= 9; i ++){
        for(int x = 0; x <= 9; x ++){
            UIImageView *imageTile = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"map_tile_%i%i.png", i, x]]];
            [imageTile setFrame:CGRectMake(TILE_WIDTH/2 * x, TILE_HEIGHT/2 * i, TILE_WIDTH/2, TILE_HEIGHT/2)];
            imageTile.tag = i+x;
            [mapView addSubview:imageTile];
            [imageTile release];
        }
        
    }
    
    UIImageView *imageTile = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_tile_54.png"]];
    [imageTile setFrame:CGRectMake(TILE_WIDTH *5, TILE_HEIGHT * 5, TILE_WIDTH, TILE_HEIGHT)];
    [mapView addSubview:imageTile];
    
    imageTile = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_tile_54.png"]];
    [imageTile setFrame:CGRectMake(TILE_WIDTH *5, TILE_HEIGHT * 5, TILE_WIDTH, TILE_HEIGHT)];
    [mapView addSubview:imageTile];
    [imageTile release];
    imageTile = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_tile_53.png"]];
    [imageTile setFrame:CGRectMake(TILE_WIDTH *4, TILE_HEIGHT * 5, TILE_WIDTH, TILE_HEIGHT)];
    [mapView addSubview:imageTile];
    [imageTile release];
    imageTile = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_tile_55.png"]];
    [imageTile setFrame:CGRectMake(TILE_WIDTH *6, TILE_HEIGHT * 5, TILE_WIDTH, TILE_HEIGHT)];
    [mapView addSubview:imageTile];
    [imageTile release];
    imageTile = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_tile_64.png"]];
    [imageTile setFrame:CGRectMake(TILE_WIDTH *5, TILE_HEIGHT * 6, TILE_WIDTH, TILE_HEIGHT)];
    [mapView addSubview:imageTile];
    [imageTile release];
    imageTile = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_tile_63.png"]];
    [imageTile setFrame:CGRectMake(TILE_WIDTH *4, TILE_HEIGHT * 6, TILE_WIDTH, TILE_HEIGHT)];
    [mapView addSubview:imageTile];
    [imageTile release];
    imageTile = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_tile_65.png"]];
    [imageTile setFrame:CGRectMake(TILE_WIDTH *6, TILE_HEIGHT * 6, TILE_WIDTH, TILE_HEIGHT)];
    [mapView addSubview:imageTile];
    [imageTile release];
    
    [self.view addSubview:mapView];
    
    */
    
    mapView = [[CNMapViewController alloc] initWithFrame:CGRectMake(GRID_SIZE, GRID_SIZE, parentFrame.size.width - GRID_SIZE*2, parentFrame.size.height - buttonSize-BUTTON_GRID_SIZE *2 - GRID_SIZE)];
    //mapView.alpha = 0.8;//
    //NSLog(@"%@", [pathFinder getNodesForPathFrom:33 toDest:36]);
    //[mapView ]
    mapView.parentPointer = self;
    [self.view addSubview:mapView];
        [mapView setAlpha:0.0];
        mapView.transform = CGAffineTransformMakeScale(0.7, 0.7);
    //[dao pathFrom:@"30" to:@"12"];

    //[mapView release];
    /*
    MKMapView *map = [[MKMapView alloc] init];
    [map setFrame:CGRectMake(GRID_SIZE, GRID_SIZE, parentFrame.size.width - GRID_SIZE*2, parentFrame.size.height - buttonSize-BUTTON_GRID_SIZE *2 - GRID_SIZE)];
    [map setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(51.893086, -8.491762), MKCoordinateSpanMake(0.001, 0.001))];
    [map setMapType:MKMapTypeHybrid];
    [map setShowsUserLocation:YES];
    [self.view addSubview:map];
    MyAnnotation *anno = [[MyAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(51.893086, -8.491762) andTitle:@"QUAD"];
    MKAnnotationView *view = [[MKAnnotationView alloc] initWithAnnotation:anno reuseIdentifier:@"MAP_ANNO"];
    view.image = [UIImage imageNamed:@"google_maps.png"];
    [map addAnnotation:anno];*/
    
   // CNUtils *utils = [[CNUtils alloc] init];
    //[utils isHeadsetPluggedIn];
    /*
    if([CNUtils isHeadsetPluggedIn]){
        [CNUtils displayAlertWithTitle:@"HEADPHONES DETECTED" andText:@"Headphones are plugged in" andButtonText:@"OK"];
    }else{
        [CNUtils displayAlertWithTitle:@"HEADPHONES NOT FOUND" andText:@"Headphones are not plugged in" andButtonText:@"OK"];
    }*/
    
    
    //[utils release];
    //[self.navigator beginNavigationToLocation:@"WGB"];
    }
    [UIView animateWithDuration:0.5 animations:^(){
        for (UIView *sv in [self.view subviews]){
            sv.transform = CGAffineTransformIdentity;
            [sv setAlpha:1.0];
            
        }
        
        
    }];
    //[self generateVoiceForFiveNearest];
    CNDAO *dao = [[CNDAO alloc] init];
    //places = [[dao getBuildingNames] retain];
    NSArray *buildings = [[dao getBuildingNodes] retain];
    [mapView addBuildings:buildings];
    [dao release];
    [buildings release];
}

/*-(void) test{
    
     float newScale = [mapView zoomScale] * 3.0;
     CGRect zoomRect = [mapView zoomRectForScale:newScale withCenter:mapView.contentOffset];
     [mapView zoomToRect:zoomRect animated:YES];
     
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setPathObject:(NSArray *)pointsArray{
    
    points = [pointsArray retain];
    
    
    //badly set map view
    for(NSArray *path in points){
        if ([path count] >= 1) {
            
            
            [mapView addAnnotationForPoints:path];
        }
    }
    
}
-(void)debug{
    debug = !debug;
}
-(void)giveStringLocation:(NSString *)text{
    NSLog(@"String is %@", text);
    if(![self.navigator isNavigating]){
        actionButton.enabled = YES;
        [actionButton setBackgroundColor:[UIColor redColor]];
        [self.navigator beginNavigationToLocation:text];
    }else if([text isEqualToString:@"STOP"]){
        actionButton.enabled = NO;
        [actionButton setBackgroundColor:[UIColor grayColor]];
        [self.navigator stopNav];
        [self.openEars stopListen];
        [self.openEars speakSentence:@"Navigation Stopped"];
    }
}
-(void)saveFavouriteWithName:(NSString *)name{
    CNDAO *dao = [[CNDAO alloc] init];
    [dao saveFavouriteWithName:[[name stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"SPACE" withString:@" "] AndLocation:[self.navigator getUserLocation]];
    [self.openEars updateVolcabWithString:[[name stringByReplacingOccurrencesOfString:@" " withString:@""]stringByReplacingOccurrencesOfString:@"SPACE" withString:@" "]];
    [dao release];
}
-(void)generateVoiceForFiveNearest{
    [self.openEars speakSentence:[self.navigator getFourNearestWithDirections]];
}
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





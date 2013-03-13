//
//  CNViewController.m
//  Campus Navigator
//
//  Created by Rich on 26/11/2012.
//  Copyright (c) 2012 UCC. All rights reserved.
//

#import "CNRootViewController.h"
#import "CNCommon.h"
#import <MapKit/MapKit.h>
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>
#import "CNUtils.h"
#import "CNMapViewController.h"
#import <MapBox/MapBox.h>
@interface CNRootViewController ()

@end

@implementation CNRootViewController
BOOL debug = YES;
@synthesize openEars;
@synthesize navigator;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.openEars = [[[CNOpenEars alloc] init] retain];
        self.openEars.delegate = (CNOpenEarsDelegate *)self;
        //pathFinder = [[[CNPathFinder alloc] init] retain];
        self.navigator = [[CNNavigator alloc] init];
        self.navigator.delegate = (CNNavigatorDelegate *)self;
        self.navigator.openears = self.openEars;
        UITapGestureRecognizer *tapRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(trebleTap)];
        tapRecog.numberOfTapsRequired = 3;
        [self.view addGestureRecognizer:tapRecog];
        [tapRecog release];
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
    [self setUpView];
    [self.openEars setUp];

    // Do any additional setup after loading the view.
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
    
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        if([self.navigator isNavigating]){
            if(debug){
                [self.navigator stopNav];
                [mapView removePathAnnotation];
            }else{
                [self.openEars stopListen];
                [self.navigator stopNav];
                [mapView removePathAnnotation];
            }
        }else{
            if (debug) {
                [self.navigator beginNavigationToLocation:@"Student Centre"];
            }else{
                if(self.openEars.isListening){
                
                    [self.openEars speakSentence:@"Voice control stopped."];
                    [self.openEars stopListen];
                }else{
                    [self.openEars listen];
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
    CGFloat buttonSize = 50.0f;
    CGRect parentFrame = self.view.frame;
    UIButton *compassButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [compassButton setBackgroundColor:BUTTON_COLOUR];
    [compassButton addTarget:self action:@selector(debug) forControlEvents:UIControlEventTouchDown];
    [compassButton setImage:[UIImage imageNamed:@"compass.png"] forState:UIControlStateNormal];
    [compassButton setFrame:CGRectMake(BUTTON_GRID_SIZE , parentFrame.size.height -( BUTTON_GRID_SIZE + buttonSize), buttonSize, buttonSize  )];
    compassButton.tag = 0;
    [self.view addSubview:compassButton];
    
    UIButton *locateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [locateButton setBackgroundColor:BUTTON_COLOUR];
    [locateButton setImage:[UIImage imageNamed:@"locate.png"] forState:UIControlStateNormal];
    
    [locateButton addTarget:self action:@selector(debug) forControlEvents:UIControlEventTouchDown];
    [locateButton setFrame:CGRectMake(parentFrame.size.width/2 -( BUTTON_GRID_SIZE/2 + buttonSize) , parentFrame.size.height -( BUTTON_GRID_SIZE + buttonSize), buttonSize, buttonSize  )];
    locateButton.tag = 1;
    [self.view addSubview:locateButton];
    
    UIButton *nearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nearButton setBackgroundColor:BUTTON_COLOUR];
    [nearButton setImage:[UIImage imageNamed:@"near.png"] forState:UIControlStateNormal];
    [nearButton setFrame:CGRectMake(parentFrame.size.width/2 +( BUTTON_GRID_SIZE/2 ) , parentFrame.size.height -( BUTTON_GRID_SIZE + buttonSize), buttonSize, buttonSize  )];
    
    [nearButton addTarget:self action:@selector(debug) forControlEvents:UIControlEventTouchDown];
    nearButton.tag = 2;
    [self.view addSubview:nearButton];
    
    UIButton *googleMapsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [googleMapsButton setBackgroundColor:BUTTON_COLOUR];
    [googleMapsButton setImage:[UIImage imageNamed:@"google_maps.png"] forState:UIControlStateNormal];
    
    [googleMapsButton addTarget:self action:@selector(debug) forControlEvents:UIControlEventTouchDown];
    [googleMapsButton setFrame:CGRectMake(parentFrame.size.width -( BUTTON_GRID_SIZE + buttonSize) , parentFrame.size.height -( BUTTON_GRID_SIZE + buttonSize), buttonSize, buttonSize  )];
    googleMapsButton.tag = 3;
    [self.view addSubview:googleMapsButton];
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
    [self.navigator beginNavigationToLocation:text];
    }else if([text isEqualToString:@"STOP"]){
        
        [self.navigator stopNav];
        [self.openEars stopListen];
        [self.openEars speakSentence:@"Navigation Stopped"];
    }
}
-(void)annotationClickedWithString:(NSString *)string{
    [self giveStringLocation:string];
}

-(void)dealloc{
    
    self.openEars = nil;
    [points release];
    [super dealloc];
}
@end





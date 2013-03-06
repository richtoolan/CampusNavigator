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
#import "CNDAO.h"
@interface CNRootViewController ()

@end

@implementation CNRootViewController
@synthesize openEars;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.openEars = [[[CNOpenEars alloc] init] retain];
        self.openEars.delegate = (CNOpenEarsDelegate *)self;
        CNDAO *dao = [[CNDAO alloc] init];
        points = [[dao returnAllPoints] retain];
        //NSLog(@"Points are %@",[dao returnAllPoints]);
        for(NSDictionary *point in points){
           CLLocation *loc = [point objectForKey:@"pointCoordinate"];
            NSLog(@"%f",[loc getDistanceFrom:[[CLLocation alloc] initWithLatitude:51.893464 longitude:-8.492174]]);
            
        }
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

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [openEars listen];
        
        //[self test];
                //AudioServicesPlaySystemSoundWithVibration(4095,nil,dict);
        [CNUtils displayAlertWithTitle:@"Shaken" andText:@"Not stired" andButtonText:@"OK"];
       
    }
}
- (void)setUpView{
    CGFloat buttonSize = 50.0f;
    CGRect parentFrame = self.view.frame;
    UIButton *compassButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [compassButton setBackgroundColor:BUTTON_COLOUR];
    [compassButton addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [compassButton setImage:[UIImage imageNamed:@"compass.png"] forState:UIControlStateNormal];
    [compassButton setFrame:CGRectMake(BUTTON_GRID_SIZE , parentFrame.size.height -( BUTTON_GRID_SIZE + buttonSize), buttonSize, buttonSize  )];
    compassButton.tag = 0;
    [self.view addSubview:compassButton];
    
    UIButton *locateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [locateButton setBackgroundColor:BUTTON_COLOUR];
    [locateButton addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [locateButton setImage:[UIImage imageNamed:@"locate.png"] forState:UIControlStateNormal];
    [locateButton setFrame:CGRectMake(parentFrame.size.width/2 -( BUTTON_GRID_SIZE/2 + buttonSize) , parentFrame.size.height -( BUTTON_GRID_SIZE + buttonSize), buttonSize, buttonSize  )];
    locateButton.tag = 1;
    [self.view addSubview:locateButton];
    
    UIButton *nearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nearButton setBackgroundColor:BUTTON_COLOUR];
    [nearButton addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [nearButton setImage:[UIImage imageNamed:@"near.png"] forState:UIControlStateNormal];
    [nearButton setFrame:CGRectMake(parentFrame.size.width/2 +( BUTTON_GRID_SIZE/2 ) , parentFrame.size.height -( BUTTON_GRID_SIZE + buttonSize), buttonSize, buttonSize  )];
    nearButton.tag = 2;
    [self.view addSubview:nearButton];
    
    UIButton *googleMapsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [googleMapsButton setBackgroundColor:BUTTON_COLOUR];
    [googleMapsButton addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [googleMapsButton setImage:[UIImage imageNamed:@"google_maps.png"] forState:UIControlStateNormal];
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
    
    CNMapViewController *mapView = [[CNMapViewController alloc] initWithFrame:CGRectMake(GRID_SIZE, GRID_SIZE, parentFrame.size.width - GRID_SIZE*2, parentFrame.size.height - buttonSize-BUTTON_GRID_SIZE *2 - GRID_SIZE)];
    //mapView.alpha = 0.8;//

    [self.view addSubview:mapView];
    [mapView release];
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
    
    CNUtils *utils = [[CNUtils alloc] init];
    [utils isHeadsetPluggedIn];
    /*
    if([CNUtils isHeadsetPluggedIn]){
        [CNUtils displayAlertWithTitle:@"HEADPHONES DETECTED" andText:@"Headphones are plugged in" andButtonText:@"OK"];
    }else{
        [CNUtils displayAlertWithTitle:@"HEADPHONES NOT FOUND" andText:@"Headphones are not plugged in" andButtonText:@"OK"];
    }*/
    
    
    [utils release];
    
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


-(void)giveStringLocation:(NSString *)text{
    NSLog(@"String is %@", text);
}
-(void)dealloc{
    
    self.openEars = nil;
    [super dealloc];
}
@end





//
//  CNAnnotationView.m
//  Campus Navigator
//
//  Created by Rich on 20/12/2012.
//  Copyright (c) 2012 UCC. All rights reserved.
//

#import "CNAnnotationView.h"
#import "CNCommon.h"
#import "CNUtils.h"
@implementation CNAnnotationView
- (id)initWithFrame:(CGRect)frame andText:(NSString *)string
{
    self = [super init];
    if (self) {
        _viewExpanded = NO;
        self.view.frame = frame;
        self.view.alpha = 0.00;
        self.view.layer.backgroundColor = [[UIColor greenColor] CGColor];
        self.view.layer.cornerRadius = GRID_SIZE/2;
        self.title = string;
        UILabel *labelText = [[UILabel alloc] initWithFrame:CGRectOffset(self.view.frame, -(GRID_SIZE * 2), -(GRID_SIZE *2))];
        [labelText setText:string];
        [labelText setTextAlignment:NSTextAlignmentCenter];
        [labelText setFont:[UIFont fontWithName:@"Arial-BoldMT" size:20.0]];
        [labelText setTextColor:[UIColor whiteColor]];
        [labelText setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:labelText];
        [labelText release];
        _takeMeHere =[UIButton buttonWithType:UIButtonTypeCustom];
        [[_takeMeHere titleLabel] setFont:[UIFont fontWithName:@"Arial-BoldMT" size:20.0]];
        
        [_takeMeHere setFrame:CGRectInset(CGRectOffset(self.view.frame,  -(GRID_SIZE *2) , GRID_SIZE), (GRID_SIZE/2),  (GRID_SIZE/2))];
        [_takeMeHere addTarget:self action:@selector(testClick) forControlEvents:UIControlEventTouchDown];
        [_takeMeHere setTitle:@"Take Me Here" forState:UIControlStateNormal];
        _takeMeHere.layer.cornerRadius = GRID_SIZE;
        
        _takeMeHere.layer.backgroundColor = [[UIColor redColor] CGColor];
        //_moreInfo = [UIButton buttonWithType:UIButtonTypeCustom];
        //[[_moreInfo titleLabel] setFont:[UIFont fontWithName:@"Arial-BoldMT" size:20.0]];
        //[_moreInfo setFrame:CGRectInset(CGRectOffset(self.view.frame,  -(GRID_SIZE *2) , self.view.frame.size.height + (GRID_SIZE) ), (GRID_SIZE/2),  (GRID_SIZE/2))];
        //[_moreInfo setFrame:CGRectOffset(self.view.frame, -(GRID_SIZE *4), self.view.frame.size.height + (GRID_SIZE*2))];
        //[_moreInfo setTitle:@"More Info" forState:UIControlStateNormal];
        //_moreInfo.layer.cornerRadius = GRID_SIZE;
        //_moreInfo.layer.backgroundColor = [[UIColor redColor] CGColor];
        [self.view addSubview:_takeMeHere];
        //[self.view addSubview:_moreInfo];
        //_moreInfo.alpha = 0.0;
        _takeMeHere.alpha = 0.0;
        // Initialization code
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if(!_viewExpanded){
        _viewExpanded = YES;
        [UIView animateWithDuration:.5 animations:^(){
            [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height *2.6)];
            
        } completion:^(BOOL c){
            //_moreInfo.alpha = 1.0;
            _takeMeHere.alpha = 1.0;
        }];
    }else{
        _viewExpanded = NO;
        [UIView animateWithDuration:.5 animations:^(){
            [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height/2.6)];
            //_moreInfo.alpha = 0.0;
            _takeMeHere.alpha = 0.0;
        } completion:^(BOOL c){
            
        }];
    }
}
-(void)testClick{
    
    [self.delegate annotationClickedWithString:self.title];

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

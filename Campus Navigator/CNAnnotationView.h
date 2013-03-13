//
//  CNAnnotationView.h
//  Campus Navigator
//
//  Created by Rich on 20/12/2012.
//  Copyright (c) 2012 UCC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CNCustomAnnotation;
@class CNAnnotationDelegate;
@interface CNAnnotationView : UIViewController{
    BOOL _viewExpanded;
    UIButton *_moreInfo;
    UIButton *_takeMeHere;
    
}
@property (nonatomic, retain)CNAnnotationDelegate *delegate;

- (id)initWithFrame:(CGRect)frame andText:(NSString*)anno;
@end

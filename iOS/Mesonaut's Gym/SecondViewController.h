//
//  SecondViewController.h
//  Horton's Gym
//
//  Created by Emil on 29/04/15.
//  Copyright (c) 2015 digitalemil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@import WatchConnectivity;

@interface SecondViewController : UIViewController<CLLocationManagerDelegate>

-(void)readHR;
-(void)readSteps;
-(void)signal:(int)i;
- (void) processHRResults:(NSArray *)results;
- (IBAction)uploadStepsPressed:(id)sender;
- (IBAction)uploadHRsPressed:(id)sender;

@end


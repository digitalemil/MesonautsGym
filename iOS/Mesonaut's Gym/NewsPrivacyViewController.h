//
//  NewsPrivacyViewController.h
//  Horton's Gym
//
//  Created by Emil on 29/04/15.
//  Copyright (c) 2015 digitalemil. All rights reserved.
//

#ifndef Horton_s_Gym_NewsPrivacyViewController_h
#define Horton_s_Gym_NewsPrivacyViewController_h
#import <UIKit/UIKit.h>

@interface NewsPrivacyViewController : UIViewController <UIWebViewDelegate>

- (void)news;
- (void)privacy;
- (void)installation;
- (void)viewmodel;
- (void)showalternateview;
- (void)setHeartRate:(int)hr;
- (void)setSteps:(int)steps;
- (void)setLocation:(double)latitude longitude:(double)longitude speed:(double)speed;

@end
#endif
//
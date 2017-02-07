//
//  FourthViewController.m
//  Horton's Gym
//
//  Created by Emil on 30/04/15.
//  Copyright (c) 2015 digitalemil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FourthViewController.h"
#import "NewsPrivacyViewController.h"
int button= 0;
extern NewsPrivacyViewController *npc;

@interface FourthViewController ()
@property (weak, nonatomic) IBOutlet UIButton *news;
@property (weak, nonatomic) IBOutlet UIButton *instructions;
@property (weak, nonatomic) IBOutlet UIButton *policy;

@end

@implementation FourthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (IBAction)newsAction:(id)sender {
    button= 1;
}
- (IBAction)privacyAction:(id)sender {
    button= 2;
}

- (IBAction)modelAction:(id)sender {
    button= 4;
}

- (IBAction)viewAction:(id)sender {
    button= 5;
}

- (void)viewDidDisappear:(BOOL)animated {
    if(button==1)
        [npc news];
    if(button==2)
        [npc privacy];
    if(button==3)
        [npc installation];
    if(button==4)
        [npc viewmodel];
    if(button==5)
        [npc showalternateview];
}

- (IBAction)installationAction:(id)sender {
    button= 3;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

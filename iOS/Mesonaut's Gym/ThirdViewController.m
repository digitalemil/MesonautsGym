//
//  ThirdViewController.m
//  Horton's Gym
//
//  Created by Emil on 30/04/15.
//  Copyright (c) 2015 digitalemil. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ThirdViewController.h"
#import "SecondViewController.h"

@import HealthKit;
@import CoreLocation;

extern HKHealthStore *store;
extern int n;
extern NSDateFormatter *formatter;
extern NSString        *dateString, *userstr, *serverstr, *server1,*server2, *servertotry, *servertried, *alternateview;
extern NSMutableURLRequest *request;

extern CLLocationManager *locationManager;
extern SecondViewController *scd;

int alerttype= 0;

@interface ThirdViewController ()
@property (weak, nonatomic) IBOutlet UITextField *server;
@property (weak, nonatomic) IBOutlet UITextField *user;
@property (weak, nonatomic) IBOutlet UIButton *stepsfromhk;
@property (weak, nonatomic) IBOutlet UITextField *av;

@end

@implementation ThirdViewController

- (IBAction)showAlert:(int)n {
    alerttype= n;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uploading data."
                                                    message:@"You're sure you want to upload data (Might take a while)?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Upload",nil];
    [alert show];
}

- (IBAction)deleteAction:(id)sender {
    alerttype= 1;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Deleting all data."
                                                    message:@"You're sure you want to delete all data?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Delete",nil];
    [alert show];
}

- (IBAction)localHRAction:(id)sender {
    [self showAlert:2];
}

- (IBAction)stepsFromHKAction:(id)sender {
    [self showAlert:3];
}

- (IBAction)stepsFromLocalAction:(id)sender {
    [self showAlert:4];
}

- (IBAction)heartratesFromHK:(id)sender {
    [self showAlert:5];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.server.delegate= self;
    self.user.delegate= self;
    self.av.delegate= self;
    
    [self.server setText:serverstr];
    [self.user setText:userstr];
    [self.av setText:alternateview];

    [self saveSettings];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)serverShouldReturn:(id)sender {
    [self.server resignFirstResponder];
    serverstr= [self.server text];
    userstr= [self.user text];
}

- (IBAction)userShouldReturn:(id)sender {
    [self.user resignFirstResponder];
    userstr= [self.user text];
    [self.server resignFirstResponder];
}

- (IBAction)alternateviewShouldReturn:(id)sender {
    [self.av resignFirstResponder];
    alternateview= [self.av text];
    [self.server resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self saveSettings];
    [textField resignFirstResponder];
    return YES;
}

-(void) saveSettings {
    char buf[1024+512];
    
    NSArray *paths= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir= [paths objectAtIndex:0];
    NSString *filePath = [docDir stringByAppendingPathComponent:@"mesonautsgym.settings"];
    
    serverstr= [self.server text];
    
    server1= serverstr;
    server2= nil;
    
    if([serverstr containsString:@","]) {
        server1 = [serverstr componentsSeparatedByString:@","][0];
        server2 = [serverstr componentsSeparatedByString:@","][1];
    }
    else {
        if([serverstr containsString:@" "]) {
            server1 = [serverstr componentsSeparatedByString:@" "][0];
            server2 = [serverstr componentsSeparatedByString:@" "][1];
        }
    }
    servertotry= server1;
    servertried= nil;
    
    userstr= [self.user text];
    alternateview= [self.av text];
    
    const char *s = [serverstr UTF8String];
    const char *u = [userstr UTF8String];
    const char *a = [alternateview UTF8String];
    
    int i =0;
    for(i=0; i< serverstr.length && i< 512; i++) {
        buf[i]= s[i];
    }
    buf[i]= '\0';
    for(i=0; i< userstr.length && i< 512; i++) {
        buf[512+i]= u[i];
    }
    buf[512+i]= '\0';
    for(i=0; i< alternateview.length && i< 512; i++) {
        buf[1024+i]= a[i];
    }
    buf[1024+i]= '\0';
    NSData *myData = [NSData dataWithBytes:buf length:(1024+512)*sizeof(char)];
    [myData writeToFile:filePath atomically:YES];

}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1 && alerttype== 1) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *filePath = [documentsPath stringByAppendingPathComponent:@"mesonautsgym.settings"];
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
        filePath = [documentsPath stringByAppendingPathComponent:@"hrdata.bin"];
        success = [fileManager removeItemAtPath:filePath error:&error];
        filePath = [documentsPath stringByAppendingPathComponent:@"stepdata.bin"];
        success = [fileManager removeItemAtPath:filePath error:&error];

        [self.server setText:@""];
        [self.user setText:@""];

    }
    if (buttonIndex == 1 && alerttype== 2) {
      [scd readHR];
    }
    if (buttonIndex == 1 && alerttype== 3) {
        [scd uploadStepsPressed:nil];
    }
    if (buttonIndex == 1 && alerttype== 4) {
        [scd readSteps];
    }
    if (buttonIndex == 1 && alerttype== 5) {
        [scd uploadHRsPressed:nil];
    }
    alerttype= 0;
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [self saveSettings];
}


@end

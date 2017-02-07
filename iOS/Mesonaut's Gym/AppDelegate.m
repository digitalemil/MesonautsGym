//
//  AppDelegate.m
//  Horton's Gym
//
//  Created by Emil on 29/04/15.
//  Copyright (c) 2015 digitalemil. All rights reserved.
//

#import "AppDelegate.h"
#import "SecondViewController.h"

@import HealthKit;
HKHealthStore *store;
extern SecondViewController *scd;


@interface AppDelegate ()

@end

@implementation AppDelegate
/*
- (NSSet *)readTypes {
    NSSet *set= [NSSet setWithObject:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate]];
    
    return set;
}

- (NSSet *)readStepTypes {
    NSSet *set= [NSSet setWithObject:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];
    
    return set;
}

- (NSSet *)shareTypes {
    return [NSSet set];
}

- (void) tryHR:(int)nt {
    [store requestAuthorizationToShareTypes:[self shareTypes]
                                  readTypes:[self readTypes] completion:^(BOOL success, NSError *error) {
                                  }];
    
    HKSampleType *sampleType =
    [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    [store enableBackgroundDeliveryForType:sampleType frequency:1 withCompletion:^(BOOL success, NSError *error) {}];
    HKObserverQuery *query =
    [[HKObserverQuery alloc]
     initWithSampleType:sampleType
     predicate:nil
     updateHandler:^(HKObserverQuery *query,
                     HKObserverQueryCompletionHandler completionHandler,
                     NSError *error) {
         
         if (error && nt> 0) {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error occured"
                                                             message:@"Unable to connect to HealthKit."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [scd signal:0];
             [alert show];
             NSLog(@"*** An error occured while setting up the observer. %@ ***",
                   error.localizedDescription);
         }
         if(error) {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please allow access to HealthKit"
                                                             message:@"In order to read your heart rate you must allow this Horton's Gym in HealthKit under Sources / Apps."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [scd signal:0];
             [alert show];
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [self tryHR:1];
             });
         }
         
         HKQuantityType *hrType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
         NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
         HKSampleQuery *hrquery = [[HKSampleQuery alloc] initWithSampleType:hrType predicate:nil limit:1 sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
             if (error) {
                [scd signal:0];
                 return;
             }
             [scd processHRResults:results];
         }];
         [store executeQuery:hrquery];
         completionHandler();
         
     }];
    [store executeQuery:query];
}

*/
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UIBackgroundTaskIdentifier __block taskID = [application beginBackgroundTaskWithExpirationHandler:^{
        if (taskID != UIBackgroundTaskInvalid) {
            [application endBackgroundTask:taskID];
            taskID = UIBackgroundTaskInvalid;
        }
    }];
    /*
    if(NSClassFromString(@"HKHealthStore") && [HKHealthStore isHealthDataAvailable]) {
        if(!store) {
            store = [HKHealthStore new];
        }
        [self tryHR:0];
    }*/
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end

//
//  InterfaceController.m
//  Horton's Watch Extension
//
//  Created by Emil on 16/02/16.
//  Copyright © 2016 digitalemil. All rights reserved.
//

#import "InterfaceController.h"

@import HealthKit;
HKHealthStore *store;
HKObserverQuery *query;

@interface InterfaceController() <WCSessionDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *button;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *bpm;
@end


@implementation InterfaceController
- (IBAction)buttonPressed {
        
    if(running) {
        running= false;
        [store stopQuery:query];
        [store endWorkoutSession:workoutSession];
        [self.button setTitle:@"Start"];
        [self.bpm setText:@"---"];
        return;
    }
    
    //   workoutSession.delegate = self;
    
    
    running= true;
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    [store startWorkoutSession:workoutSession];
    
    HKSampleType *sampleType =
    [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    query =
    [[HKObserverQuery alloc]
     initWithSampleType:sampleType
     predicate:nil
     updateHandler:^(HKObserverQuery *query,
                     HKObserverQueryCompletionHandler completionHandler,
                     NSError *error) {
         
         if (error) {
             NSLog(@"*** An error occured while setting up the observer. %@ ***",
                   error.localizedDescription);
         }
         
         HKQuantityType *hrType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
         NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
         HKSampleQuery *hrquery = [[HKSampleQuery alloc] initWithSampleType:hrType predicate:nil limit:1 sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
             if (error) {
                 return;
             }
             [self processHRResults:results];
         }];
         [store executeQuery:hrquery];
         completionHandler();
         
     }];
    [self.button setTitle:@"Stop"];
    [store executeQuery:query];
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    store= [[HKHealthStore alloc] init];
    
    [store requestAuthorizationToShareTypes:[self shareTypes]
                                  readTypes:[self readTypes] completion:^(BOOL success, NSError *error) {
                                  }];
    workoutSession = [[HKWorkoutSession alloc] initWithActivityType:HKWorkoutActivityTypeOther locationType:HKWorkoutSessionLocationTypeUnknown];

    // Configure interface objects here.
}

- (NSSet *)shareTypes {
    return [NSSet set];
}
- (NSSet *)readTypes {
    NSSet *set= [NSSet setWithObject:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate]];
    
    return set;
}

- (void) processHRResults:(NSArray *)results {
    // if there is a data point, dispatch to the main queue
    if (results) {
        dispatch_async(dispatch_get_main_queue(), ^{
            HKQuantitySample *quantitySample = results.lastObject;
            
            HKQuantity *quantity = quantitySample.quantity;
            
            HKUnit *hrunit= [[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]];
            int userHR= (int)[quantity doubleValueForUnit:hrunit];
            NSString *text= [NSString stringWithFormat:@"%i", userHR];
            [self.bpm setText:text];
            NSString *string = [NSString stringWithFormat:@"%d", userHR];
            NSDictionary *applicationData = [[NSDictionary alloc] initWithObjects:@[string] forKeys:@[@"bpm"]];
            
            [[WCSession defaultSession] sendMessage:applicationData
                                       replyHandler:^(NSDictionary *reply) {
                                           //handle reply from iPhone app here
                                       }
                                       errorHandler:^(NSError *error) {
                                           //catch any errors here
                                       }
             ];
        });
    }
}

- (void)workoutSession:(HKWorkoutSession *)workoutSession
      didChangeToState:(HKWorkoutSessionState)toState
             fromState:(HKWorkoutSessionState)fromState
                  date:(NSDate *)date {
    
}

- (void)workoutSession:(HKWorkoutSession *)workoutSession didFailWithError:(NSError *)error {
    
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
    running= false;
   }

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    running= false;
}

@end




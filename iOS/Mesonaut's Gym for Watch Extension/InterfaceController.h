//
//  InterfaceController.h
//  Horton's Watch Extension
//
//  Created by Emil on 16/02/16.
//  Copyright © 2016 digitalemil. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@import HealthKit;
@import WatchConnectivity;

@interface InterfaceController : WKInterfaceController {
    dispatch_queue_t queue;
    bool running;
    HKWorkoutSession *workoutSession;

}
@end

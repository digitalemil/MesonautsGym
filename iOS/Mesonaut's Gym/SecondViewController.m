//
//  SecondViewController.m
//  Horton's Gym
//
//  Created by Emil on 29/04/15.
//  Copyright (c) 2015 digitalemil. All rights reserved.
//

#import "SecondViewController.h"
#import "NewsPrivacyViewController.h"
#include <sys/time.h>

@import HealthKit;
@import CoreLocation;

extern HKHealthStore *store;
int n=0;
NSDateFormatter *formatter;
NSString        *dateString, *userstr, *serverstr, *server1, *server2, *servertried, *servertotry, *hrString, *stepsString, *uploadhrstr, *uploadsuccess, *alternateview;
extern NewsPrivacyViewController *npc;

int hrs= 0;
NSMutableURLRequest *request;
int elefant= 0;
bool years200= false;
NSFileHandle *hrFileHandle= nil, *stepFileHandle= nil;
double longitude, latitude,speed;
bool trackloc= false;

SecondViewController *scd;
long locationManagerStartTimestamp;

CLLocationManager *locationManager;

@interface SecondViewController () <WCSessionDelegate>

@property (weak, nonatomic) IBOutlet UILabel *bpm;
@property (weak, nonatomic) IBOutlet UILabel *stepcount;
@property (weak, nonatomic) IBOutlet UIImageView *elefimg;
@property (weak, nonatomic) IBOutlet UISwitch *locswitch;
@end

int nbpms= 0;
@implementation SecondViewController
- (IBAction)locswitchAction:(id)sender {
    if(trackloc) {
        [locationManager stopUpdatingLocation];
        trackloc= false;
    }
    else {
        [locationManager startUpdatingLocation];
        locationManagerStartTimestamp = [[NSDate date] timeIntervalSince1970];
        trackloc= true;
    }
}


/*- (void)tryRestartLocationManager
 {
 NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
 
 int seconds = round(floor(now - locationManagerStartTimestamp));
 
 if ( seconds > (60 * 2) ) {
 [locationManager stopUpdatingLocation];
 [locationManager startUpdatingLocation];
 locationManagerStartTimestamp = now;
 }
 }
 */

-(void)writeHR:(NSString*)json {
    if(hrFileHandle== nil) {
        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* hrdatafile = [documentsPath stringByAppendingPathComponent:@"hrdata.bin"];
        
        hrFileHandle = [NSFileHandle fileHandleForWritingAtPath:hrdatafile];
        [hrFileHandle seekToEndOfFile];
    }
    if(hrFileHandle== nil)
        [self signal:5];
    
    @try {
        NSData* data = [json dataUsingEncoding:NSUTF8StringEncoding];
        [hrFileHandle writeData:data];
        [hrFileHandle closeFile];
        hrFileHandle= nil;
    }
    @catch (NSException *exception) {
        [self signal:5];
    }
}

-(void)writeStep:(NSString*)json {
    if(stepFileHandle== nil) {
        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* stepdatafile = [documentsPath stringByAppendingPathComponent:@"stepdata.bin"];
        
        stepFileHandle = [NSFileHandle fileHandleForWritingAtPath:stepdatafile];
        [stepFileHandle seekToEndOfFile];
    }
    if(stepFileHandle== nil)
        [self signal:5];
    
    @try {
        NSData* data = [json dataUsingEncoding:NSUTF8StringEncoding];
        [stepFileHandle writeData:data];
        [stepFileHandle closeFile];
        stepFileHandle= nil;
    }
    @catch (NSException *exception) {
        [self signal:5];
    }
}


-(void)readHR {
    NSFileHandle *fh= nil;
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* hrdatafile = [documentsPath stringByAppendingPathComponent:@"hrdata.bin"];
    NSMutableString *ret= [[NSMutableString alloc] init];
    
    if(fh== nil) {
        fh = [NSFileHandle fileHandleForReadingAtPath:hrdatafile];
    }
    if(fh== nil)
        return;
    
    int chunkSize= 2048;
    
    char buf[4096];
    buf[0]= '\0';
    int line =0;
    [ret appendString:@"{\"hrs\":["];
    @try {
        
        bool stopit= false;
        while (!stopit)  {
            NSData *data = [fh readDataOfLength:chunkSize];
            if([data length]< chunkSize)
                stopit= true;
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            const char *d= [dataString UTF8String];
            int len=  [dataString length];
            int s= 0;
            int i =0;
            for(; i< len; i++) {
                if(d[i]== '}') {
                    NSString *str = [[NSString alloc] initWithBytes:&d[s] length:(i-s+1) encoding:NSASCIIStringEncoding];
                    if(strlen(buf)!= 0) {
                        str= [NSString stringWithFormat:@"%s%@", buf, str];
                    }
                    s= i+1;
                    buf[0]= '\0';
                    if(![str hasPrefix:@"{"] || ![str hasSuffix:@"}"]) {
                        NSLog(@"JSON Error: %i %@. Buffer: %s", line, str, buf);
                    }
                    line++;
                    [ret appendString:str];
                    [ret appendString:@",\n"];
                }
            }
            if(i== len && d[i-1]!='}') {
                strncpy(&buf[strlen(buf)], &d[s], len-s+1);
                buf[len-s+1]='\0';
                //       NSLog(@"Buffer: %s", buf);
            }
        }
        
        servertried= nil;
        [ret appendString:@"]}\n"];
        uploadsuccess= [NSString stringWithFormat:@"Successfully uploaded %i events.", line];
        
        uploadhrstr= ret;
        
        if(servertotry!= nil)
            [self sendToServer:servertotry uri:@"/data/upload" json:ret];
        
    }
    @catch (NSException *exception) {
        [self signal:5];
    }
}

-(void)readSteps {
    NSFileHandle *fh= nil;
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* stepdatafile = [documentsPath stringByAppendingPathComponent:@"stepdata.bin"];
    NSMutableString *steps= [[NSMutableString alloc] init];
    [steps appendString:@"{\"steps\":["];
    
    if(fh== nil) {
        fh = [NSFileHandle fileHandleForReadingAtPath:stepdatafile];
    }
    if(fh== nil)
        return;
    
    int chunkSize= 4096;
    
    char buf[4096];
    buf[0]= '\0';
    int line =0;
    @try {
        
        bool stopit= false;
        while (!stopit)  {
            NSData *data = [fh readDataOfLength:chunkSize];
            
            if([data length]< chunkSize)
                stopit= true;
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            const char *d= [dataString UTF8String];
            int len=  [dataString length];
            int s= 0;
            int i =0;
            for(; i< len; i++) {
                if(d[i]== '}') {
                    if(i>0 && d[i-1]== ']')
                        continue;
                    NSString *str = [[NSString alloc] initWithBytes:&d[s] length:(i-s+1) encoding:NSASCIIStringEncoding];
                    
                    if(strlen(buf)!= 0) {
                        str= [NSString stringWithFormat:@"%s%@", buf, str];
                    }
                    str= [str stringByReplacingOccurrencesOfString:@"{\"steps\":[" withString:@""];
                    str= [str stringByReplacingOccurrencesOfString:@"]}" withString:@""];
                    
                    s= i+1;
                    buf[0]= '\0';
                    if(![str hasPrefix:@"{"] || ![str hasSuffix:@"}"]) {
                        NSLog(@"JSON Error: %i %@. Buffer: %s", line, str, buf);
                    }
                    [steps appendString:str];
                    [steps appendString:@",\n"];
                    line++;
                    
                }
            }
            if(i== len && d[i-1]!='}') {
                strncpy(&buf[strlen(buf)], &d[s], len-s+1);
                buf[len-s+1]='\0';
                //       NSLog(@"Buffer: %s", buf);
            }
        }
        servertried= nil;
        stepsString= steps;
        [steps appendString:@"]}"];
        uploadsuccess= [NSString stringWithFormat:@"Successfully uploaded %i events.", line];
        
        if(servertotry!= nil)
            [self sendToServer:servertotry uri:@"/data/steps" json:steps];
        NSLog(@"JSON: %i %@.", line, steps);
    }
    @catch (NSException *exception) {
        [self signal:5];
    }
}



- (void)loadSettings {
    userstr= [[NSProcessInfo processInfo] globallyUniqueString];
    serverstr= @"";
    char buf[1024+512];
    NSArray *paths= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir= [paths objectAtIndex:0];
    NSString *filePath = [docDir stringByAppendingPathComponent:@"hortonsgym.settings"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath])
        return;
    
    NSData *myData = [NSData dataWithContentsOfFile:filePath];
    
    [myData getBytes:buf length:(1024+512)*sizeof(char)];
    serverstr = [NSString stringWithUTF8String:[myData bytes]];
    userstr = [NSString stringWithUTF8String:&([myData bytes][512])];
    alternateview=[NSString stringWithUTF8String:&([myData bytes][1024])];
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
}


- (void)signal:(int)c {
  // [self.bpm setText:@"120"];
  // [self.stepcount setText:@"90"];
    
    if(c== elefant)
        return;
    switch(c) {
        case 0:
            if(!years200) {
                [self.elefimg setImage:[UIImage imageNamed:@"mesonautred@2x.png"]];
            }
                       break;
        case 1:
            if(!years200) {
                self.elefimg.animationImages= nil;
                
                [self.elefimg setImage:[UIImage imageNamed:@"mesonaut@2x.png"]];
            }
            
            break;
        case 2:
            if(!years200) {
                [self.elefimg setImage:[UIImage imageNamed:@"mesonaut@2x.png"]];
            }
           
            
            break;
        case 3:
            if(!years200) {
                [self.elefimg setImage:[UIImage imageNamed:@"mesonaut@2x.png"]];
            }
                       break;
            
        case 4:
            if(!years200) {
                [self.elefimg setImage:[UIImage imageNamed:@"mesonaut@2x.png"]];
            }
            
            break;
        case 5:
            if(!years200) {
                [self.elefimg setImage:[UIImage imageNamed:@"mesonaut@2x.png"]];
            }
            
            break;
            
    }
    elefant= c;
}
- (IBAction)twohundredAction:(id)sender {
    years200= false;
    int d= elefant;
    elefant= -1;
    [self signal:d];
}

- (void) sendToServer:(NSString *)server uri:(NSString *)uri json:(NSString *)json {
    NSString *url = [NSString stringWithFormat:@"%@%@", server, uri];
    request = [[NSMutableURLRequest alloc]
               initWithURL:[NSURL
                            URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    
    
    [request setValue:[NSString stringWithFormat:@"%lu",
                       (unsigned long)[json length]] forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:[json
                          dataUsingEncoding:NSUTF8StringEncoding]];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}


- (void) processHRResults:(NSArray *)results {
    // if there is a data point, dispatch to the main queue
    if (results) {
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            HKQuantitySample *quantitySample = results.firstObject;
            
            HKQuantity *quantity = quantitySample.quantity;
            
            HKUnit *hrunit= [[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]];
            int userHR= (int)[quantity doubleValueForUnit:hrunit];
            [self.bpm setText:[NSString stringWithFormat:@"%i bpm", userHR]];
            
            dateString = [formatter stringFromDate:quantitySample.startDate];
            
            struct timeval time;
            gettimeofday(&time, NULL);
            long millis = (time.tv_sec * 1000) + (time.tv_usec / 1000);
            
            hrString = [NSString stringWithFormat:@"{\"id\":\"%li\", \"location\":\"%lf,%lf\", \"event_timestamp\":\"%@\", \"deviceid\":\"%@\", \"user\":\"%@\", \"heartrate\":\"%u\"}", millis, latitude, longitude, dateString, @"2207", userstr, userHR];
            [self writeHR:hrString];
            if(npc!= nil) {
                [npc setHeartRate:userHR];
                           }
            servertried= nil;
            if(servertotry!= nil)
                [self sendToServer:servertotry uri:@"/data" json:hrString];
            
        });
    }
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
             [self signal:0];
             [alert show];
             NSLog(@"*** An error occured while setting up the observer. %@ ***",
                   error.localizedDescription);
         }
         if(error) {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please allow access to HealthKit"
                                                             message:@"In order to read your heart rate you must allow this Horton\"s Gym in HealthKit under Sources / Apps."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [self signal:0];
             //[alert show];
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [self tryHR:1];
               });
         }
         
         HKQuantityType *hrType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
         NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
         HKSampleQuery *hrquery = [[HKSampleQuery alloc] initWithSampleType:hrType predicate:nil limit:1 sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
             if (error) {
                 [self signal:0];
                 return;
             }
             [self processHRResults:results];
         }];
         [store executeQuery:hrquery];
         completionHandler();
         
     }];
    [store executeQuery:query];
}


- (void) trySteps:(int)nt {
    /*
    [store requestAuthorizationToShareTypes:[self shareTypes]
                                  readTypes:[self readStepTypes] completion:^(BOOL success, NSError *error) {
                                  }];
    
    HKSampleType *stepsType =
    [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    
    
    [store enableBackgroundDeliveryForType:stepsType frequency:1 withCompletion:^(BOOL success, NSError *error) {}];
    HKObserverQuery *query =
    [[HKObserverQuery alloc]
     initWithSampleType:stepsType
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
             [self signal:0];
             //[alert show];
             NSLog(@"*** An error occured while setting up the observer. %@ ***",
                   error.localizedDescription);
         }
         if(error) {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please allow access to HealthKit"
                                                             message:@"In order to read your heart rate and steps you must allow this Horton\"s Gym in HealthKit under Sources / Apps."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [self signal:0];
             // [alert show];
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self trySteps:1];
               });
         }
         
         HKSampleType *stepsType =
         [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
         NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
         
         HKSampleQuery *stepsquery = [[HKSampleQuery alloc] initWithSampleType:stepsType predicate:nil limit:1 sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
             if (error) {
                 [self signal:0];
                 return;
             }
             [self processStepResults:results];
         }];
         [store executeQuery:stepsquery];
         completionHandler();
     }];
    [store executeQuery:query];
     */
}

/*
 - (void) myTimer:(NSTimer *)timer {
 dateString = [formatter stringFromDate:[NSDate date]];
 
 double CurrentTime = CACurrentMediaTime();
 long id= (long)CurrentTime;
 
 long lat=locationManager.location.coordinate.latitude;
 long lon= locationManager.location.coordinate.longitude;
 
 hrString = [NSString stringWithFormat:@"{\"id\":\"%@-%ld\", \"location\":\"%@\", \"event_timestamp\":\"%@\", \"deviceid\":\"%@\", \"user\":\"%@\", \"heartrate\":\"%u\"}", userstr, id, [self deviceLocation], dateString, userstr, userstr, 0];
 
 servertried= nil;
 if(servertotry!= nil)
 [self sendToServer:servertotry uri:@"/data/publish" json:hrString];
 
 }
 */

- (void)session:(nonnull WCSession *)session didReceiveMessage:(nonnull NSDictionary *)message replyHandler:(nonnull void (^)(NSDictionary * __nonnull))replyHandler {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *value = [message objectForKey:@"bpm"];
        
        int userHR= [value intValue];
   //     userHR= nbpms;
        nbpms++;
        [self.bpm setText:[NSString stringWithFormat:@"%i bpm", userHR]];
        
        dateString = [formatter stringFromDate:[NSDate date]];
        
        struct timeval time;
        gettimeofday(&time, NULL);
        long millis = (time.tv_sec * 1000) + (time.tv_usec / 1000);
        
        hrString = [NSString stringWithFormat:@"{\"id\":\"%li\", \"location\":\"%lf,%lf\", \"event_timestamp\":\"%@\", \"deviceid\":\"%@\", \"user\":\"%@\", \"heartrate\":\"%u\"}", millis, latitude, longitude, dateString, @"2207", userstr, userHR];
        [self writeHR:hrString];
        if(npc!= nil) {
            [npc setHeartRate:userHR];
        }
        servertried= nil;
        if(servertotry!= nil)
            [self sendToServer:servertotry uri:@"/data" json:hrString];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
    
    
    scd= self;
    
    elefant= -1;
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* hrdatafile = [documentsPath stringByAppendingPathComponent:@"hrdata.bin"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:hrdatafile];
    if(!fileExists) {
        [[NSFileManager defaultManager] createFileAtPath:hrdatafile contents:nil attributes:nil];
    }
    
    NSString* stepdatafile = [documentsPath stringByAppendingPathComponent:@"stepdata.bin"];
    fileExists = [[NSFileManager defaultManager] fileExistsAtPath:stepdatafile];
    if(!fileExists) {
        [[NSFileManager defaultManager] createFileAtPath:stepdatafile contents:nil attributes:nil];
    }
    
    [self signal:2];
    [self loadSettings];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    [locationManager startMonitoringSignificantLocationChanges];
    
    locationManager.delegate = self;
    [locationManager requestAlwaysAuthorization];
    [locationManager requestWhenInUseAuthorization];
    [locationManager stopUpdatingLocation];
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    
    
    if(NSClassFromString(@"HKHealthStore") && [HKHealthStore isHealthDataAvailable]) {
        if(!store) {
            store = [HKHealthStore new];
        }
        [self tryHR:0];
        [self trySteps:0];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 - (NSString *)deviceLocation {
 [self tryRestartLocationManager];
 //    [self tryHR:0];
 
 return [NSString stringWithFormat:@"%f,%f", locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude];
 }
 */

- (NSPredicate *)predicateForStepsAndHRs {
    NSDate *now = [NSDate date];
    NSDate *tomorrow = [NSDate dateWithTimeInterval:(24*60*60) sinceDate:[NSDate date]];
    NSDate *startDate = [now dateByAddingTimeInterval:-7*24*60*60];
    
    return [HKQuery predicateForSamplesWithStartDate:startDate endDate:tomorrow options:HKQueryOptionStrictStartDate];
}

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

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([response respondsToSelector:@selector(statusCode)]) {
        int statusCode = [((NSHTTPURLResponse *)response) statusCode];
        if (statusCode == 200) {
            servertried= nil;
            [self signal:1];
            if(uploadsuccess!= nil && [uploadsuccess length]>0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Successfull upload"
                                                                message:uploadsuccess
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [self signal:0];
                
                [alert show];
                uploadsuccess= @"";
            }
            
        }
        else {
            [self signal:4];
            NSURL *myURL = [[connection currentRequest] URL];
            if(uploadsuccess!= nil && [uploadsuccess length]>0) {
                NSString *str= [NSString stringWithFormat:@"Couldn't upload data. Reason: %i", statusCode];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                message:str
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                
                uploadsuccess= @"";
                
                
            }
            
            NSLog(@"HTTP Status: %i %@" , statusCode, myURL.relativePath);
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSURL *myURL = [[connection currentRequest] URL];
    
    NSString *uri= @"/data", *data= hrString;
    
    if([myURL.relativePath containsString:@"steps"]) {
        uri= @"/data/steps";
        data= stepsString;
    }
    
    if([myURL.relativePath containsString:@"upload"]) {
        uri= @"/data/upload";
        data= uploadhrstr;
    }
    
    if(servertotry== server1 && servertried== nil) {
        servertried= server1;
        if(server2!= nil)
            servertotry= server2;
        [self sendToServer:servertotry uri:uri json:data];
        return;
    }
    if(servertotry== server2 && servertried== nil) {
        servertried= server2;
        if(server1!= nil)
            servertotry= server1;
        [self sendToServer:servertotry uri:uri json:data];
        return;
    }
    [self signal:3];
}

- (IBAction)uploadStepsPressed:(id)sender {
    /*
    if(NSClassFromString(@"HKHealthStore") && [HKHealthStore isHealthDataAvailable]) {
        if(!store) {
            return;
        }
        
        // Query Steps
        [store requestAuthorizationToShareTypes:[self shareTypes]
                                      readTypes:[self readStepTypes] completion:^(BOOL success, NSError *error) {
                                      }];
        
        HKSampleType *stepsType =
        [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
        
        NSPredicate *predicate = [self predicateForStepsAndHRs];
        
        HKSampleQuery *stepsquery = [[HKSampleQuery alloc] initWithSampleType:stepsType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
            if (!results) {
                NSLog(@"An error occured fetching the user  s steps: %@.", error);
                abort();
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                int i= 0;
                NSMutableString *ret= [[NSMutableString alloc] init];
                [ret appendString:@"{'steps':["];
                for (id object in results) {
                    i++;
                    HKQuantitySample *quantitySample = object;
                    
                    HKQuantity *quantity = quantitySample.quantity;
                    HKUnit *unit = [HKUnit countUnit];
                    double steps = [quantity doubleValueForUnit:unit];
                    NSString *js= [NSString stringWithFormat:@"{\"id\":\"%@-%@\", \"location\":\"0,0\", \"event_timestamp\":\"%@\", \"user\":\"%@\", \"steps\":\"%i\"},\n", userstr, [formatter stringFromDate:quantitySample.startDate], [formatter stringFromDate:quantitySample.startDate], userstr, (int)steps];
                    [ret appendString:js];
                }
                [ret appendString:@"]}"];
                //     NSLog(@"Steps: %@" , ret);
                uploadsuccess= [NSString stringWithFormat:@"Successfully uploaded %i events.", i];
                
                servertried= nil;
                if(servertotry!= nil)
                    [self sendToServer:servertotry uri:@"/data/steps" json:ret];
                
            });
        }];
        
        [store executeQuery:stepsquery];
        
    }
     */
}

- (IBAction)uploadHRsPressed:(id)sender {
    if(NSClassFromString(@"HKHealthStore") && [HKHealthStore isHealthDataAvailable]) {
        if(!store) {
            return;
        }
        
        // Query Steps
        [store requestAuthorizationToShareTypes:[self shareTypes]
                                      readTypes:[self readStepTypes] completion:^(BOOL success, NSError *error) {
                                      }];
        
        HKQuantityType *hrType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
        NSPredicate *predicate = [self predicateForStepsAndHRs];
        
        HKSampleQuery *hrquery =[[HKSampleQuery alloc] initWithSampleType:hrType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
            
            if (!results) {
                NSLog(@"An error occured fetching the user's steps: %@.", error);
                abort();
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                int i= 0;
                NSMutableString *ret= [[NSMutableString alloc] init];
                
                [ret appendString:@"{\"hrs\":["];
                for (id object in results) {
                    i++;
                    HKQuantitySample *quantitySample = object;
                    
                    HKQuantity *quantity = quantitySample.quantity;
                    
                    HKUnit *hrunit= [[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]];
                    int userHR= (int)[quantity doubleValueForUnit:hrunit];
                    struct timeval time;
                    gettimeofday(&time, NULL);
                    long millis = (time.tv_sec * 1000) + (time.tv_usec / 1000);
                    
                    NSString *js= [NSString stringWithFormat:@"{\"id\":\"%li\", \"location\":\"%lf,%lf\", \"event_timestamp\":\"%@\", \"deviceid\":\"%@\", \"user\":\"%@\", \"heartrate\":\"%u\"},\n", millis, 0.0, 0.0, [formatter stringFromDate:quantitySample.startDate], @"2207", userstr, userHR];
                    [ret appendString:js];
                }
                [ret appendString:@"]}"];
                //   NSLog(@"Steps: %@" , ret);
                uploadsuccess= [NSString stringWithFormat:@"Successfully uploaded %i events.", i];
                
                servertried= nil;
                if(servertotry!= nil)
                    [self sendToServer:servertotry uri:@"/data/upload" json:ret];
                
            });
        }];
        
        [store executeQuery:hrquery];
        
    }
}


- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
  //  if (abs(howRecent) < 15.0) {
        longitude= location.coordinate.longitude;
        latitude=location.coordinate.latitude;
        speed= location.speed;
        if(npc!= nil)
            [npc setLocation:latitude longitude:longitude speed:speed];
        // If the event is recent, do something with it.
        /*
         NSLog(@"latitude %+.6f, longitude %+.6f\n",
         location.coordinate.latitude,
         location.coordinate.longitude);
         */
  //  }
}


@end

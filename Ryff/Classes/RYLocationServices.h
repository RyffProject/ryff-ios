//
//  RYLocationServices.h
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import <Foundation/Foundation.h>
// Location API
#import <CoreLocation/CoreLocation.h>

@protocol LocationDelegate <NSObject>

- (void) locationSuceededWithLat:(NSNumber*)latitude Long:(NSNumber*)longitude;
- (void) locationFailedWithError:(NSError*)error;

@end

@interface RYLocationServices : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, weak) id<LocationDelegate> locationDelegate;

+ (RYLocationServices*)sharedInstance;

- (void) requestLocationCoordinatesForDelegate:(id<LocationDelegate>)delegate;

@end

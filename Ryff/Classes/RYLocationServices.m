//
//  RYLocationServices.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYLocationServices.h"

// Data Managers
#import "RYServices.h"
#import "RYRegistrationServices.h"


@implementation RYLocationServices

static RYLocationServices* _sharedInstance;

+ (RYLocationServices *)sharedInstance
{
    if (_sharedInstance == NULL)
    {
        _sharedInstance = [RYLocationServices allocWithZone:NULL];
        _sharedInstance.locationManager = [[CLLocationManager alloc] init];
        [_sharedInstance.locationManager setDelegate:_sharedInstance];
    }
    return _sharedInstance;
}

- (void) requestLocationUpdate
{
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager startUpdatingLocation];
}

- (void) requestLocationCoordinatesForDelegate:(id<LocationDelegate>)delegate
{
    _locationDelegate = delegate;
    [self requestLocationUpdate];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (_locationDelegate)
    {
        [_locationDelegate locationFailedWithError:error];
        _locationDelegate = nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        NSNumber *longitude = [NSNumber numberWithFloat:currentLocation.coordinate.longitude];
        NSNumber *latitude = [NSNumber numberWithFloat:currentLocation.coordinate.latitude];
        
        [[NSUserDefaults standardUserDefaults] setObject:longitude forKey:kCoordLongitude];
        [[NSUserDefaults standardUserDefaults] setObject:latitude forKey:kCoordLongitude];
        [[NSUserDefaults standardUserDefaults] synchronize];
    
        if (_locationDelegate)
        {
            [_locationDelegate locationSuceededWithLat:latitude Long:longitude];
            _locationDelegate = nil;
        }
    }
}

@end

//
//  LocationDelegate.h
//  locationcli
//
//  Created by João Paulo Barraca <jpbarraca@gmail.com>
//


#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ILGeoNamesLookup.h"

@protocol CLLocationManager;
@protocol ILGeoNamesLookup;
@protocol NSDictionary;
@protocol CLLocation;

@interface LocationDelegate : NSObject <NSApplicationDelegate, CLLocationManagerDelegate, ILGeoNamesLookupDelegate> {

    @private
	CLLocationManager *locationManager;
    ILGeoNamesLookup *geocoder;
    NSTimer *timer;
    CLLocation *location;
    BOOL gotLocation;
    NSDictionary *place;
    BOOL gotPlace;
    int retries;
}

- (void) printResult;

@end

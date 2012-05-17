//
//  LocationDelegate.m
//  locationcli
//
//  Created by João Paulo Barraca <jpbarraca@gmail.com>
//

#import "LocationDelegate.h"
#import <Foundation/Foundation.h>


@implementation LocationDelegate
#pragma mark -
#pragma mark CLLocationManagerDelegate

//GeoNames Account Name. REQUIRED
static NSString *kGeoNamesAccountName = @"geonamesaccountname";

- (id)init
{
	self = [super init];

	if (self != nil) {

		if( [CLLocationManager locationServicesEnabled] == 0)
		{
			fprintf(stderr,"ERROR: Location Service Disabled\n");
			exit(-1);
		}
        gotLocation = false;
        gotPlace = false;

        locationManager = [[CLLocationManager alloc] init];
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.delegate = self; // send loc updates to myself
		retries = 0;

        timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(timeout) userInfo:nil repeats:NO];

        [locationManager startUpdatingLocation];

        geocoder = [[[ILGeoNamesLookup alloc] initWithUserID:kGeoNamesAccountName] autorelease];
        geocoder.delegate = self;
	}

    return self;
}

- (void) timeout{
    fprintf(stderr,"ERROR: Timeout after 30s\n");
    exit(-3);
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];

	if(locationAge > 5 && retries < 5)
	{
		retries++;
		return;
	}

    location = [newLocation copy];

    gotLocation = true;

    [locationManager stopUpdatingLocation];

	[geocoder findNearbyPlaceNameForLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];

}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSString *strError = [[[NSString alloc] init] autorelease];
    switch([error code])
    {
        case kCLErrorDenied:
            strError=@"Location denied error";
            break;
        case kCLErrorLocationUnknown:
            strError=@"Unknown location error";
            break;
        default:
            strError=@"Generic Location Error";
            break;
    }
    fprintf(stderr,"ERROR: %s: %s\n", [[error localizedDescription] UTF8String], [strError UTF8String]);
	exit(-2);
}


- (void)locationManager:(CLLocationManager *)manager
    didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if(status != kCLAuthorizationStatusAuthorized)
    {
        fprintf(stderr,"ERROR: Authorization status %d\n", status);
        [locationManager stopUpdatingLocation];
        [locationManager release];
        exit(-2);
    }
}


- (void)destroy
{
    [timer release];
    [timer invalidate];

	[locationManager stopUpdatingLocation];
	[locationManager release];

    [geocoder release];
}

#pragma mark -
#pragma mark ILGeoNamesLookupDelegate

- (void)geoNamesLookup:(ILGeoNamesLookup *)handler networkIsActive:(BOOL)isActive
{
}



- (void)geoNamesLookup:(ILGeoNamesLookup *)handler didFindGeoNames:(NSArray *)geoNames totalFound:(NSUInteger)total
{
	if (geoNames && [geoNames count] >= 1) {
		place = [[geoNames objectAtIndex:0] copy];
        gotPlace = true;
	}

    [self printResult];
    exit(0);

}

- (void)geoNamesLookup:(ILGeoNamesLookup *)handler didFailWithError:(NSError *)error
{
    fprintf(stderr,"ERROR: %s\n", [[error localizedDescription] UTF8String]);

    [self printResult];
    exit(0);
}

- (void)printResult{
    double latitude= 0;
    double longitude = 0;
    double accuracy = 0;
    double age = 0;

    NSString *placeName = @"unknown";
    NSString *city = @"unknown";
    NSString *country = @"unknown";

    if(gotLocation){
        latitude = location.coordinate.latitude;
        longitude = location.coordinate.longitude;
        age = -[location.timestamp timeIntervalSinceNow];
        accuracy = location.horizontalAccuracy;
    }

    if(gotPlace){
        placeName = [place objectForKey:kILGeoNamesNameKey];
        city =  [place objectForKey:kILGeoNamesAdminName1Key];
        country = [place objectForKey:kILGeoNamesCountryNameKey];
    }

    printf("latitude=%f longitude=%f accuracy=%f age=%f place=\"%s\" city=\"%s\" country=\"%s\"\n", latitude, longitude,accuracy, age, [placeName UTF8String], [city UTF8String], [country UTF8String]);

   }

@end

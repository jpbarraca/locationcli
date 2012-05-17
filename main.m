//
//  main.m
//  locationcli
//
//  Created by João Paulo Barraca <jpbarraca@gmail.com>
//

#import <Cocoa/Cocoa.h>
#import "LocationDelegate.h"
#import <CoreData/CoreData.h>
#include "main.h"

@implementation Main

int main(int argc, char *argv[])
{
	NSAutoreleasePool *rp = [[NSAutoreleasePool alloc] init];

    LocationDelegate *ld= [[LocationDelegate alloc] init];

    NSRunLoop *loop = [NSRunLoop currentRunLoop];
 	[loop run];

	[rp release];

	return 0;
}



@end

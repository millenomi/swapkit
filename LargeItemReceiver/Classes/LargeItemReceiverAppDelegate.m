//
//  LargeItemReceiverAppDelegate.m
//  LargeItemReceiver
//
//  Created by ∞ on 01/03/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "LargeItemReceiverAppDelegate.h"

@implementation LargeItemReceiverAppDelegate

@synthesize window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    // Override point for customization after application launch
	
	[ILSwapService didFinishLaunchingWithOptions:launchOptions];
	
    [window makeKeyAndVisible];
	
	return YES;
}

- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url;
{
	return [ILSwapService handleOpenURL:url];
}

- (void) swapServiceDidReceiveRequest:(ILSwapRequest *)request;
{
	NSLog(@"%@", request.item.value);
	
	reader = [request.item.value reader];
	reader.delegate = self;
	
	[reader start];
}

- (void) reader:(id <ILSwapReader>)r didReceiveData:(NSData *)d;
{
	NSLog(@"Read %d bytes", (int) [d length]);
}

- (void) readerDidEnd:(id <ILSwapReader>)r;
{
	[reader release];
}

- (void)dealloc {
    [window release];
    [super dealloc];
}


@end

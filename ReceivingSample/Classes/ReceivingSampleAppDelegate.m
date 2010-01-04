//
//  ReceivingSampleAppDelegate.m
//  ReceivingSample
//
//  Created by ∞ on 28/12/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "ReceivingSampleAppDelegate.h"

#import <SwapKit/SwapKit.h>

@interface ReceivingSampleAppDelegate () <ILSwapServiceDelegate>
@end


@implementation ReceivingSampleAppDelegate

@synthesize window;


- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)options;
{
    [window makeKeyAndVisible];
	
	BOOL handled = [ILSwapService didFinishLaunchingWithOptions:options];
	if (!handled) {
		// handle URL or push notification here.
	}
	
	return YES;
}

- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url;
{
	BOOL handled = [ILSwapService handleOpenURL:url];
	if (!handled) {
		// handle other URL here.
	}
	
	return handled;
}

- (void) swapServiceDidReceiveRequest:(ILSwapRequest*) request;
{	
	// we received items via SwapKit! do stuff with them!
	id text = request.item.stringValue;
	if (text && [text isKindOfClass:[NSString class]])
		textView.text = text;
}

- (void) dealloc;
{
    [window release];
    [super dealloc];
}

@end

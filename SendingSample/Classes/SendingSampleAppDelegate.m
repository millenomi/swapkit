//
//  SendingSampleAppDelegate.m
//  SendingSample
//
//  Created by ∞ on 27/12/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "SendingSampleAppDelegate.h"
#import <SwapKit/SwapKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation SendingSampleAppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    // Override point for customization after application launch
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [window release];
    [super dealloc];
}

- (IBAction) send;
{
	ILSwapSendingController* sender = [ILSwapSendingController controllerForSendingItems:[NSArray arrayWithObject:loremIpsumView.text] ofType:(id) kUTTypeUTF8PlainText forAction:nil];
	[sender send];
}

@end

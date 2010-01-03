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


- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
{

	[ILSwapService didFinishLaunchingWithOptions:launchOptions];
    
	[window makeKeyAndVisible];
	doneButton.enabled = NO;
	 
	return YES;
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

- (IBAction) done;
{
	[loremIpsumView resignFirstResponder];
}

- (void) textViewDidBeginEditing:(UITextView *)textView;
{
	doneButton.enabled = YES;
}

- (void) textViewDidEndEditing:(UITextView *)textView;
{
	doneButton.enabled = NO;
}

@end

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

- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url;
{
	return [ILSwapService handleOpenURL:url];
}


- (void)dealloc {
    [window release];
    [super dealloc];
}

- (IBAction) send;
{
	ILSwapMutableItem* item = [ILSwapMutableItem item];
	item.value = loremIpsumView.text;
	item.attributes = [NSDictionary dictionaryWithObjectsAndKeys:
					   @"From Sender…", kILSwapItemTitleAttribute,
					   nil];
	item.type = (id) kUTTypeUTF8PlainText;
	
	ILSwapSendController* sender = [ILSwapSendController controllerForSendingItems:[NSArray arrayWithObject:item] forAction:nil];
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

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
	[window addSubview:rootController.view];
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
	
	BOOL foundText = NO, foundImage = NO;
	
	for (ILSwapItem* item in request.items) {
		
		if (!foundText && [item typeConformsTo:(id) kUTTypePlainText]) {
			NSString* text = item.stringValue;
			if (text)
				textView.text = text;
		
			id title = [item.attributes objectForKey:kILSwapItemTitleAttribute];
			if (title && [title isKindOfClass:[NSString class]])
				currentNavigationItem.title = title;
			
			foundText = YES;
			
		} else if (!foundImage && [item typeConformsTo:(id) kUTTypeImage]) {
			UIImage* image = item.imageValue;
			if (image)
				imageView.image = image;
			
			id title = [item.attributes objectForKey:kILSwapItemTitleAttribute];
			if (title && [title isKindOfClass:[NSString class]])
				imagePane.navigationItem.title = title;
			
			[rootController pushViewController:imagePane animated:YES];
			
			foundImage = YES;
			
		}
		
		if (foundText && foundImage)
			break;
	}
}

- (void) dealloc;
{
    [window release];
    [super dealloc];
}

@end

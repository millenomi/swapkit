//
//  LargeItemSenderAppDelegate.m
//  LargeItemSender
//
//  Created by ∞ on 01/03/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "LargeItemSenderAppDelegate.h"
#import <SwapKit/SwapKit.h>

@implementation LargeItemSenderAppDelegate

@synthesize window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

    // Override point for customization after application launch
	
	[[NSFileManager defaultManager] removeItemAtPath:[self path] error:NULL];
	[ILSwapService didFinishLaunchingWithOptions:launchOptions];
	
    [window makeKeyAndVisible];
	
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

- (NSString*) path;
{
	return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/BigFile.dat"];
}

- (IBAction) send;
{
#define kILSwapLargeItemSender_FileSizeInMB (30)
	
	NSFileManager* fm = [NSFileManager defaultManager];
	NSString* path = [self path];
	if (![fm fileExistsAtPath:path]) {
		
		uint8_t oneKBOfNothing[1024];
		bzero(oneKBOfNothing, sizeof(oneKBOfNothing));
		NSOutputStream* stream = [NSOutputStream outputStreamToFileAtPath:[self path] append:NO];
		[stream open];
		
		NSInteger i = 0;
		while (i <= kILSwapLargeItemSender_FileSizeInMB * 1024 * 1024)
			i += [stream write:oneKBOfNothing maxLength:1024];	
		
//		BOOL died = [stream streamError] != nil;
//		if (died)
//			abort();
		
		[stream close];
		
	}
	
	ILSwapItem* item = [ILSwapItem itemWithContentsOfFile:path type:@"public.data" attributes:nil];
	
	[[ILSwapSendController controllerForSendingItems:[NSArray arrayWithObject:item] forAction:nil] send];
}

@end

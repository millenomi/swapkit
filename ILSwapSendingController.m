//
//  ILSwapSendingController.m
//  SwapKit
//
//  Created by ∞ on 25/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ILSwapSendingController.h"
#import "ILSwapService.h"

@interface ILSwapSendingController () <UIActionSheetDelegate>

@end


@implementation ILSwapSendingController

- (id) initWithItems:(NSArray*) i ofType:(id) t forAction:(NSString*) a;
{
	if (!(self = [super init]))
		return nil;
	
	items = [i copy];
	type = [t copy];
	action = [a copy];
	
	return self;
}

- (void) dealloc
{
	[destinations release];
	
	[items release];
	[type release];
	[action release];
	
	[super dealloc];
}

+ (id) controllerForSendingItems:(NSArray*) items ofType:(id) uti forAction:(NSString*) action;
{
	return [[[self alloc] initWithItems:items ofType:uti forAction:action] autorelease];
}

- (void) send;
{
	UIWindow* w = UIApp.keyWindow;
	[self send:w];
}

- (void) send:(UIView*) v;
{
	ILSwapService* s = [ILSwapService sharedService];
	NSArray* candidates = [s allApplicationRegistrationsForSendingItems:items ofType:type forAction:action];
	
	if ([candidates count] == 0)
		return;
	
//	if ([d count] == 1) {
//		[s sendItems:items ofType:type forAction:action toApplicationWithIdentifier:[[d objectAtIndex:0] objectForKey:kILAppIdentifier]];
//		return;
//	}
	
	[destinations release]; destinations = nil;
	NSMutableArray* dests = [NSMutableArray array];

	[self retain];
	UIActionSheet* sheet = [[UIActionSheet new] autorelease];
	sheet.delegate = self;
	
	for (NSDictionary* app in candidates) {
		if (![app objectForKey:kILAppVisibleName])
			continue;
		
		[dests addObject:app];
		[sheet addButtonWithTitle:[app objectForKey:kILAppVisibleName]];
	}
	
	// TODO Decent localization.
	sheet.cancelButtonIndex = [sheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel button")];
	
	destinations = [dests copy];
	
	if ([v isKindOfClass:[UITabBar class]])
		[sheet showFromTabBar:(id) v];
	else if ([v isKindOfClass:[UIToolbar class]])
		[sheet showFromToolbar:(id) v];
	else
		[sheet showInView:v];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
	if (buttonIndex != actionSheet.cancelButtonIndex) {
		NSDictionary* app = [destinations objectAtIndex:buttonIndex];
		[[ILSwapService sharedService] sendItems:items ofType:type forAction:action toApplicationWithIdentifier:[app objectForKey:kILAppIdentifier]];
	}

	actionSheet.delegate = nil;
	[self autorelease];
}

@end

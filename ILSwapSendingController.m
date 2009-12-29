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

- (void) updateDestinations;

@end

L0UniquePointerConstant(kILSwapSendingControllerObservationContext);

@implementation ILSwapSendingController

- (id) init;
{
	if (!(self = [super init]))
		return nil;

	[self addObserver:self forKeyPath:@"items" options:0 context:kILSwapSendingControllerObservationContext];
	[self addObserver:self forKeyPath:@"type" options:0 context:kILSwapSendingControllerObservationContext];
	[self addObserver:self forKeyPath:@"action" options:0 context:kILSwapSendingControllerObservationContext];
	
	return self;
}

- (id) initWithItems:(NSArray*) i ofType:(id) t forAction:(NSString*) a;
{
	if (!(self = [self init]))
		return nil;
	
	items = [i copy];
	type = [t copy];
	action = [a copy];
	[self updateDestinations];
	
	return self;
}

@synthesize items, type, action;

- (void) dealloc
{
	[self removeObserver:self forKeyPath:@"items"];
	[self removeObserver:self forKeyPath:@"type"];
	[self removeObserver:self forKeyPath:@"action"];
	
	[destinations release];
	
	[items release];
	[type release];
	[action release];
	
	[sendButtonItem release];
	
	[super dealloc];
}

+ (id) controllerForSendingItems:(NSArray*) items ofType:(id) uti forAction:(NSString*) action;
{
	return [[[self alloc] initWithItems:items ofType:uti forAction:action] autorelease];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
	if (context == kILSwapSendingControllerObservationContext)
		[self updateDestinations];
}

- (void) updateDestinations;
{
	[destinations release]; destinations = nil;
	if (!self.items || !self.type)
		return;
	
	NSMutableArray* dests = [NSMutableArray array];

	ILSwapService* s = [ILSwapService sharedService];
	NSArray* candidates = [s allApplicationRegistrationsForSendingItems:items ofType:type forAction:action];
	
	if ([candidates count] == 0)
		return;
	
	for (NSDictionary* app in candidates) {
		if (![app objectForKey:kILAppVisibleName])
			continue;
		
		[dests addObject:app];
	}

	destinations = [dests copy];
	
	if (sendButtonItem)
		sendButtonItem.enabled = self.canSend;
}

- (BOOL) canSend;
{
	return destinations && [destinations count] > 0;
}
- (NSSet*) keyPathsForValuesAffectingCanSend;
{
	return [NSSet setWithObjects:@"items", @"type", @"action", nil];
}

- (UIBarButtonItem*) sendButtonItem;
{
	if (!sendButtonItem)
		sendButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(send)];
	
	return sendButtonItem;
}

- (void) send;
{
	UIWindow* w = UIApp.keyWindow;
	[self send:w];
}

- (void) send:(UIView*) v;
{
	if (!self.canSend)
		return;
	
	[self retain];
	UIActionSheet* sheet = [[UIActionSheet new] autorelease];
	sheet.delegate = self;
	
	for (NSDictionary* app in destinations)
		[sheet addButtonWithTitle:[app objectForKey:kILAppVisibleName]];

	// TODO Decent localization.
	sheet.cancelButtonIndex = [sheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel button")];
	
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

//
//  ILSwapSendController.m
//  SwapKit
//
//  Created by ∞ on 25/12/09.

/*
 
 The MIT License
 
 Copyright (c) 2009 Emanuele Vulcano ("∞labs")
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */


#import "ILSwapSendController.h"
#import "ILSwapService.h"
#import "ILSwapKitBundle.h"

@interface ILSwapSendController () <UIActionSheetDelegate>

- (void) updateDestinations;

@end

L0UniquePointerConstant(kILSwapSendControllerObservationContext);

@implementation ILSwapSendController

- (id) init;
{
	if (!(self = [super init]))
		return nil;

	[self addObserver:self forKeyPath:@"items" options:0 context:kILSwapSendControllerObservationContext];
	[self addObserver:self forKeyPath:@"type" options:0 context:kILSwapSendControllerObservationContext];
	[self addObserver:self forKeyPath:@"action" options:0 context:kILSwapSendControllerObservationContext];
	
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

@synthesize items, type, action, delegate;

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
	if (context == kILSwapSendControllerObservationContext)
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
	if (!self.canSend) {
		[self.delegate sendController:self didNotSendItemsWithCause:kILSwapNoKnownDestinationForSending];
		return;
	}
	
	[self retain];
	UIActionSheet* sheet = [[UIActionSheet new] autorelease];
	sheet.delegate = self;
	
	for (NSDictionary* app in destinations)
		[sheet addButtonWithTitle:[app objectForKey:kILAppVisibleName]];

	// TODO Decent localization.
	sheet.cancelButtonIndex = [sheet addButtonWithTitle:ILSwapLocalizedString(@"Cancel", @"Cancel button")];
	
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
	} else
		[self.delegate sendController:self didNotSendItemsWithCause:kILSwapSendingCancelled];

	actionSheet.delegate = nil;
	[self autorelease];
}

@end

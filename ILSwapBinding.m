//
//  ILSwapBinding.m
//  SwapKit
//
//  Created by ∞ on 27/02/10.
//  Copyright 2010 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import "ILSwapBinding.h"
#import <MobileCoreServices/MobileCoreServices.h>

#import "ILSwapService.h"
#import "ILSwapItem.h"


@implementation ILSwapBinding

+ binding;
{
	return [[[self alloc] initWithRegistrations:[ILSwapService sharedService].applicationRegistrations] autorelease];
}

- (id) initWithRegistrations:(NSDictionary*) regs;
{
	if (self = [super init]) {
		registrations = [regs copy];
		self.action = kILSwapDefaultAction;
	}
	
	return self;
}

- (void) clear;
{
	[appropriateApplications release];
	appropriateApplications = nil;
}

- (void) dealloc
{
	[self clear];
	[items release];
	[action release];
	
	[registrations release];
	[super dealloc];
}


#pragma mark -
#pragma mark Input

@synthesize items, action, allowMatchingThisApplication;

- (void) setItems:(NSArray *) a;
{
	if (a != items) {
		[self clear];
		
		[items release];
		items = [a copy];
	}
}

- (void) setAction:(NSString *) a;
{
	if (a == nil)
		a = kILSwapDefaultAction;

	if (a != action) {
		[self clear];
				
		[action release];
		action = [a copy];
	}
}

- (void) setAllowMatchingThisApplication:(BOOL) m;
{
	if (m != allowMatchingThisApplication) {
		[self clear];
		allowMatchingThisApplication = m;
	}
}

#pragma mark -
#pragma mark Output

- (NSArray*) findApplicationsStoppingAtFirstMatch:(BOOL) stopAtMatch;
{
	NSMutableArray* matchingApps = [NSMutableArray array];
	
	NSMutableSet* utis = [NSMutableSet set];
	for (ILSwapItem* i in items)
		[utis addObject:i.type];
	
	NSString* selfIdent = [[ILSwapService sharedService].applicationRegistration objectForKey:kILAppIdentifier];
	
	for (NSString* appID in registrations) {
		NSDictionary* reg = [registrations objectForKey:appID];
		// an app does not match if it is us and we don't want to match ourselves.
		if (!self.allowMatchingThisApplication && selfIdent && [appID isEqual:selfIdent])
			continue;
		
		// an app does not match if it's not installed.
		//if (!ILSwapIsAppInstalled(reg))
		//	continue;
		// we just assume ILSwapService fulfills its contract of never giving us uninstalled apps.
		
		// an app does not match if there are multiple items and it cannot accept them.
		if ([self.items count] > 1 && ![[reg objectForKey:kILAppSupportsReceivingMultipleItems] boolValue])
			continue;
		
		// an app does not match if there are multiple types and it does not support accepting multitype requests.
		if ([utis count] > 1 && ![[reg objectForKey:kILAppSupportsReceivingMultipleTypes] boolValue])
			continue;
		
		// an app does not match if it doesn't support any of the types we seek.
		NSArray* a = [reg objectForKey:kILAppSupportedReceivedItemsUTIs];
		if (!a || ![a isKindOfClass:[NSArray class]])
			continue;
		BOOL supportsAllUTIs = YES;
		for (NSString* type in utis) {
			BOOL found = NO;
			for (id supportedType in a) {
				if (![supportedType isKindOfClass:[NSString class]])
					continue;
				
				if ([type isEqual:supportedType] || UTTypeConformsTo((CFStringRef) type, (CFStringRef) supportedType)) {
					found = YES;
					break;
				}
			}
			
			if (!found) {
				supportsAllUTIs = NO;
				break;
			}
		}
		
		if (!supportsAllUTIs)
			continue;
		
		// it matches!
		[matchingApps addObject:reg];
		
		if (stopAtMatch)
			break;
	}
	
	return matchingApps;
}

- (NSArray*) appropriateApplications;
{
	if (!self.items || !self.action)
		return nil;
	
	if (!appropriateApplications)
		appropriateApplications = [[self findApplicationsStoppingAtFirstMatch:NO] copy];
	
	return appropriateApplications;
}

- (BOOL) canSend;
{
	if (!self.items || !self.action)
		return NO;
	
	if (appropriateApplications && [appropriateApplications count] != 0)
		return YES;
	
	if ([[self findApplicationsStoppingAtFirstMatch:YES] count] != 0)
		return YES;
	else
		appropriateApplications = [NSArray new]; // since nothing matches, we cache the fact.
	
	return NO;
}

@end

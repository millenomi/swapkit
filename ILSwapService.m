//
//  ILSwapService.m
//  SwapKit
//
//  Created by ∞ on 21/12/09.

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

#import "ILSwapService.h"
#import <MobileCoreServices/MobileCoreServices.h>

#import "ILSwapRequest.h"
#import "ILSwapRequest_Private.h"

#define kILSwapServiceAppCatalogPasteboardName @"net.infinite-labs.SwapKit.AppCatalog"
#define kILSwapServiceLastRegistrationUUIDDefaultsKey @"ILSwapServiceLastRegistrationUUID"
#define kILSwapServiceRegistrationUTI @"net.infinite-labs.SwapKit.Registration"

#define kILSwapServiceThisSessionOnlyPasteboardsDefaultsKey @"ILSwapServiceThisSessionOnlyPasteboardsDefaultsKey"

#import "L0UUID.h"
#import "NSURL+L0URLParsing.h"

#import "ILSwapKitGuards.h"

#import "ILSwapItem.h"
#import "ILSwapItem_Private.h"

#import "ILSwapBinding.h"

#import "ILSwapService_Private.h"

#import "ILSwapPasteboardSender.h"

static BOOL ILSwapIsAppInstalled(NSDictionary* reg) {
	NSString* s = [reg objectForKey:kILAppReceiveItemURLScheme];
	return s && [UIApp canOpenURL:
				 [NSURL URLWithString:[NSString stringWithFormat:@"%@:", s]]];
}

static BOOL ILSwapContainsAllObjectsInArray(NSArray* containee, NSArray* contents) {
	for (id i in contents) {
		if (![containee containsObject:i])
			return NO;
	}
	
	return YES;
}


@interface ILSwapService ()

- (NSDictionary*) registrationByApplyingDefaultsToAttributes:(NSDictionary*) a;

@end



@implementation ILSwapService

#pragma mark -
#pragma mark Convenience methods

+ (BOOL) didFinishLaunchingWithOptions:(NSDictionary*) options;
{
	BOOL didAnythingWithTheURL = NO;
	
	ILSwapService* me = [self sharedService];
	// set delegate
	id a = [[UIApplication sharedApplication] delegate];
	me.delegate = a;
	
	NSDictionary* d = L0As(NSDictionary, [[[NSBundle mainBundle] infoDictionary] objectForKey:kILSwapServiceRegistrationInfoDictionaryKey]);
	if (d)
		[me registerWithAttributes:d update:NO];
	
	NSURL* u = [options objectForKey:UIApplicationLaunchOptionsURLKey];
	if (u)
		didAnythingWithTheURL = [me performActionsForURL:u];

	[me deleteInvalidatedPasteboards];
	return didAnythingWithTheURL;
}

+ (BOOL) handleOpenURL:(NSURL*) u;
{
	return [[self sharedService] performActionsForURL:u];
}


#pragma mark -
#pragma mark Initialization

L0ObjCSingletonMethod(sharedService)

- (id) init
{	
	self = [super init];
	if (self != nil) {
		appCatalog = [[UIPasteboard pasteboardWithName:kILSwapServiceAppCatalogPasteboardName create:YES] retain];
		appCatalog.persistent = YES;
	}
	
	return self;
}

- (void) dealloc
{
	[registrationAttributes release];
	[appCatalog release];
	[thisSessionOnlyPasteboards release];
	[super dealloc];
}

#pragma mark -
#pragma mark Properties

@synthesize delegate, applicationRegistration = registrationAttributes;


#pragma mark -
#pragma mark Registration Management & Bindings

- (void) registerWithAttributes:(NSDictionary*) a update:(BOOL) update;
{
	if (registrationAttributes) {
		[registrationAttributes release];
		registrationAttributes = nil;
	}
	
	// check out if there's anything in the app catalog we have to fix.
	NSString* appID = [a objectForKey:kILAppIdentifier];
	if (!appID)
		appID = [[NSBundle mainBundle] bundleIdentifier];
	
	id currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	NSString* currentUUID = L0As(NSString, [[NSUserDefaults standardUserDefaults] objectForKey:kILSwapServiceLastRegistrationUUIDDefaultsKey]);
	
	NSIndexSet* allRegistrationIndexes = [appCatalog itemSetWithPasteboardTypes:[NSArray arrayWithObject:kILSwapServiceRegistrationUTI]];
	
	NSMutableIndexSet* selfRegistrationIndexes = [NSMutableIndexSet indexSet];
	NSDictionary* ourOwnFoundData = nil;
	
	NSUInteger idx = [allRegistrationIndexes firstIndex];
	for (id reg in [appCatalog valuesForPasteboardType:kILSwapServiceRegistrationUTI inItemSet:allRegistrationIndexes]) {
		if ([reg isKindOfClass:[NSData class]]) {
			NSPropertyListFormat notInteresting;
			NSString* error = nil;
			reg = [NSPropertyListSerialization propertyListFromData:reg mutabilityOption:NSPropertyListImmutable format:&notInteresting errorDescription:&error];
			
			if (!reg && error) {
				NSLog(@"Could not read data from one of the app catalog entries: %@", error);
				[error release];
			}
		}
		
		if ([reg isKindOfClass:[NSDictionary class]] && [[reg objectForKey:kILAppIdentifier] isEqual:appID]) {
			
			[selfRegistrationIndexes addIndex:idx];

			if (!update) {
				NSString* UUID = [reg objectForKey:kILAppRegistrationUUID];
				id thisVersion = [reg objectForKey:kILAppVersion];
				if ([currentUUID isEqual:UUID] && [thisVersion isEqual:currentVersion]) {
					// we got our own data and were told not to update it.
					// we save it as our registrationAttributes, then.
					if (!ourOwnFoundData)
						ourOwnFoundData = reg;
					// and bail.
					continue;
				}				
			}
		}
		
		idx = [allRegistrationIndexes indexGreaterThanIndex:idx];
	}
	
	if (!update && ourOwnFoundData && [selfRegistrationIndexes count] == 1) {
		registrationAttributes = [ourOwnFoundData copy];
		return;
	}
	
	NSMutableArray* items = [[appCatalog.items mutableCopy] autorelease];
	[items removeObjectsAtIndexes:selfRegistrationIndexes];
	
	a = [self registrationByApplyingDefaultsToAttributes:a];
	NSDictionary* item = [NSDictionary dictionaryWithObject:a forKey:kILSwapServiceRegistrationUTI];
	[items addObject:item];
	appCatalog.items = items;
	
	NSString* newUUID = [a objectForKey:kILAppRegistrationUUID];
	[[NSUserDefaults standardUserDefaults] setObject:newUUID forKey:kILSwapServiceLastRegistrationUUIDDefaultsKey];
	
	registrationAttributes = [a copy];
}

- (NSDictionary*) registrationByApplyingDefaultsToAttributes:(NSDictionary*) a;
{
	NSMutableDictionary* reg = [NSMutableDictionary dictionaryWithDictionary:a];
	
	NSString* newUUID = [[L0UUID UUID] stringValue];
	[reg setObject:newUUID forKey:kILAppRegistrationUUID];
	
	if (![reg objectForKey:kILAppIdentifier])
		[reg setObject:[[NSBundle mainBundle] bundleIdentifier] forKey:kILAppIdentifier];
	
	if (![reg objectForKey:kILAppVersion]) {
		id currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
		[reg setObject:currentVersion forKey:kILAppVersion];
	}
	
	if (![reg objectForKey:kILAppVisibleName]) {
		id x = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
		if (!x)
			x = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
		if (!x)
			x = [[[[NSBundle mainBundle] bundlePath] lastPathComponent] stringByDeletingPathExtension];
		
		[reg setObject:x forKey:kILAppVisibleName];
	}
	
	if ([reg objectForKey:kILAppReceiveItemURLScheme]) {
		if (![reg objectForKey:kILAppSupportedReceivedItemsUTIs])
			[reg setObject:[NSArray array] forKey:kILAppSupportedReceivedItemsUTIs];
		
		if (![reg objectForKey:kILAppSupportsReceivingMultipleItems])
			[reg setObject:[NSNumber numberWithBool:NO] forKey:kILAppSupportsReceivingMultipleItems];
		
		// if the user specifies any UTIs, it's (public.data). Otherwise, ().
		if (![reg objectForKey:kILAppSupportedActions]) {
			NSArray* a = ([[reg objectForKey:kILAppSupportedReceivedItemsUTIs] count] != 0)?
				[NSArray arrayWithObject:kILSwapDefaultAction] : [NSArray array];
			[reg setObject:a forKey:kILAppSupportedActions];
		}
	}
	
	return reg;
}

- (NSDictionary*) applicationRegistrations;
{
	if (!appRegistrations) {
		NSMutableDictionary* regs = [NSMutableDictionary dictionary];
		
		NSIndexSet* s = [appCatalog itemSetWithPasteboardTypes:[NSArray arrayWithObject:kILSwapServiceRegistrationUTI]];
		for (id x in [appCatalog valuesForPasteboardType:kILSwapServiceRegistrationUTI inItemSet:s]) {
			if ([x isKindOfClass:[NSData class]]) {
				NSPropertyListFormat f; NSString* e = nil;
				x = [NSPropertyListSerialization propertyListFromData:x mutabilityOption:NSPropertyListImmutable format:&f errorDescription:&e];
				
				if (e) {
					NSLog(@"<SwapKit> Error while deserializing part of the application catalog: %@", e);
					[e release];
				}
			}
			
			if ([x isKindOfClass:[NSDictionary class]] && ILSwapIsAppInstalled(x)) {
				NSString* ident = [x objectForKey:kILAppIdentifier];
				if (ident)
					[regs setObject:x forKey:ident];
			}
		}
		
		appRegistrations = [regs copy];
	}
	
	return appRegistrations;
}

- (NSArray*) internalApplicationRegistrationRecords;
{
	NSMutableArray* regs = [NSMutableArray array];
	
	NSIndexSet* s = [appCatalog itemSetWithPasteboardTypes:[NSArray arrayWithObject:kILSwapServiceRegistrationUTI]];
	for (id x in [appCatalog valuesForPasteboardType:kILSwapServiceRegistrationUTI inItemSet:s]) {
		if ([x isKindOfClass:[NSData class]]) {
			NSPropertyListFormat f; NSString* e = nil;
			x = [NSPropertyListSerialization propertyListFromData:x mutabilityOption:NSPropertyListImmutable format:&f errorDescription:&e];
			
			if (e) {
				NSLog(@"<SwapKit> Error while deserializing part of the application catalog: %@", e);
				[e release];
			}
		}
		
		if ([x isKindOfClass:[NSDictionary class]]) 
			[regs addObject:x];
	}
	
	return regs;
}

- (void) deleteAllApplicationRegistrations;
{
	[registrationAttributes release]; registrationAttributes = nil;
	[appCatalog release]; appCatalog = nil;
	[UIPasteboard removePasteboardWithName:kILSwapServiceAppCatalogPasteboardName];
	
	appCatalog = [[UIPasteboard pasteboardWithName:kILSwapServiceAppCatalogPasteboardName create:YES] retain];
}

- (NSDictionary*) registrationForApplicationWithIdentifier:(NSString*) appID;
{
	return [[self applicationRegistrations] objectForKey:appID];
}

// TODO rewrite this to take multiple types into account.
- (NSDictionary*) applicationRegistrationForSendingItems:(NSArray*) items forAction:(NSString*) action;
{	
	ILSwapBinding* binding = [ILSwapBinding binding];
	binding.items = items;
	binding.action = action;
	
	NSArray* regs = binding.appropriateApplications;
	return [regs count] > 0? [binding.appropriateApplications objectAtIndex:0] : nil;
}

- (BOOL) canSendItems:(NSArray*) items forAction:(NSString*) action;
{
	ILSwapBinding* binding = [ILSwapBinding binding];
	binding.items = items;
	binding.action = action;
	
	return binding.canSend;
}

- (NSArray*) allApplicationRegistrationsForSendingItems:(NSArray*) items forAction:(NSString*) action;
{
	if (!action)
		action = kILSwapDefaultAction;
	
	ILSwapBinding* binding = [ILSwapBinding binding];
	binding.items = items;
	binding.action = action;
	
	return binding.appropriateApplications;
}

#pragma mark -
#pragma mark Receiving


- (BOOL) performActionsForURL:(NSURL*) u;
{
	if (!registrationAttributes)
		return NO;
	
	NSString* recvScheme = [registrationAttributes objectForKey:kILAppReceiveItemURLScheme];
	if (!recvScheme)
		return NO;
	
	NSDictionary* parts = [u dictionaryByDecodingQueryString];
	
	if ([[u scheme] isEqual:recvScheme]) {
		if ([delegate respondsToSelector:@selector(swapServiceDidReceiveRequest:)]) {
			
			NSString* pasteboardName = [parts objectForKey:kILSwapServicePasteboardNameKey];
			
			UIPasteboard* pb = nil;
			
			if (pasteboardName)
				pb = [UIPasteboard pasteboardWithName:pasteboardName create:YES];
			
			if (pb.numberOfItems > 0) {
				ILSwapRequest* req = [[[ILSwapRequest alloc] initWithPasteboard:pb attributes:parts removePasteboardWhenDone:YES] autorelease];
				
				[delegate swapServiceDidReceiveRequest:req];
				return YES;
			}
		}
		
		if ([delegate respondsToSelector:@selector(swapServiceDidReceiveRequestWithAttributes:)]) {
			[delegate swapServiceDidReceiveRequestWithAttributes:parts];
			return YES;
		}
	}
	
	return NO;
}


#pragma mark -
#pragma mark Sending

- (BOOL) sendingAsynchronously;
{
	return asyncSender != nil;
}

- (BOOL) sendItem:(ILSwapItem*) item forAction:(NSString*) action toApplicationWithIdentifier:(NSString*) appID;
{
	return [self sendItems:[NSArray arrayWithObject:item] forAction:action toApplicationWithIdentifier:appID];
}

- (BOOL) sendItems:(NSArray*) items forAction:(NSString*) action toApplicationWithIdentifier:(NSString*) appID;
{
	if (asyncSender)
		return NO; // one at a time please
	
	ILSwapPasteboardSender* sender = [[[ILSwapPasteboardSender alloc] initWithItems:items action:action applicationIdentifier:appID] autorelease];
	
	ILSwapSendResult r = [sender send];
	if (r == kILSwapSendOngoing) {
		
		if ([delegate respondsToSelector:@selector(swapServiceWillBeginSendingAsynchronousRequest)])
			[delegate swapServiceWillBeginSendingAsynchronousRequest];
		
		asyncSender = [sender retain];
		
	}
	
	return r != kILSwapSendError;
}

- (void) sendingFinishedWithResult:(ILSwapSendResult)r;
{
	if ([delegate respondsToSelector:@selector(swapServiceDidEndSendingAsynchronousRequest:)])
		[delegate swapServiceDidEndSendingAsynchronousRequest:r != kILSwapSendError];

	[asyncSender autorelease]; asyncSender = nil;
}

- (BOOL) sendRequestWithAttributes:(NSDictionary*) attributes toApplicationWithRegistration:(NSDictionary*) reg;
{
	NSString* s = [reg objectForKey:kILAppReceiveItemURLScheme];
	if (!s)
		return NO;
		
	NSString* queryString = [attributes queryString];
	NSString* urlString = [NSString stringWithFormat:@"%@:?%@", s, queryString];
	NSURL* u = [NSURL URLWithString:urlString];
	if (!u)
		return NO;
	
	if (![[UIApplication sharedApplication] canOpenURL:u])
		return NO;
	
	return [[UIApplication sharedApplication] openURL:u];
}

- (BOOL) openApplicationWithIdentifier:(NSString*) ident;
{
	NSDictionary* d = [self registrationForApplicationWithIdentifier:ident];
	if (!d)
		return NO;
	
	return [self sendRequestWithAttributes:[NSDictionary dictionaryWithObject:@"YES" forKey:kILSwapServiceJustOpenKey] toApplicationWithRegistration:d];
}

@end

@implementation ILSwapService (ILSwapPasteboardLifetime)

- (void) deleteInvalidatedPasteboards;
{
	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	
	NSArray* a = L0As(NSArray, [ud objectForKey:kILSwapServiceThisSessionOnlyPasteboardsDefaultsKey]);
	if (!a)
		return;
	
	NSMutableArray* items = [NSMutableArray arrayWithArray:a];
	
	NSInteger i; for (i = 0; i < [items count]; i++) {
		NSString* pasteboardName = L0As(NSString, [items objectAtIndex:i]);
		BOOL shouldRemove = NO;
		
		if (pasteboardName &&
			![thisSessionOnlyPasteboards containsObject:pasteboardName]) {
			[UIPasteboard removePasteboardWithName:pasteboardName];
			shouldRemove = YES;
		} else if (!pasteboardName) {
			shouldRemove = YES;
		}
		
		if (shouldRemove) {
			[items removeObjectAtIndex:i];
			i--;
		}
	}
	
	if ([items count] == 0)
		[ud removeObjectForKey:kILSwapServiceThisSessionOnlyPasteboardsDefaultsKey];
	else
		[ud setObject:items forKey:kILSwapServiceThisSessionOnlyPasteboardsDefaultsKey];
}

- (void) managePasteboard:(UIPasteboard*) pb withLifetimePeriod:(ILSwapPasteboardLifetime) lt;
{
	// TODO other lifetimes.
	if (lt != kILSwapPasteboardThisSessionOnly)
		return;
	
	NSMutableArray* pasteboards = [NSMutableArray array];
	NSArray* a = L0As(NSArray, [[NSUserDefaults standardUserDefaults] objectForKey:kILSwapServiceThisSessionOnlyPasteboardsDefaultsKey]);
	if (a)
		[pasteboards setArray:a];
	
	[pasteboards addObject:pb.name];
	
	if (!thisSessionOnlyPasteboards)
		thisSessionOnlyPasteboards = [NSMutableSet new];
	
	[thisSessionOnlyPasteboards addObject:pb.name];
	
	[[NSUserDefaults standardUserDefaults] setObject:pasteboards forKey:kILSwapServiceThisSessionOnlyPasteboardsDefaultsKey];
}

@end

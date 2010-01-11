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

enum {
	kILSwapPasteboardThisSessionOnly,
};
typedef NSInteger ILSwapPasteboardLifetime;

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

@interface ILSwapService (ILSwapPasteboardLifetime)

- (void) deleteInvalidatedPasteboards;
- (void) managePasteboard:(UIPasteboard*) pb withLifetimePeriod:(ILSwapPasteboardLifetime) lt;

@end

@interface ILSwapService ()

- (NSArray*) findApplicationRegistrationsForSendingItems:(NSArray*) items ofType:(id) uti forAction:(NSString*) action stopAtTheFirstMatch:(BOOL) oneOnly;

@end



@implementation ILSwapService

+ (BOOL) didFinishLaunchingWithOptions:(NSDictionary*) options;
{
	BOOL didAnythingWithTheURL = NO;
	
	ILSwapService* me = [self sharedService];
	// set delegate
	id a = [[UIApplication sharedApplication] delegate];
	me.delegate = a;
	
	NSDictionary* d = L0As(NSDictionary, [[[NSBundle mainBundle] infoDictionary] objectForKey:kILSwapServiceRegistrationInfoDictionaryKey]);
	if (d)
		[me registerWithAttributes:d];
	
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

@synthesize delegate;

- (void) dealloc
{
	[registrationAttributes release];
	[appCatalog release];
	[thisSessionOnlyPasteboards release];
	[super dealloc];
}


- (void) registerWithAttributes:(NSDictionary*) a;
{
	if (registrationAttributes) {
		[registrationAttributes release];
		registrationAttributes = nil;
	}
	
	NSInteger previousNumberOfItems = appCatalog.numberOfItems;
	
	// 1. Check to see if we're already registered and, if so, if we're out of date.
	
	NSString* appID = [a objectForKey:kILAppIdentifier];
	BOOL hasAppID = (appID != nil);
	if (!appID)
		appID = [[NSBundle mainBundle] bundleIdentifier];
	
	id currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	NSString* currentUUID = L0As(NSString, [[NSUserDefaults standardUserDefaults] objectForKey:kILSwapServiceLastRegistrationUUIDDefaultsKey]);
	
	NSIndexSet* allRegistrationIndexes = [appCatalog itemSetWithPasteboardTypes:[NSArray arrayWithObject:kILSwapServiceRegistrationUTI]];
	
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
			
			NSString* UUID = [reg objectForKey:kILAppRegistrationUUID];
			id thisVersion = [reg objectForKey:kILAppVersion];
			if ([currentUUID isEqual:UUID] && [thisVersion isEqual:currentVersion]) {
				// we extract info from the pasteboard rather than using the one passed in.
				registrationAttributes = [reg copy];
				return; // no need to update.
			} else
				break; // we found our spot and it's out of date.
			
		}
		
		idx = [allRegistrationIndexes indexGreaterThanIndex:idx];
	}
	
	// 2. Add or update the registration. (idx == NSNotFound if it must be added, the actual index if it must be updated.)
	
	NSInteger expectedNumberOfItems = (idx == NSNotFound? previousNumberOfItems + 1 : previousNumberOfItems);
	
	// Add the UUID and the defaults if needed
	NSMutableDictionary* reg = [NSMutableDictionary dictionaryWithDictionary:a];
	NSString* newUUID = [[L0UUID UUID] stringValue];
	[reg setObject:newUUID forKey:kILAppRegistrationUUID];
	
	if (!hasAppID)
		[reg setObject:[[NSBundle mainBundle] bundleIdentifier] forKey:kILAppIdentifier];
	
	[reg setObject:currentVersion forKey:kILAppVersion];
	
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
			[reg setObject:[NSArray arrayWithObject:(id) kUTTypeData] forKey:kILAppSupportedReceivedItemsUTIs];
		
		if (![reg objectForKey:kILAppSupportsReceivingMultipleItems])
			[reg setObject:[NSNumber numberWithBool:NO] forKey:kILAppSupportsReceivingMultipleItems];
		
		if (![reg objectForKey:kILAppSupportedActions])
			[reg setObject:[NSArray arrayWithObject:kILSwapDefaultAction] forKey:kILAppSupportedActions];
	}
	
	if (idx == NSNotFound) {
		NSArray* registrationItemArray = [NSArray arrayWithObject:
										  [NSDictionary dictionaryWithObject:reg forKey:kILSwapServiceRegistrationUTI]];		
		[appCatalog addItems:registrationItemArray];
	} else {
		NSMutableArray* items = [NSMutableArray arrayWithArray:appCatalog.items];
		[items replaceObjectAtIndex:idx withObject:reg];
		appCatalog.items = items;
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:newUUID forKey:kILSwapServiceLastRegistrationUUIDDefaultsKey];
	
	ILSwapKitGuardWrongNumberOfItemsAfterRegistration(expectedNumberOfItems, appCatalog.numberOfItems);
	
	registrationAttributes = [reg copy];
}


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
			
			if ([x isKindOfClass:[NSDictionary class]]) {
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

- (NSDictionary*) applicationRegistrationForSendingItems:(NSArray*) items ofType:(id) uti forAction:(NSString*) action;
{
	if (!action)
		action = kILSwapDefaultAction;
	
	NSDictionary* reg = nil;
	BOOL isMany = [items count] > 1;
	for (NSString* candidateAppID in [self applicationRegistrations]) {
		NSDictionary* r = [[self applicationRegistrations] objectForKey:candidateAppID];
		if (![r objectForKey:kILAppReceiveItemURLScheme])
			continue;
		
		if (![L0As(NSArray, [r objectForKey:kILAppSupportedActions]) containsObject:action])
			continue;
		
		NSArray* supportedUTIs = L0As(NSArray, [r objectForKey:kILAppSupportedReceivedItemsUTIs]);
		BOOL hasUTI = [supportedUTIs containsObject:(id) kUTTypeData] || [supportedUTIs containsObject:uti];
		if (!hasUTI) {
			for (NSString* supportedUTI in supportedUTIs) {
				if (UTTypeConformsTo((CFStringRef) uti, (CFStringRef) supportedUTI)) {
					hasUTI = YES;
					break;
				}
			}
		}
		
		if (!hasUTI)
			continue;
		
		if (isMany && ![L0As(NSNumber, [r objectForKey:kILAppSupportsReceivingMultipleItems]) boolValue])
			continue;
		
		reg = r;
		break;
	}
	
	if (!reg && isMany) {
		for (NSString* candidateAppID in [self applicationRegistrations]) {
			NSDictionary* r = [[self applicationRegistrations] objectForKey:candidateAppID];
			if (![r objectForKey:kILAppReceiveItemURLScheme])
				continue;
			
			if (![L0As(NSArray, [r objectForKey:kILAppSupportedActions]) containsObject:action])
				continue;
			
			NSArray* supportedUTIs = L0As(NSArray, [r objectForKey:kILAppSupportedReceivedItemsUTIs]);
			BOOL hasUTI = [supportedUTIs containsObject:(id) kUTTypeData] || [supportedUTIs containsObject:uti];
			if (!hasUTI) {
				for (NSString* supportedUTI in supportedUTIs) {
					if (UTTypeConformsTo((CFStringRef) uti, (CFStringRef) supportedUTI)) {
						hasUTI = YES;
						break;
					}
				}
			}
			
			if (!hasUTI)
				continue;
			
			reg = r;
			break;
		}
	}
	
	return reg;
}

- (BOOL) canSendItems:(NSArray*) items ofType:(id) uti forAction:(NSString*) action;
{
	return [[self findApplicationRegistrationsForSendingItems:items ofType:uti forAction:action stopAtTheFirstMatch:YES] count] != 0;
}

- (NSArray*) allApplicationRegistrationsForSendingItems:(NSArray*) items ofType:(id) uti forAction:(NSString*) action;
{
	return [self findApplicationRegistrationsForSendingItems:items ofType:uti forAction:action stopAtTheFirstMatch:NO];
}

- (NSArray*) findApplicationRegistrationsForSendingItems:(NSArray*) items ofType:(id) uti forAction:(NSString*) action stopAtTheFirstMatch:(BOOL) oneOnly;
{
	if (!action)
		action = kILSwapDefaultAction;
	
	NSMutableArray* candidates = [NSMutableArray array];
	for (NSString* candidateAppID in [self applicationRegistrations]) {
		NSDictionary* r = [[self applicationRegistrations] objectForKey:candidateAppID];
		if (![r objectForKey:kILAppReceiveItemURLScheme])
			continue;
		
		if (![[r objectForKey:kILAppSupportedActions] containsObject:action])
			continue;
		
		if (![L0As(NSArray, [r objectForKey:kILAppSupportedReceivedItemsUTIs]) containsObject:uti])
			continue;
		
		[candidates addObject:r];
		
		if (oneOnly)
			break;
	}	
	
	return candidates;
}

- (BOOL) sendItems:(NSArray*) items ofType:(id) uti forAction:(NSString*) action toApplicationWithIdentifier:(NSString*) appID;
{
	if ([items count] == 0)
		return NO;
	
	if (!action)
		action = kILSwapDefaultAction;
	
	NSDictionary* reg = nil;
	if (appID)
		reg = [self registrationForApplicationWithIdentifier:appID];
	else 
		reg = [self applicationRegistrationForSendingItems:items ofType:uti forAction:action];
	
	if (!reg)
		return NO;
		
	BOOL handlesOnlyOne = ![L0As(NSNumber, [reg objectForKey:kILAppSupportsReceivingMultipleItems]) boolValue];
	
	UIPasteboard* pb = [UIPasteboard pasteboardWithUniqueName];
	pb.persistent = YES;
	
	NSMutableArray* a = [NSMutableArray array];
	for (id item in items) {
		NSDictionary* d;
		if ([item isKindOfClass:[ILSwapItem class]]) 
			d = [item pasteboardItemOfType:uti];
		else
			d = [NSDictionary dictionaryWithObject:item forKey:uti];
		
		if (!d) {
			[NSException raise:@"ILSwapServiceCannotSendObject" format:@"Could not extract a value from object: %@", item];
			return NO;
		}
		
		[a addObject:d];
		
		if (handlesOnlyOne)
			break;
	}
	pb.items = a;
	
	NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
						   pb.name, kILSwapServicePasteboardNameKey,
						   action, kILSwapServiceActionKey,
						   nil];
	
	[self managePasteboard:pb withLifetimePeriod:kILSwapPasteboardThisSessionOnly];
	
	BOOL done = [self sendRequestWithAttributes:attrs toApplicationWithRegistration:reg];
	if (!done)
		[UIPasteboard removePasteboardWithName:pb.name];
	
	return done;
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

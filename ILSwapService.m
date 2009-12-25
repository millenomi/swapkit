//
//  ILSwapService.m
//  SwapKit
//
//  Created by ∞ on 21/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ILSwapService.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define kILSwapServiceAppCatalogPasteboardName @"net.infinite-labs.SwapKit.AppCatalog"
#define kILSwapServiceLastRegistrationUUIDDefaultsKey @"ILSwapServiceLastRegistrationUUID"
#define kILSwapServiceRegistrationUTI @"net.infinite-labs.SwapKit.Registration"

#import "L0UUID.h"
#import "NSURL+L0URLParsing.h"

@implementation ILSwapService

+ (BOOL) didFinishLaunchingWithOptions:(NSDictionary*) options;
{
	ILSwapService* me = [self sharedService];
	// set delegate
	id a = [[UIApplication sharedApplication] delegate];
	me.delegate = a;
	
	NSDictionary* d = L0As(NSDictionary, [[[NSBundle mainBundle] infoDictionary] objectForKey:kILSwapServiceRegistrationInfoDictionaryKey]);
	if (d)
		[me registerWithAttributes:d];
	
	NSURL* u = [options objectForKey:UIApplicationLaunchOptionsURLKey];
	if (u)
		return [me performActionsForURL:u];
	else
		return NO;
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
	[super dealloc];
}


- (void) registerWithAttributes:(NSDictionary*) a;
{
	if (registrationAttributes) {
		[registrationAttributes release];
		registrationAttributes = nil;
	}
	
	// 1. Check to see if we're already registered and, if so, if we're out of date.
	
	BOOL hasAppID = YES;
	NSString* appID = [a objectForKey:kILAppIdentifier];
	if (!appID) {
		hasAppID = NO;
		appID = [[NSBundle mainBundle] bundleIdentifier];
	}
	
	id currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	NSString* currentUUID = L0As(NSString, [[NSUserDefaults standardUserDefaults] objectForKey:kILSwapServiceLastRegistrationUUIDDefaultsKey]);
	
	NSIndexSet* allRegistrationIndexes = [appCatalog itemSetWithPasteboardTypes:[NSArray arrayWithObject:kILSwapServiceRegistrationUTI]];
	
	NSUInteger idx = [allRegistrationIndexes firstIndex];
	for (id reg in [appCatalog valuesForPasteboardType:kILSwapServiceRegistrationUTI inItemSet:allRegistrationIndexes]) {
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
	
	NSArray* registrationItemArray = [NSArray arrayWithObject:
								 [NSDictionary dictionaryWithObject:reg forKey:kILSwapServiceRegistrationUTI]];
	
	if (idx == NSNotFound)
		[appCatalog addItems:registrationItemArray];
	else {
		NSMutableArray* items = [NSMutableArray arrayWithArray:appCatalog.items];
		[items replaceObjectAtIndex:idx withObject:registrationItemArray];
		appCatalog.items = items;
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:newUUID forKey:kILSwapServiceLastRegistrationUUIDDefaultsKey];
	
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
		if ([delegate respondsToSelector:@selector(swapServiceDidReceiveItemsInPasteboard:attributes:)]) {
		
			NSString* pasteboardName = [parts objectForKey:kILSwapServicePasteboardNameKey];
			
			UIPasteboard* pb = nil;
			
			if (pasteboardName)
				pb = [UIPasteboard pasteboardWithName:pasteboardName create:YES];
			
			if (pb.numberOfItems > 0) {
				[delegate swapServiceDidReceiveItemsInPasteboard:pb attributes:parts];
				[UIPasteboard removePasteboardWithName:pb.name];
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
		
		if (![[r objectForKey:kILAppSupportedActions] containsObject:action])
			continue;
		
		if (![L0As(NSArray, [r objectForKey:kILAppSupportedReceivedItemsUTIs]) containsObject:uti])
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
			
			if (![[r objectForKey:kILAppSupportedActions] containsObject:action])
				continue;
			
			if (![L0As(NSArray, [r objectForKey:kILAppSupportedReceivedItemsUTIs]) containsObject:uti])
				continue;
			
			reg = r;
			break;
		}
	}
	
	return reg;
}

- (NSArray*) allApplicationRegistrationsForSendingItems:(NSArray*) items ofType:(id) uti forAction:(NSString*) action;
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
		NSDictionary* d = [NSDictionary dictionaryWithObject:item forKey:uti];
		[a addObject:d];
		
		if (handlesOnlyOne)
			break;
	}
	pb.items = a;
	
	NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
						   pb.name, kILSwapServicePasteboardNameKey,
						   action, kILSwapServiceActionKey,
						   nil];
	
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

//
//  ILSwapSendOperation.m
//  SwapKit
//
//  Created by ∞ on 01/03/10.
//  Copyright 2010 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import "ILSwapPasteboardSender.h"

#import "ILSwapService.h"
#import "ILSwapService_Private.h"
#import "ILSwapItem.h"
#import "ILSwapItem_Private.h"

#import "ILSwapLargeItemSupport.h"

// The size of the data in a single fragment pasteboard.
#define kILSwapPasteboardSenderFragmentSize (3 * 1024 * 1024)

@interface ILSwapPasteboardSender () <ILSwapReaderDelegate>

- (void) endSending;
- (void) commitPasteboardForReader:(id <ILSwapReader>) r;

@end


@implementation ILSwapPasteboardSender

- (id) initWithItems:(NSArray*) i action:(NSString*) a applicationIdentifier:(NSString*) ai;
{
	if (self = [super init]) {
		items = [i copy];
		if (!a)
			a = kILSwapDefaultAction;
		action = [a copy];
		appID = [ai copy];
	}
	
	return self;
}

- (void) dealloc;
{
	[self endSending];
	
	[items release];
	[action release];
	[appID release];
	[super dealloc];
}

- (ILSwapSendResult) send;
{
	ILSwapService* s = [ILSwapService sharedService];
	
	if ([items count] == 0)
		return kILSwapSendError;
		
	NSDictionary* reg = nil;
	if (appID)
		reg = [s registrationForApplicationWithIdentifier:appID];
	else 
		reg = [s applicationRegistrationForSendingItems:items forAction:action];
	
	if (!reg)
		return kILSwapSendError;
	
	BOOL needsAsync = NO;
	
	BOOL handlesOnlyOne = ![L0As(NSNumber, [reg objectForKey:kILAppSupportsReceivingMultipleItems]) boolValue];
		
	NSMutableArray* pbItems = [NSMutableArray array], * dataSourceItems = [NSMutableArray array];
	for (ILSwapItem* item in items) {
		if ([item.value conformsToProtocol:@protocol(ILSwapDataSource)]) {
			needsAsync = YES;
			[dataSourceItems addObject:item];
		} else {
		
			NSDictionary* d = [item pasteboardItem];
			
			if (!d) {
				[NSException raise:@"ILSwapServiceCannotSendObject" format:@"Could not extract a value from object: %@", item];
				return NO;
			}
			
			[pbItems addObject:d];
		}
		
		if (handlesOnlyOne)
			break;
	}
	
	if (!needsAsync) {
	
		UIPasteboard* pb = [UIPasteboard pasteboardWithUniqueName];
		pb.persistent = YES;
		pb.items = pbItems;
	
		NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
							   pb.name, kILSwapServicePasteboardNameKey,
							   action, kILSwapServiceActionKey,
							   nil];
		
		[s managePasteboard:pb withLifetimePeriod:kILSwapPasteboardThisSessionOnly];
		
		BOOL done = [s sendRequestWithAttributes:attrs toApplicationWithRegistration:reg];
		if (!done)
			[UIPasteboard removePasteboardWithName:pb.name];
		return done? kILSwapSendDone : kILSwapSendError;	

	} else {
		
		registration = [reg copy];
		
		pasteboardItems = [pbItems copy];
		
		attributesByReader = [L0Map new];
		
		NSMutableSet* rs = [NSMutableSet set];
		for (ILSwapItem* item in dataSourceItems) {
			id <ILSwapDataSource> ds = (id <ILSwapDataSource>) item.value;
			id <ILSwapReader> r = [ds reader];

			[rs addObject:r];
			
			NSMutableDictionary* a = [[item.attributes mutableCopy] autorelease];
			if (!a)
				a = [NSMutableDictionary dictionary];
			
			[a setObject:item.type forKey:kILSwapLargeItemOriginalTypeAttribute];
			[attributesByReader setObject:a forKey:r];
		}
		
		readers = [rs copy];
		buffersByReader = [L0Map new];
		pasteboardListsByReader = [L0Map new];
		for (id <ILSwapReader> r in readers) {
			
			[buffersByReader setObject:[NSMutableData data] forKey:r];
			[pasteboardListsByReader setObject:[NSMutableArray array] forKey:r];
			
			r.delegate = self;
		}
		
		[readers makeObjectsPerformSelector:@selector(start)];
		return kILSwapSendOngoing;
		
	}
	
}

- (void) endSending;
{
	for (id <ILSwapReader> r in readers) {
		r.delegate = nil;
		[r stop];		
	}
	
	[readers release]; readers = nil;
	[buffersByReader release]; buffersByReader = nil;
	[pasteboardListsByReader release]; pasteboardListsByReader = nil;
	[attributesByReader release]; attributesByReader = nil;
	[pasteboardItems release]; pasteboardItems = nil;
	[registration release]; registration = nil;
}

- (void) reader:(id <ILSwapReader>) r didReceiveData:(NSData*) d;
{
	NSAutoreleasePool* pool = [NSAutoreleasePool new];
	{
		NSMutableData* currentBuffer = [buffersByReader objectForKey:r];
		[currentBuffer appendData:d];
		
		if ([currentBuffer length] >= kILSwapPasteboardSenderFragmentSize) {
			[self commitPasteboardForReader:r];
			[buffersByReader setObject:[NSMutableData data] forKey:r];
		}
	}
	[pool release];
}

- (void) commitPasteboardForReader:(id <ILSwapReader>) r;
{
	NSMutableData* currentBuffer = [buffersByReader objectForKey:r];
	if ([currentBuffer length] != 0) {

		NSString* pbName;
		
		NSAutoreleasePool* pool = [NSAutoreleasePool new];
		{
			UIPasteboard* pb = [UIPasteboard pasteboardWithUniqueName];
			pbName = [pb.name copy];
			pb.persistent = YES;
			pb.items = [NSDictionary dictionaryWithObject:currentBuffer forKey:kILSwapFragmentPasteboardType];
			[[ILSwapService sharedService] managePasteboard:pb withLifetimePeriod:kILSwapPasteboardThisSessionOnly];
		}
		[pool release];
		
		NSMutableArray* pbList = [pasteboardListsByReader objectForKey:r];
		[pbList addObject:pbName];
		[pbName release];
		
	}
}

- (void) readerDidEnd:(id <ILSwapReader>) r;
{
	NSAutoreleasePool* pool = [NSAutoreleasePool new];
	{
		[self commitPasteboardForReader:r];
		[buffersByReader removeObjectForKey:r];
	}
	[pool release];
	
	finishedReaders++;
	if (finishedReaders == [readers count]) {
		
		ILSwapService* s = [ILSwapService sharedService];
		
		UIPasteboard* pb = [UIPasteboard pasteboardWithUniqueName];
		pb.persistent = YES;
		
		NSMutableArray* pbItems = [[pasteboardItems copy] autorelease];
		
		for (id <ILSwapReader> r in readers) {
			NSMutableDictionary* item = [NSMutableDictionary dictionary], * a = [attributesByReader objectForKey:r];

			[item setObject:a forKey:kILSwapItemAttributesUTI];
			[item setObject:[pasteboardListsByReader objectForKey:r] forKey:kILSwapFragmentListPasteboardType];
			
			[pbItems addObject:item];
		}
		
		pb.items = pbItems;
		
		NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
							   pb.name, kILSwapServicePasteboardNameKey,
							   action, kILSwapServiceActionKey,
							   nil];
		
		[s managePasteboard:pb withLifetimePeriod:kILSwapPasteboardThisSessionOnly];
		
		BOOL done = [s sendRequestWithAttributes:attrs toApplicationWithRegistration:registration];
		if (!done)
			[UIPasteboard removePasteboardWithName:pb.name];
		[s sendingFinishedWithResult:(done? kILSwapSendDone : kILSwapSendError)];
		
		[self endSending];
	}
}

- (void) reader:(id <ILSwapReader>) r didEncounterError:(NSError*) e;
{
	for (NSMutableArray* pbNames in [pasteboardListsByReader allValues]) {
		for (NSString* pbName in pbNames)
			[UIPasteboard removePasteboardWithName:pbName];
	}
	[self endSending];
	[[ILSwapService sharedService] sendingFinishedWithResult:kILSwapSendError];
}

@end

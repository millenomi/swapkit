//
//  ILSwapResponse.m
//  SwapKit
//
//  Created by ∞ on 03/01/10.
//  Copyright 2010 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import "ILSwapRequest.h"
#import "ILSwapRequest_Private.h"

#import "ILSwapService.h"
#import "ILSwapItem.h"
#import "ILSwapItem_Private.h"

#import "ILSwapPasteboardSender.h"
#import "ILSwapLargeItemSupport.h"


@interface ILSwapPasteboardFragmentsDataSource : NSObject <ILSwapDataSource>
{
	NSArray* fragments;
}

- (id) initWithFragmentList:(NSArray*) f;

@end

@interface ILSwapPasteboardFragmentsReader : NSObject <ILSwapReader>
{
	NSArray* fragments;
	NSInteger current;
	id <ILSwapReaderDelegate> delegate;
}

- (id) initWithFragmentList:(NSArray*) f;
- (void) scheduleNextFragmentRead;

@end


@implementation ILSwapPasteboardFragmentsDataSource

- (id) initWithFragmentList:(NSArray*) f;
{
	if (self = [super init])
		fragments = [f copy];
	
	return self;
}

- (void) dealloc
{
	for (NSString* name in fragments)
		[UIPasteboard removePasteboardWithName:name];
	
	[fragments release];
	[super dealloc];
}

- (id <ILSwapReader>) reader;
{
	return [[[ILSwapPasteboardFragmentsReader alloc] initWithFragmentList:fragments] autorelease];
}

@end

@implementation ILSwapPasteboardFragmentsReader

- (id) initWithFragmentList:(NSArray*) f;
{
	if (self = [super init]) {
		fragments = [f copy];
		current = -1;
	}
	
	return self;
}

- (void) dealloc
{
	[fragments release];
	[super dealloc];
}


@synthesize delegate;

- (BOOL) isRunning;
{
	return current >= 0;
}

- (void) start;
{
	NSAssert(current < 0, @"Can't call -start on a running reader!");
	current = 0;
	
	if ([delegate respondsToSelector:@selector(readerWillStart:)])
		[delegate readerWillStart:self];
	
	[self scheduleNextFragmentRead];
}

- (void) stop;
{
	[[NSRunLoop currentRunLoop] cancelPerformSelector:@selector(readNextFragment) target:self argument:nil];
	current = -1;
}

- (void) scheduleNextFragmentRead;
{
	[[NSRunLoop currentRunLoop] performSelector:@selector(readNextFragment) target:self argument:nil order:0 modes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
}

- (void) readNextFragment;
{
	if (current >= [fragments count]) {
		current = -1;
		if ([delegate respondsToSelector:@selector(readerDidEnd:)])
			[delegate readerDidEnd:self];
		return;
	}
	
	BOOL dieWithError = NO;
	
	NSAutoreleasePool* pool = [NSAutoreleasePool new];
	{
		UIPasteboard* pb = [UIPasteboard pasteboardWithName:[fragments objectAtIndex:current] create:YES];
		NSData* d = [pb dataForPasteboardType:kILSwapFragmentPasteboardType];
		
		if (!d)
			dieWithError = YES;
		else
			[delegate reader:self didReceiveData:d];
	}
	[pool release];
	
	if (dieWithError) {
		if ([delegate respondsToSelector:@selector(reader:didEncounterError:)]) {
			// TODO better error
			[delegate reader:self didEncounterError:[NSError errorWithDomain:NSPOSIXErrorDomain code:EINVAL userInfo:nil]];
		}
		
		current = -1;
		
		if ([delegate respondsToSelector:@selector(readerDidEnd:)])
			[delegate readerDidEnd:self];
	} else
		[self scheduleNextFragmentRead];
}

@end




static id ILSwapItemValueFromPasteboardValue(NSString* uti, id value) {
	if (![uti isEqual:kILSwapFragmentListPasteboardType])
		return value;
	else {
		
		if ([value isKindOfClass:[NSData class]]) {
			
			NSPropertyListFormat format;
			NSString* error = nil;
			
			id m = [NSPropertyListSerialization propertyListFromData:value mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&error];
			if (!m && error) {
				NSLog(@"<SwapKit> An error occurred while deserializing item attributes from the pasteboard: %@", error);
				[error release];
			}
			
			value = m;
			
		}
		
		if (value && [value isKindOfClass:[NSArray class]])
			return [[[ILSwapPasteboardFragmentsDataSource alloc] initWithFragmentList:value] autorelease];
		else
			return nil;
	}
}


@interface ILSwapRequest ()

@end


@implementation ILSwapRequest

- (id) initWithPasteboard:(UIPasteboard*) p attributes:(NSDictionary*) a removePasteboardWhenDone:(BOOL) r;
{
	if (!(self = [super init]))
		return nil;
	
	pb = [p retain];
	remove = r;
	
	attributes = [a copy];
	
	return self;
}

@synthesize attributes;

- (void) dealloc
{
	if (remove)
		[UIPasteboard removePasteboardWithName:pb.name];
	[pb release];

	[attributes release];

	[super dealloc];
}

- (NSString*) action;
{
	return L0As(NSString, [attributes objectForKey:kILSwapServiceActionKey]);
}

#pragma mark Items management

- (ILSwapItem*) item;
{
	if (pb.numberOfItems != 1)
		return nil;
	
	NSString* uti; // take the first UTI off the item.
	for (NSString* u in [pb pasteboardTypes]) {
		if ([u isEqual:kILSwapItemAttributesUTI])
			continue;
		
		uti = u; break;
	}
	
	if (!uti)
		return nil;
	
	id d = ILSwapItemValueFromPasteboardValue(uti, [pb valueForPasteboardType:uti]);
	id m = [pb valueForPasteboardType:kILSwapItemAttributesUTI];
	
	return !d? nil: [ILSwapItem itemWithValue:d type:uti attributes:[ILSwapItem attributesFromPasteboardValue:m]];
}



- (NSUInteger) countOfItems;
{
	return [self.items count];
}

- (NSArray*) items;
{
	if (!items) {
		NSMutableArray* a = [NSMutableArray array];

		for (NSDictionary* item in pb.items) {
			NSString* uti; // take the first UTI off the item.
			for (NSString* u in item) {
				if ([u isEqual:kILSwapItemAttributesUTI])
					continue;
				
				uti = u; break;
			}
			
			if (!uti)
				continue; // the item is missing, well, the item value :)
			
			id d = ILSwapItemValueFromPasteboardValue(uti, [item objectForKey:uti]);
			id m = [item objectForKey:kILSwapItemAttributesUTI];
			
			if (!d || ![ILSwapItem canUseAsItemValue:d])
				continue;
			
			[a addObject:
			 [ILSwapItem itemWithValue:d type:uti attributes:[ILSwapItem attributesFromPasteboardValue:m]]
			 ];
		}
		
		items = [a copy];
	}
	
	return items;
}

@end

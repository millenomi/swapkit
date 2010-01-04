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

	[type release];
	[attributes release];

	[super dealloc];
}

- (NSString*) action;
{
	return L0As(NSString, [attributes objectForKey:kILSwapServiceActionKey]);
}

#pragma mark Items management

- (NSString*) type;
{
	if (!type) {
		NSMutableArray* a = [NSMutableArray arrayWithArray:pb.pasteboardTypes];
		[a removeObject:kILSwapItemAttributesUTI];
		type = [a count] != 0? [[a objectAtIndex:0] copy] : nil;
	}
	
	return type;
}

- (ILSwapItem*) item;
{
	if (pb.numberOfItems == 0)
		return nil;
	
	if (!self.type)
		return nil;
	
	NSData* d = [pb dataForPasteboardType:self.type];
	NSData* m = [pb dataForPasteboardType:kILSwapItemAttributesUTI];
	
	return [ILSwapItem itemWithContentData:d attributes:[ILSwapItem attributesFromDataOrNil:m]];
}

- (NSUInteger) countOfItems;
{
	return [[pb itemSetWithPasteboardTypes:[NSArray arrayWithObject:self.type]] count];
}

- (NSArray*) items;
{
	if (!items) {
		NSMutableArray* a = [NSMutableArray array];
		
		NSIndexSet* s = [pb itemSetWithPasteboardTypes:[NSArray arrayWithObject:self.type]];
		NSArray* dataArray = [pb dataForPasteboardType:self.type inItemSet:s];
		NSArray* metaArray = [pb dataForPasteboardType:kILSwapItemAttributesUTI inItemSet:s];
		NSUInteger i = 0;
		for (id d in dataArray) {
			if (![d isKindOfClass:[NSData class]])
				continue;
			
			id m = L0As(NSData, [metaArray objectAtIndex:i]);
			
			[a addObject:
			 [ILSwapItem itemWithContentData:d attributes:[ILSwapItem attributesFromDataOrNil:m]]
			 ];
			i++;
		}
		
		items = [a copy];
	}
	
	return items;
}

@end

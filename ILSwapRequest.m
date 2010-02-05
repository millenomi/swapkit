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
	
	NSData* d = [pb valueForPasteboardType:self.type];
	NSData* m = [pb valueForPasteboardType:kILSwapItemAttributesUTI];
	
	return [ILSwapItem itemWithValue:d attributes:[ILSwapItem attributesFromPasteboardValue:m]];
}

- (NSUInteger) countOfItems;
{
	return [self.items count];
}

- (NSArray*) items;
{
	if (!items) {
		NSMutableArray* a = [NSMutableArray array];
		NSString* uti = self.type;

		for (NSDictionary* item in pb.items) {
			id d = [item objectForKey:uti];
			id m = [item objectForKey:kILSwapItemAttributesUTI];
			
			if (!d || ![ILSwapItem canUseAsItemValue:d])
				continue;
			
			[a addObject:
			 [ILSwapItem itemWithValue:d attributes:[ILSwapItem attributesFromPasteboardValue:m]]
			 ];
		}
		
		items = [a copy];
	}
	
	return items;
}

@end

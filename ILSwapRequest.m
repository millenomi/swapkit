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
	
	NSData* d = [pb valueForPasteboardType:uti];
	NSData* m = [pb valueForPasteboardType:kILSwapItemAttributesUTI];
	
	return [ILSwapItem itemWithValue:d type:uti attributes:[ILSwapItem attributesFromPasteboardValue:m]];
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
			
			id d = [item objectForKey:uti];
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

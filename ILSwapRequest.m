//
//  ILSwapResponse.m
//  SwapKit
//
//  Created by ∞ on 03/01/10.
//  Copyright 2010 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import "ILSwapRequest.h"
#import "ILSwapService.h"

@interface ILSwapRequest ()

- (NSArray*) contentsForItemsOfType:(id) type selector:(SEL) sel expectedClass:(Class) c;

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

- (NSArray*) availableTypes;
{
	return [pb pasteboardTypes];
}


- (NSData*) dataForType:(id) type;
{
	return [pb.pasteboardTypes containsObject:type]? [pb dataForPasteboardType:type] : nil;
}

- (id) valueForType:(id) type;
{
	return [pb.pasteboardTypes containsObject:type]? [pb valueForPasteboardType:type] : nil;
}

- (id) valueForType:(id) type expectedClass:(Class) c;
{
	return L0AsClass(c, [self valueForType:type]);
}


- (NSUInteger) numberOfItemsOfType:(id) type;
{
	NSIndexSet* s = [pb itemSetWithPasteboardTypes:[NSArray arrayWithObject:type]];
	return [s count];
}

- (NSArray*) dataForItemsOfType:(id) type;
{
	return [self contentsForItemsOfType:type selector:@selector(dataForPasteboardType:inItemSet:) expectedClass:[NSData class]];
}

- (NSArray*) valuesForItemsOfType:(id) type expectedClass:(Class) c;
{
	return [self contentsForItemsOfType:type selector:@selector(valuesForPasteboardType:inItemSet:) expectedClass:c];
}

- (NSArray*) valuesForItemsOfType:(id) type;
{
	return [self valuesForItemsOfType:type expectedClass:Nil];
}

- (NSArray*) contentsForItemsOfType:(id) type selector:(SEL) sel expectedClass:(Class) cls;
{
	NSIndexSet* s = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, pb.numberOfItems)];
	NSMutableArray* a = [NSMutableArray array];
	for (id x in [pb performSelector:sel withObject:type withObject:s]) {
		if (!cls || [x isKindOfClass:[NSData class]])
			[a addObject:x];
	}
	
	return a;	
}

- (NSString*) action;
{
	return L0As(NSString, [attributes objectForKey:kILSwapServiceActionKey]);
}

@end

//
//  ILSwapItem.m
//  SwapKit
//
//  Created by ∞ on 04/01/10.
//  Copyright 2010 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import "ILSwapItem.h"
#import "ILSwapItem_Private.h"

@interface ILSwapItem ()

// not the designated initializer, and actually private to this class.
// subclasses use -init as the designated init.
- (id) initWithContentData:(NSData*) d attributes:(NSDictionary*) m;

@end


@implementation ILSwapItem

- (id) initWithContentData:(NSData*) d attributes:(NSDictionary*) m;
{
	if (!(self = [super init]))
		return nil;
	
	contentData = [d copy];
	attributes = [m copy];
	
	return self;
}

+ itemWithContentData:(NSData*) data attributes:(NSDictionary*) dictionary;
{
	return [[[self alloc] initWithContentData:data attributes:dictionary] autorelease];
}

- (id) copyWithZone:(NSZone *)zone;
{
	return [[[ILSwapItem allocWithZone:zone] initWithContentData:self.contentData attributes:self.attributes] autorelease];
}

- (id)mutableCopyWithZone:(NSZone *)zone;
{
	return [[[ILSwapMutableItem allocWithZone:zone] initWithContentData:self.contentData attributes:self.attributes] autorelease];
}

@synthesize contentData, attributes;

- (void) dealloc
{
	[contentData release];
	[attributes release];
	
	[super dealloc];
}


@end

@implementation ILSwapMutableItem

@synthesize contentData, attributes;

+ item;
{
	return [[self new] autorelease];
}

// Silences the compiler.

- (id) init;
{
	return [super init];
}

@end


@implementation ILSwapItem (ILSwapItemPasteboard)

- (NSDictionary*) pasteboardItemOfType:(NSString*) type;
{
	if (!self.contentData)
		return nil;
	
	NSMutableDictionary* d = [NSMutableDictionary dictionaryWithObject:self.contentData forKey:type];
	if (self.attributes && [self.attributes count] > 0)
		[d setObject:self.attributes forKey:kILSwapItemAttributesUTI];
	
	return d;
}

+ (NSDictionary*) attributesFromDataOrNil:(NSData*) d;
{
	NSPropertyListFormat format;
	NSString* error = nil;
	
	id m = [NSPropertyListSerialization propertyListFromData:d mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&error];
	if (!m && error) {
		NSLog(@"<SwapKit> An error occurred while deserializing item attributes from the pasteboard: %@", error);
		[error release];
	}
	
	return L0As(NSDictionary, m);
}

@end


@implementation ILSwapItem (ILSwapItemCommonTypesAccess)

- (id) propertyList;
{
	NSPropertyListFormat format;
	NSString* error = nil;

	id m = [NSPropertyListSerialization propertyListFromData:self.contentData mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&error];
	if (!m && error) {
		NSLog(@"<SwapKit> An error occurred while deserializing item content as a property list: %@", error);
		[error release];
	}
	
	return m;
}

- (NSString*) string;
{
	return [[[NSString alloc] initWithData:self.contentData encoding:NSUTF8StringEncoding] autorelease];
}

- (UIImage*) image;
{
	return [UIImage imageWithData:self.contentData];
}

@end

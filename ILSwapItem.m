//
//  ILSwapItem.m
//  SwapKit
//
//  Created by ∞ on 04/01/10.
//  Copyright 2010 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import "ILSwapItem.h"
#import "ILSwapItem_Private.h"

#import <MobileCoreServices/MobileCoreServices.h>

#define L0Keep(object) ([object conformsToProtocol:@protocol(NSCopying)]? [object copy] : [object retain])

@interface ILSwapItem ()

- (void) privatelySetValue:(id) value;
- (void) privatelySetAttributes:(NSDictionary*) a;
- (void) privatelySetType:(NSString*) type;

+ (BOOL) canBeInitializedWithNilItem;

@end

static BOOL ILSwapIsPropertyListObject(id v) {
	return CFPropertyListIsValid((CFPropertyListRef)v, kCFPropertyListBinaryFormat_v1_0);
}

@implementation ILSwapItem

+ (BOOL) canUseAsItemValue:(id) v;
{
	return [v isKindOfClass:[NSData class]] ||
		[v isKindOfClass:[NSString class]] ||
		(([v isKindOfClass:[NSArray class]] || [v isKindOfClass:[NSDictionary class]]) &&ILSwapIsPropertyListObject(v)) ||
		[v isKindOfClass:[UIImage class]];
}

+ (BOOL) canBeInitializedWithNilItem;
{
	return NO;
}

- (id) initWithValue:(id) v type:(NSString*) t attributes:(NSDictionary*) a;
{
	if (!(self = [super init]))
		return nil;
	
	value = L0Keep(v);
	if (!value && ![[self class] canBeInitializedWithNilItem]) {
		[self release];
		return nil;
	}
	
	type = [t copy];
	if (!type && ![[self class] canBeInitializedWithNilItem]) {
		[self release];
		return nil;
	}
	
	attributes = [a copy];
	
	return self;
}

+ itemWithValue:(id) v type:(NSString*) t attributes:(NSDictionary*) a;
{
	return [[[self alloc] initWithValue:v type:t attributes:a] autorelease];
}

- (id) copyWithZone:(NSZone *)zone;
{
	return [[ILSwapItem allocWithZone:zone] initWithValue:self.value type:self.type attributes:self.attributes];
}

- (id) mutableCopyWithZone:(NSZone *)zone;
{
	return [[ILSwapMutableItem allocWithZone:zone] initWithValue:self.value type:self.type attributes:self.attributes];
}

- (BOOL) typeConformsTo:(id) t;
{
	if (!self.type)
		return NO;
	
	return [t isEqual:self.type] || UTTypeConformsTo((CFStringRef) self.type, (CFStringRef) t);
}

@synthesize value, type, attributes;

- (void) dealloc
{
	[value release];
	[attributes release];
	
	[super dealloc];
}

- (void) privatelySetValue:(id) v;
{
	if (v != value) {
		[value release];
		value = L0Keep(v);
	}
}

- (void) privatelySetType:(id) t;
{
	if (t != type) {
		[type release];
		type = [t copy];
	}
}

- (void) privatelySetAttributes:(NSDictionary*) a;
{
	if (a != attributes) {
		[attributes release];
		attributes = [a copy];
	}
}

@end

@implementation ILSwapMutableItem

+ (BOOL) canBeInitializedWithNilItem;
{
	return YES;
}


+ item;
{
	return [[[self alloc] initWithValue:nil type:nil attributes:nil] autorelease];
}

// Silences the compiler.

- (id) init;
{
	return [super init];
}

- (NSString*) type;
{
	return [super type];
}

- (id) value;
{
	return [super value];
}

- (NSDictionary*) attributes;
{
	return [super attributes];
}

- (void) setType:(NSString*) t;
{
	[super privatelySetType:t];
}

- (void) setValue:(id) v;
{
	[super privatelySetValue:v];
}

- (void) setAttributes:(NSDictionary *) a;
{
	[super privatelySetAttributes:a];
}

@end


@implementation ILSwapItem (ILSwapItemPasteboard)

- (NSDictionary*) pasteboardItem;
{
	if (!self.value)
		return nil;
	
	NSMutableDictionary* d = [NSMutableDictionary dictionaryWithObject:self.value forKey:self.type];
	if (self.attributes && [self.attributes count] > 0)
		[d setObject:self.attributes forKey:kILSwapItemAttributesUTI];
	
	return d;
}

+ (NSDictionary*) attributesFromPasteboardValue:(id) d;
{
	if (!d)
		return nil;

	if ([d isKindOfClass:[NSDictionary class]])
		return d;
	
	if ([d isKindOfClass:[NSData class]]) {
	
		NSPropertyListFormat format;
		NSString* error = nil;
		
		id m = [NSPropertyListSerialization propertyListFromData:d mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&error];
		if (!m && error) {
			NSLog(@"<SwapKit> An error occurred while deserializing item attributes from the pasteboard: %@", error);
			[error release];
		}
		
		return L0As(NSDictionary, m);
		
	}
	
	return nil;
}

@end


@implementation ILSwapItem (ILSwapItemCommonTypesAccess)

- (id) propertyListValue;
{
	id v = self.value;
	
	if ([v isKindOfClass:[NSDictionary class]] ||
		[v isKindOfClass:[NSArray class]] ||
		[v isKindOfClass:[NSString class]] ||
		[v isKindOfClass:[NSDate class]] ||
		[v isKindOfClass:[NSNumber class]])
		return v;
	
	if ([v isKindOfClass:[NSData class]]) {	
		NSPropertyListFormat format;
		NSString* error = nil;

		id m = [NSPropertyListSerialization propertyListFromData:v mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&error];
		if (!m && error) {
			NSLog(@"<SwapKit> An error occurred while deserializing item content as a property list: %@", error);
			[error release];
		}
		
		return m;
	}
	
	return nil;
}

- (NSString*) stringValue;
{
	id v = self.value;
	if ([v isKindOfClass:[NSString class]])
		return v;
	else if ([v isKindOfClass:[NSData class]])
		return [[[NSString alloc] initWithData:v encoding:NSUTF8StringEncoding] autorelease];
	else
		return nil;
}

- (UIImage*) imageValue;
{
	id v = self.value;
	if ([v isKindOfClass:[UIImage class]])
		return v;
	else if ([v isKindOfClass:[NSData class]])
		return [UIImage imageWithData:v];
	else
		return nil;
}

- (NSData*) dataValue;
{
	id v = self.value;
	if ([v isKindOfClass:[NSString class]])
		return [v dataUsingEncoding:NSUTF8StringEncoding];
	return L0As(NSData, v);
}

@end

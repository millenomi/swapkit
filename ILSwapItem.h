//
//  ILSwapItem.h
//  SwapKit
//
//  Created by ∞ on 04/01/10.
//  Copyright 2010 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ILSwapItem : NSObject <NSCopying, NSMutableCopying> {
@protected
	id <NSObject, NSCopying> value;
	NSDictionary* attributes;
}

// Warning: no public constructors.
// Use -[ILSwapItem copy] on a ILSwapMutableItem to create an immutable copy.

@property(copy, readonly) id value;
@property(copy, readonly) NSDictionary* attributes; // may contain any property list type.

// not the designated initializer.
// subclasses use -init instead.
- (id) initWithValue:(id) v attributes:(NSDictionary*) a;
+ itemWithValue:(id) v attributes:(NSDictionary*) a;

@end

@interface ILSwapMutableItem : ILSwapItem {}

@property(copy) NSDictionary* attributes;

- (id) init;
+ item;

@end


@interface ILSwapItem (ILSwapItemCommonTypesAccess)

@property(readonly) id propertyListValue;
@property(readonly) NSString* stringValue; // requires item to have been sent as kUTTypeUTF8PlainText.
@property(readonly) UIImage* imageValue;
@property(readonly) NSData* dataValue;

@end

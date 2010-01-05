//
//  ILSwapItem.h
//  SwapKit
//
//  Created by ∞ on 04/01/10.
//  Copyright 2010 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import <Foundation/Foundation.h>

/** \addtogroup ILSwapKitItems Items and data accessors. */

/**
 \ingroup ILSwapKitItems
 An item is a basic "transfer unit" handled by SwapKit. A request you make will include one or more items (see ILSwapService#sendItems:ofType:forAction:toApplicationWithIdentifier:), and the receiving application will be given a ILSwapRequest object containing one or more ILSwapItem instances.
 
 ILSwapItem is a concrete class that allows access to an (immutable) #value object and to metadata (#attributes) of the object provided by the sending application. You can produce a ILSwapItem via its constructors, or use the ILSwapMutableItem subclass to produce a mutable item you can modify at will before sending it. You do not produce items for incoming requests, instead, you access them through a provided request's ILSwapRequest#item or ILSwapRequest#items properties, as appropriate.
 
 The #value object in a ILSwapitem can be any of the following:
 
 * A NSData object containing arbitrary data for the item; or
 * A NSString, containing textual data; or
 * a NSArray or NSDictionary containing property lists objects; or
 
 You don't usually access the #value directly. Instead, you use one of the #propertyListValue, #stringValue, #imageValue, #dataValue and other accessor methods to specify how you want to access the data. (These methods will recognize and automatically convert the #value for you if inappropriate -- for example, if the #value is a NSData object containing a serialized property list, the #propertyListValue method will deserialize it for you.) It's up to you to know what accessor to use for the particular ILSwapRequest#type involved.
 
 */
@interface ILSwapItem : NSObject <NSCopying, NSMutableCopying> {
@protected
	id <NSObject, NSCopying> value;
	NSDictionary* attributes;
}

/**
 The value for this item. It can be a NSData, NSString, NSArray (property list), NSDictionary (property list) object. Never nil (unless the item is mutable; but see ILSwapMutableItem for more information -- basically, if a method can take an immutable item, it's a violation of its contract to pass a mutable item with a nil value).
 */
@property(copy, readonly) id value;

/**
 The attributes for this item. It can be nil, or, if non-nil, it's a NSDictionary instance containing only property list objects. This dictionary, if present, contains additional metadata for the item.
 
 @see ILSwapKitCommonItemAttributeKeys
 */
@property(copy, readonly) NSDictionary* attributes; // may contain any property list type.

/**
 Creates a new item with the given value and attributes.
 
 @param v A valid value for this item. See #value for details.
 @param a Metadata attributes for this item. Can be nil; if it's not, it must only contain property list objects.
 */
- (id) initWithValue:(id) v attributes:(NSDictionary*) a;

/**
 Convenience method for #initWithValue:attributes:.
 */
+ itemWithValue:(id) v attributes:(NSDictionary*) a;

@end

/**
 \ingroup ILSwapKitItems

 A mutable item is similar to an item, but it allows modifications to its properties. You can use the <code>copy</code> method of NSObject to produce an immutable ILSwapItem copy, and ILSwapItem can produce a <code>mutableCopy</code> that responds to the messages of this class.
 
 Please note that while a mutable item with a nil #value can exist, an immutable item with a nil #value must not. Trying to produce an immutable item from such a mutable item has, in current releases of SwapKit, produces an undefined behavior.
 
 @see ILSwapItem
 */
@interface ILSwapMutableItem : ILSwapItem {}

/**
 The value for this item. Can be modified. Can be nil, but it must be non-nil if you want to pass this object to anything that can also take an immutable ILSwapItem. The type of anything set through this property must be a valid value object as per ILSwapItem#value.
 */
@property(copy) id value;

/**
 The attributes for this item. Can be modified.
 @see ILSwapItem#attributes
 */
@property(copy) NSDictionary* attributes;

/**
 The designated initializer. Produces a mutable item with nil #value and #attributes properties.
 */
- (id) init;

/** Convenience method for #init */
+ item;

@end

/**
 \ingroup ILSwapKitItems

 This category contains useful value accessors for items.
 */
@interface ILSwapItem (ILSwapItemCommonTypesAccess)

/**
 Returns a property list. This will happen only if the ILSwapItem#value is a property list top-level object or a NSData that deserializes into a property list, or nil will be returned otherwise.
 */
@property(readonly) id propertyListValue;

/**
 Returns a string. This will happen only if the ILSwapItem#value is a NSString or a NSData object containing UTF-8 encoded text, or nil will be returned otherwise.
 */
@property(readonly) NSString* stringValue; // assumes the type is kUTTypeUTF8PlainText.

/**
 Returns an image. This will happen only if the ILSwapItem#value is a NSData object containing valid image data that UIKit can detect, or nil will be returned otherwise.
 */
@property(readonly) UIImage* imageValue;

/**
 Returns a NSData value. This will happen only if the ILSwapItem#value is a NSData object, or if it's a NSString, in which case the UTF-8 encoding of the ILSwapItem#value will be returned. nil will be returned otherwise.
 */
@property(readonly) NSData* dataValue;

@end

//
//  ILSwapItem.h
//  SwapKit
//
//  Created by ∞ on 04/01/10.
//  Copyright 2010 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import <Foundation/Foundation.h>

/** \addtogroup ILSwapKitItems Items and data accessors.
 @{
 */

/**
 The key in an item's attributes dictionary reserved for the title of the item (a NSString). The title should be a concise description of the item, similar to a file name; however, it's not a file name (and as such it shouldn't contain an extension).
 */
#define kILSwapItemTitleAttribute @"ILSwapItemTitle"

/**
 The key in an item's attributes dictionary reserved for a description of the item (a NSString). A description is a short excerpt or summary of the contents of the item, and it should not exceed a length of 200 characters. This can be used by application as a textual preview of the object.
 */
#define kILSwapItemDescriptionAttribute @"ILSwapItemDescription"

/**
 The key in an item's attributes dictionary reserved for the item's icon, if any (a NSData object). The value should be image data encoded with any format UIKit can detect (usually PNG or JPEG), should be square, not exceed the size of 96 by 96 pixels, and should look nice over any backdrop (especially light or white backdrops). Final image size should be valued over image detail.
 
 This icon should be used by applications whenever they want to represent the item with a thumbnail that is larger than 44x44 (such as in a image picker-like list of images, or *ahem* a table of user-manipulable slides). If this icon is absent but @ref kILSwapItemIcon29Attribute is set, the app should NOT scale up the small icon; it should instead adopt a default icon, inspect the item contents, or center the small icon to produce the final representation.
 */
#define kILSwapItemIcon96Attribute @"ILSwapItemIcon96"

/**
 The key in an item's attributes dictionary reserved for the item's small icon, if any (a NSData object). The value should be image data encoded with any format UIKit can detect (usually PNG or JPEG), should be square, not exceed the size of 29 by 29 pixels, and should look nice over any backdrop (especially light or white backdrops such as default table view cells). Final image size should be valued over image detail.
 
 This icon should be used by application whenever they want to represent the item in a UITableView or in a similar context where screen space is at a premium. If this icon is absent but @ref kILSwapItemIcon96Attribute is set, apps may choose to scale down that image to produce a final icon.
 */
#define kILSwapItemIcon29Attribute @"ILSwapItemIcon29"

/**
 The key in an item's attributes dictionary reserved for the item's original file name (a NSString). This allows applications that deal with files to name the item correctly in such contexts. If the item comes from a file and the file name is meaningful (because it was, for example, chosen by the user or transferred from another outlet where file names are meaningful such as a remote computer), then it should be included verbatim.
 
 If this attribute is present and has an extension, the app should use this extension when producing a file name for the item, favoring it over any other extension produced by the OS unless this would be undesirable for other reasons (eg. security). If this attribute is absent, the application should use the @ref kILSwapItemTitleAttribute and the information about the request's type (ILSwapRequest#type) to produce a file name, if needed.
 */
#define kILSwapItemOriginalFileNameAttribute @"ILSwapItemOriginalFileName"

/** @} */

/**
 \ingroup ILSwapKitItems
 An item is a basic "transfer unit" handled by SwapKit. A request you make will include one or more items (see ILSwapService#sendItems:ofType:forAction:toApplicationWithIdentifier:), and the receiving application will be given a ILSwapRequest object containing one or more ILSwapItem instances.
 
 ILSwapItem is a concrete class that allows access to an (immutable) #value object and to metadata (#attributes) of the object provided by the sending application. You can produce a ILSwapItem via its constructors, or use the ILSwapMutableItem subclass to produce a mutable item you can modify at will before sending it. You do not produce items for incoming requests, instead, you access them through a provided request's ILSwapRequest#item or ILSwapRequest#items properties, as appropriate.
 
 The #value object in a ILSwapitem can be any of the following:
 
 * A NSData object containing arbitrary data for the item; or
 * A NSString, containing textual data; or
 * a NSArray or NSDictionary containing property lists objects; or
 * a UIImage.
 
 You don't usually access the #value directly. Instead, you use one of the #propertyListValue, #stringValue, #imageValue, #dataValue and other accessor methods to specify how you want to access the data. (These methods will recognize and automatically convert the #value for you if inappropriate -- for example, if the #value is a NSData object containing a serialized property list, the #propertyListValue method will deserialize it for you.) It's up to you to know what accessor to use for the particular ILSwapRequest#type involved.
 
 */
@interface ILSwapItem : NSObject <NSCopying, NSMutableCopying> {
@protected
	id value;
	NSDictionary* attributes;
}

/**
 Returns YES if the given object can be used as an item value, NO otherwise.
*/
+ (BOOL) canUseAsItemValue:(id) v;

/**
 The value for this item. It can be a NSData, NSString, NSArray (property list), NSDictionary (property list) object, or a UIImage. Never nil (unless the item is mutable; but see ILSwapMutableItem for more information -- basically, if a method can take an immutable item, it's a violation of its contract to pass a mutable item with a nil value).
 */
@property(copy, nonatomic, readonly) id value;

/**
 The attributes for this item. It can be nil, or, if non-nil, it's a NSDictionary instance containing only property list objects. This dictionary, if present, contains additional metadata for the item.
 
 @see ILSwapKitItems
 */
@property(copy, nonatomic, readonly) NSDictionary* attributes; // may contain any property list type.

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
 
 Please note that while a mutable item with a nil #value can exist, an immutable item with a nil #value must not. Trying to produce an immutable item from such a mutable item produces, in current releases of SwapKit, an undefined behavior.
 
 @see ILSwapItem
 */
@interface ILSwapMutableItem : ILSwapItem {}

/**
 The value for this item. Can be modified. Can be nil, but it must be non-nil if you want to pass this object to anything that can also take an immutable ILSwapItem. The type of anything set through this property must be a valid value object as per ILSwapItem#value.
 
 Please note: you CAN set a UIImage as the value. It will be treated correctly, but it will be retained rather than used as the basis for a new object. This should not affect the application, since UIImages are immutable.
 */
@property(copy, nonatomic) id value;

/**
 The attributes for this item. Can be modified.
 @see ILSwapItem#attributes
 */
@property(copy, nonatomic) NSDictionary* attributes;

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
 Returns an image. This will happen only if the ILSwapItem#value is a NSData object containing valid image data that UIKit can detect, or a UIImage itself; nil will be returned otherwise.
 */
@property(readonly) UIImage* imageValue;

/**
 Returns a NSData value. This will happen only if the ILSwapItem#value is a NSData object, or if it's a NSString, in which case the UTF-8 encoding of the ILSwapItem#value will be returned. nil will be returned otherwise.
 
 Please note: the data value may not be available if the value is a UIImage.
 */
@property(readonly) NSData* dataValue;

@end


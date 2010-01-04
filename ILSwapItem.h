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
	NSData* contentData;
	NSDictionary* attributes;
}

// Warning: no public constructors.
// Use -[ILSwapItem copy] on a ILSwapMutableItem to create an immutable copy.

@property(copy, readonly) NSData* contentData;
@property(copy, readonly) NSDictionary* attributes; // may contain any property list type.

@end

@interface ILSwapMutableItem : ILSwapItem {}

@property(copy) NSData* contentData;
@property(copy) NSDictionary* attributes;

- (id) init;
+ item;

- (id) initWithContentData:(NSData*) d attributes:(NSDictionary*) a;
+ itemWithContentData:(NSData*) d attributes:(NSDictionary*) a;

@end


// Private. DO NOT USE.
#if kILSwapItemAllowPrivateUse

#define kILSwapItemattributesUTI @"net.infinite-labs.SwapKit.Itemattributes"

@interface ILSwapItem (ILSwapItemPasteboard)

/** @internal */
- (NSDictionary*) pasteboardItemOfType:(NSString*) type;

/** @internal */
- (id) initWithPasteboardItem:(NSDictionary*) d ofType:(NSString*) type;

@end
#endif

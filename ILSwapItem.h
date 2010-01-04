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

- (id) initWithContentData:(NSData*) d attributes:(NSDictionary*) a;
+ itemWithContentData:(NSData*) d attributes:(NSDictionary*) a;

@end

@interface ILSwapMutableItem : ILSwapItem {}

@property(copy) NSData* contentData;
@property(copy) NSDictionary* attributes;

- (id) init;
+ item;

@end


@interface ILSwapItem (ILSwapItemCommonTypesAccess)

@property(readonly) id propertyList;
@property(readonly) NSString* string; // requires item to have been sent as kUTTypeUTF8PlainText.
@property(readonly) UIImage* image;

@end

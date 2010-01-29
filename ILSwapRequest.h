//
//  ILSwapResponse.h
//  SwapKit
//
//  Created by ∞ on 03/01/10.
//  Copyright 2010 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import <Foundation/Foundation.h>
@class ILSwapItem;

/**
 A request contains all information regarding a specific 'send' performed by another application. Requests that are sent through ILSwapService#sendItems:ofType:forAction:toApplicationWithIdentifier: and ILSwapSendController will both arrive in the form of a ILSwapRequest instance through ILSwapServiceDelegate#swapServiceDidReceiveRequest:; it's up to you to get the items from within the request and parse them for your own use.
 
 Requests do not have public constructors. Instead, you receive instances of this class as arguments to delegate classes. You can retain the requests and they will remain valid until deallocated, but a request "dies" in the same session it was received — it cannot be serialized.
 */
@interface ILSwapRequest : NSObject {
@private
	UIPasteboard* pb;
	NSString* type;
	BOOL remove;
	NSArray* items;

	NSDictionary* attributes;
}

// Responses have private constructors only. Sorry!

/**
 The type of data contained in this request. This is the same type that was passed to ILSwapService#sendItems:ofType:forAction:toApplicationWithIdentifier:.
 */
@property(readonly) NSString* type;

/**
 The single item contained in this request. If multiple items are in the request, then this will contain the first item only. (In case a malformed request arrives, with no items in it, this method will return nil.)
 */
@property(readonly) ILSwapItem* item;

/**
 The number of items contained in this request. Malformed requests with multiple items may arrive even if @ref kILAppSupportsReceivingMultipleItems is NO.
 */
@property(readonly) NSUInteger countOfItems;

/**
 The items contained in this request. Use of this property makes sense only if @ref kILAppSupportsReceivingMultipleItems is YES for your app.
 */
@property(readonly) NSArray* items;


/**
 Returns the attributes associated with this request. This is useful for custom requests, but you would usually use #action instead.
 
 @see ILSwapKitRequestAttributes
 */
@property(readonly) NSDictionary* attributes;

/**
 Returns the action that was used to produce this request. Note that SwapKit does some checking, but if the action is important you should still check it, as currently SwapKit does not give guarantees regarding the delivery of requests, and may deliver requests with incorrect actions (such as actions you did not register).
 */
@property(readonly) NSString* action;

@end

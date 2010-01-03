//
//  ILSwapResponse.h
//  SwapKit
//
//  Created by ∞ on 03/01/10.
//  Copyright 2010 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A request contains all information regarding a specific 'send' performed by another application. Requests that are sent through ILSwapService#sendItems:ofType:forAction:toApplicationWithIdentifier: and ILSwapSendingController will both arrive in the form of a ILSwapRequest instance through ILSwapServiceDelegate#swapServiceDidReceiveRequest:; it's up to you to get the items from within the request and parse them for your own use.
 
 Requests do not have public constructors. Instead, you receive instances of this class as arguments to delegate classes. You can retain the requests and they will remain valid until deallocated, but a request "dies" in the same session it was received — it cannot be serialized.
 */
@interface ILSwapRequest : NSObject {
@private
	UIPasteboard* pb;
	BOOL remove;

	NSDictionary* attributes;
}

// Responses have private constructors only. Sorry!

/** Contains all types associated to items sent with this request. Current versions of SwapKit support only a single type per request, so this array should usually contain no more than a single object, but future implementations may contain more than one. */
@property(readonly) NSArray* availableTypes;

/**
 Returns the number of items of the specified type that were sent with this request.
 */
- (NSUInteger) numberOfItemsOfType:(id) type;

/**
 Returns a NSData object for a single item of the specified type. If no items of this type are contained in this request, it will return nil.
 
 This method only works with the first item in the request. Items past the first will be ignored.
 */
- (NSData*) dataForType:(id) type;

/**
 Returns an array of NSData objects containing data for all items sent with this requests of the given type.

 Use of this method is appropriate only if you registered your app as being able to receive multiple items per request. See @ref kILAppSupportsReceivingMultipleItems for more information.
*/
- (NSArray*) dataForItemsOfType:(id) type;

/**
 Returns an appropriate object for a single item of the specified type. If no items of this type are contained in this request, or if the appropriate object would not be of the given class, it will return nil.
 
 This method only works with the first item in the request. Items past the first will be ignored.
 */
- (id) valueForType:(id) type expectedClass:(Class) c;

/**
 Returns an appropriate object for a single item of the specified type. If no items of this type are contained in this request it will return nil.
 
 This method only works with the first item in the request. Items past the first will be ignored.
 
 No type is guaranteed for any particular type — you should check the returned object's class before using it. You can use #valueForType:expectedClass: to signal to the implementation that you want a particular class returned. 
 */
- (id) valueForType:(id) type;

/**
 Returns an array of objects that are appropriate representations for items of the given type. All items will be considered, but if an item would have an appropriate object of a class other than the given one, the item will be skipped and this method will not return an object for it.
 
 Use of this method is appropriate only if you registered your app as being able to receive multiple items per request. See @ref kILAppSupportsReceivingMultipleItems for more information.
 */
- (NSArray*) valuesForItemsOfType:(id) type expectedClass:(Class) c;

/**
 Returns an array of objects that are appropriate representations for all items of the specified type in the request.
 
 No type is guaranteed for any particular type — you should check the returned object's class before using it. You can use #valuesForItemsOfType:expectedClass: to signal to the implementation that you want a particular class returned.

 Use of this method is appropriate only if you registered your app as being able to receive multiple items per request. See @ref kILAppSupportsReceivingMultipleItems for more information.
*/
- (NSArray*) valuesForItemsOfType:(id) type;

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

// Private. DO NOT USE.
#if kILSwapResponseAllowPrivateUse
@interface ILSwapRequest ()

/** @internal */
- (id) initWithPasteboard:(UIPasteboard*) pb attributes:(NSDictionary*) attributes removePasteboardWhenDone:(BOOL) remove;

@end
#endif

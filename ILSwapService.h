//
//  ILSwapService.h
//  SwapKit
//
//  Created by ∞ on 21/12/09.

/*
 
 The MIT License
 
 Copyright (c) 2009 Emanuele Vulcano ("∞labs")
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */


#import <UIKit/UIKit.h>
@class ILSwapRequest;

/**
\addtogroup ILSwapKitRegistrationKeys App Registration Keys

 These constants are the keys in an app registration -- a dictionary that says what an app can do. You can -- indeed, if you use SwapKit, you're expected to -- add a registration for your app, and you can query the services for all registrations on the system.
 These constants are used:

 - in Info.plist, in a dictionary under the ILSwapRegistration key, if you're using ILSwapService#didFinishLaunchingWithOptions: (much easier), or
 - as an argument to ILSwapService#registerWithAttributes:, if you are using it, less commonly, or
 - in the dictionaries returned by ILSwapService#applicationRegistrations and related methods (and in dictionaries passed to any ...Registration: argument).
 
 Note that if a key is marked "optional" below, and it has a default value, then you can expect to find it in dictionaries returned by ILSwapService#applicationRegistrations and ILSwapService#registrationForApplicationWithIdentifier: with the default value set. Keys marked as optional without a default may be missing from those dictionaries if unspecified.
 
 @{
*/
/// String. A unique identifier for your app. Automatically taken from CFBundleIdentifier if not given.
#define kILAppIdentifier @"ILAppIdentifier"

/// String. Localized, user-visible name for your app. Automatically taken from CFBundleDisplayName or CFBundleName or the bundle's name on the filesystem if not present.
#define kILAppVisibleName @"ILAppVisibleName"

/// String. The URL scheme that can be used to send items to this application.
#define kILAppReceiveItemURLScheme @"ILAppReceiveItemURLScheme"

/** 
Array of strings, 'actions'. An action marks the intended use of the received data for the receiving application. For example, an application may receive text to be made into a message, or a mood message change, so it can define two actions for that. The default action is "ILReceive" (that is, "Do your thing, whatever it is").
 
 The default for this key is '()' (the empty array) if you specify no types in the @ref kILAppSupportedReceivedItemsUTIs key (or if that key is missing), or '(ILReceive)' (just the default action) otherwise.

PLEASE NOTE: If you specify custom actions AND you also want to receive stuff for the default action, you have to mention it explicitly. Example: '(ILReceive, new-tweet, new-direct-message)'.
TODO: A better architecture to specify which actions apply to which types.
*/
#define kILAppSupportedActions @"ILAppSupportedActions"

/** 
Array of strings. UTIs advertised as accepted for receiving. Default is '()' (ie. nothing).
*/
#define kILAppSupportedReceivedItemsUTIs @"ILAppSupportedReceivedItemsUTIs" 

/// Boolean (NSNumber). If YES, sending multiple items is meaningful. If NO (default), sending multiple items will only cause the first item to be received.
#define kILAppSupportsReceivingMultipleItems @"ILAppSupportsReceivingMultipleItems"

/// String. Used to avoid registering multiple times. Will be ignored and overwritten by the internal registration machinery if given during registration, but will be returned by ILSwapRegistration#applicationRegistrations and related methods.
#define kILAppRegistrationUUID @"ILAppRegistrationUUID"

/// Property list object. The bundle version (CFBundleVersion in Info.plist). Used to update the registration after an app update. Will be ignored and overwritten by the internal registration machinery if given during registration, but will be returned by ILSwapRegistration#applicationRegistrations and related methods.
#define kILAppVersion @"ILAppVersion"

/** @} */

// -- - --

/**
\addtogroup ILSwapKitConstants Other Constants
*/

/**
\ingroup ILSwapKitConstants

This is the key in Info.plist the swap service will look for when autoregistering in didFinishLaunchingWithOptions:. It must contain a registration dictionary (see @ref ILSwapKitRegistrationKeys for more information on the contents of a registration dictionary).
*/
#define kILSwapServiceRegistrationInfoDictionaryKey @"ILSwapRegistration"

/**
\ingroup ILSwapKitConstants

This is the default action, that is, a generic "I can receive items of this type" action without strings attached. It's the action used if you specify nil in ILSwapService#sendItems:ofType:forAction:toApplicationWithIdentifier: and other methods that take an action.
*/
#define kILSwapDefaultAction @"ILReceive"

// -- - --

/**
\addtogroup ILSwapKitRequestAttributes Request Attributes

Request attributes are keys attached to a particular request, usually accessed through ILSwapRequest#attributes. Usually, the only key you will care about is @ref kILSwapServiceActionKey, which is the key that contains the action that was used to produce this request, but you can produce your own custom requests by specifying a dictionary containing these keys to the ILSwapService#sendRequestWithAttributes:toApplicationWithRegistration: method.

@{
*/

/** String: the action that was specified by the application that produced this request. */
#define kILSwapServiceActionKey @"swap.action"

/** String: the name for the pasteboard that contains the data for this request. You shouldn't use this key directly; instead, implement the ILSwapServiceDelegate#swapServiceDidReceiveRequest: method in your delegate. This allows SwapKit to dispose of the pasteboard correctly once it's no longer useful (and, in the future, use means other than pasteboards to receive and send data). */
#define kILSwapServicePasteboardNameKey @"swap.pasteboard"

/** @} */

// -- - --

@protocol ILSwapServiceDelegate;

/**
 \addtogroup ILSwapKit SwapKit Classes and Protocols
 */

/**
 \ingroup ILSwapKit
ILSwapService is a singleton class whose instance (referred to as simply the 'swap service') manages interactions between applications, including the registration of metadata in the shared application catalog and sending and receiving requests based on that metadata.

TODO: More detailed information.
*/
@interface ILSwapService : NSObject {
@private
	UIPasteboard* appCatalog;
	id <ILSwapServiceDelegate> delegate;
	NSDictionary* registrationAttributes;
	NSDictionary* appRegistrations;
	NSMutableSet* thisSessionOnlyPasteboards;
}

/// Returns the shared instance of this class.
+ sharedService;

/// Sets or retrieves the delegate. The object set through this property receives callbacks when SwapKit finds that certain events have happened (for example, that an array of items was received).
@property(assign) id <ILSwapServiceDelegate> delegate;

/**
Registers this app with the swap service. Most methods of this class DO NOT WORK unless this method is called first with valid attributes. Methods that only work after registration are noted in their documentation.

Usually, you don't call this method directly. Instead, you use the #didFinishLaunchingWithOptions: method from the application:didFinishLaunchingWithOptions: method of your app delegate, which automatically registers your app using registration attributes found in your Info.plist file at the @ref kILSwapServiceRegistrationInfoDictionaryKey.
 
@param a A dictionary containing app registration keys and values. If values are not supplied for some app registration keys, defaults may be used during registration instead.
@param update If YES, any current application's registration will be removed and replaced with this one. If NO, then the current registration will not be replaced, if it exists. Note that this method may try to perform maintenance operations upon the application catalog anyway (for instance, clearing unwanted multiple registrations for this app) even if this argument is set to NO.

@see #didFinishLaunchingWithOptions:
*/
- (void) registerWithAttributes:(NSDictionary*) a update:(BOOL) update;

/**
Called to perform appropriate delegate method calls based on the given URL. Returns YES if it has performed any action based on the URL (such as calling a delegate method), NO otherwise. Calling delegate methods requires having called #registerWithAttributes: since the app launched; otherwise, this method will always return NO.

Usually, you don't call this method directly. Instead, you use the #didFinishLaunchingWithOptions: method from the application:didFinishLaunchingWithOptions: method of your app delegate, and the #handleOpenURL: method from the application:handleOpenURL: method of your app delegate, which automatically call this method if needed.

@see #didFinishLaunchingWithOptions:
@see #handleOpenURL:
*/
- (BOOL) performActionsForURL:(NSURL*) u;

/**
 Convenience method for performing startup actions. It will perform the following upon the swap service instance:
 - sets the #delegate to the UIApplication delegate, and
 - calls #registerWithAttributes: with the dictionary at the @ref kILSwapServiceRegistrationInfoDictionaryKey key of Info.plist if present, and
 - if the passed-in options indicate a URL being opened, calls #performActionsForURL: (which may call appropriate delegate methods).
 Returns YES if #performActionsForURL: acted upon the URL, NO otherwise. (This allows you to ignore SwapKit-handled URLs.)

@param options The same dictionary that was passed to the application:didFinishLaunchingWithOptions: call on the application delegate.
*/
+ (BOOL) didFinishLaunchingWithOptions:(NSDictionary*) options;

/// Convenience method that calls #performActionsForURL: on the swap service instance.
/// Returns YES if performActionsForURL: acted upon the URL, NO otherwise. (This allows you to ignore SwapKit-handled URLs.)
+ (BOOL) handleOpenURL:(NSURL*) u;

// -- - --

// INTERACTING WITH OTHER APPLICATIONS

/**
Returns all application registrations. The returned dictionary uses application identifiers as keys, and registration dictionaries as their associated values. These contain any number of registration keys as specified in @ref ILSwapKitRegistrationKeys, and may contain the registration for this app if #registerWithAttributes: was called at least once from it.
*/
@property(readonly) NSDictionary* applicationRegistrations;

/**
 \internal
 Returns all application registration records in the application catalog. Items in this array are guaranteed to be registration dictionaries, but they are offered as-they-are, which means they may be missing required app registration keys, and there may be obsoleted or duplicate registrations in the catalog; this may not match what applicationRegistrations returns for the same applications.
 
 This property may be useful as a debugging feature or for writing apps that inspect the contents of the catalog, but should never be used by a normal SwapKit client. Do not rely on this being here in the future (that is, it's NOT part of the stable API).
 */
@property(readonly) NSArray* internalApplicationRegistrationRecords;
 

/**
 \internal
 Removes all application registration records and resets the application catalog to a clean state.
 
 Note that the use of this method also removes the current app's registration, as though you never called #registerWithAttributes: this session. If you want to use any service that requires registration, you might need to call this again.
 
 This method may be useful as a debugging feature or for writing apps that inspect the contents of the catalog, but should never be used by a normal SwapKit client. Do not rely on this being here in the future (that is, it's NOT part of the stable API).
 */
- (void) deleteAllApplicationRegistrations;

/// Returns the registration info for the given application identifier, or nil if it's unavailable.
- (NSDictionary*) registrationForApplicationWithIdentifier:(NSString*) appID;

/**
 Sends one item to the application with the given identifier. This is a convenience method for #sendItems:ofType:forAction:toApplicationWithIdentifier: for sending a single item; see the docs for that method for more information.
*/
- (BOOL) sendItem:(id) item ofType:(id) uti forAction:(NSString*) action toApplicationWithIdentifier:(NSString*) appID;

/**
 Sends the given items to the application with the given identifier.
 This method behaves as follows:
 - if an app ID is specified (non-nil), its registration will be used to send the items to it.
 - if no app ID is specified, the first app that supports receiving their item type for the given action will receive the items. If there's more than one item, and there is an app that has the @ref kILAppSupportsReceivingMultipleItems set to YES, it's preferred; otherwise, only the first item will be sent to the first app that supports that type, if any. Note that apps that do not support the given action are not considered.
 
Passing nil for the action is the same as passing @ref kILSwapDefaultAction.

 The items array can contain either ILSwapItem instances or "raw" values, which can be any value you could set a ILSwapItem#value to. In this second case, they will be wrapped into a metadata-less ILSwapItem when received by the other application. For reference, the following values are fine:
 
 - NSData.
 - NSString (in which case the type parameter must be kUTTypeUTF8PlainText).
 - NSArray or NSDictionary containing property list objects only.
 
 but see ILSwapItem#value's documentation for details.
 
@return YES if the item was dispatched to an app, NO otherwise.

@param items An array of items, as specified above.
@param uti The UTI for the type of all items in the items parameter array.
@param action The action to be performed upon the items by the target application. Can be nil; @ref kILSwapDefaultAction will be used in that case.
@param ident The application identifier for the target application, or nil to send to the first app that can handle the specified items, type and action.
*/
- (BOOL) sendItems:(NSArray*) items ofType:(id) uti forAction:(NSString*) action toApplicationWithIdentifier:(NSString*) ident;

/**
 Searches for a registered application that can receive the given items and perform the given action. This is the same algorithm described for the #sendItems:ofType:forAction:toApplicationWithIdentifier: method when the application identifier is nil.
 
 If you specify nil for the action, @ref kILSwapDefaultAction will be used.
 
 The returned registration is guaranteed to never refer to the currently running application.
 
 @return The registration dictionary for the right application, if found, or nil if no such application is registered with SwapKit.
 @see #sendItems:ofType:forAction:toApplicationWithIdentifier:
 */
- (NSDictionary*) applicationRegistrationForSendingItems:(NSArray*) items ofType:(id) uti forAction:(NSString*) action;

/**
 Returns YES if there is at least one app, other than the current one, that can receive the given items and action, NO otherwise. Using this method is more efficient than inspecting the return value of #applicationRegistrationForSendingItems:ofType:forAction: and #allApplicationRegistrationsForSendingItems:ofType:forAction:.
 
 If you specify nil for the action, @ref kILSwapDefaultAction will be used.
 
 @return The registration dictionary for the right application, if found, or nil if no such application is registered with SwapKit.
 @see #sendItems:ofType:forAction:toApplicationWithIdentifier:
 */
- (BOOL) canSendItems:(NSArray*) items ofType:(id) uti forAction:(NSString*) action;

/**
 Searches for a set of registered applications that can receive the given items and perform the given action. This is similar to #applicationRegistrationForSendingItems:ofType:forAction:, but returns all possible matches rather than a single one. The order of matches returned is currently arbitrary, but this may change in a future release of SwapKit.
 
 If you specify nil for the action, @ref kILSwapDefaultAction will be used.
 
 The returned array never contains the currently running application. If you want to get the currently running application's registration, use #registrationForApplicationWithIdentifier: with the current app's identifier instead.

 @return An array of registration dictionaries for all found applications. If none is found, an empty array will be returned.
 @see #applicationRegistrationForSendingItems:ofType:forAction:
 @see #sendItems:ofType:forAction:toApplicationWithIdentifier:
*/
- (NSArray*) allApplicationRegistrationsForSendingItems:(NSArray*) items ofType:(id) uti forAction:(NSString*) action;

/**
 This is the primitive request-sending method. It will send a request with the given attributes to the application whose registration dictionary is passed in.
 
 This method does no checking -- it is assumed that this method is called with an attributes dictionary that will be successfully parsed by another app, either via its delegate method or via SwapKit's built-in checks. #sendItems:ofType:forAction:toApplicationWithIdentifier: uses this method to send appropriately-formatted requests; it is preferred that you use that method, as it also takes care of placing the items in external storage (such as a pasteboard) and manages that storage's lifetime.
 
 @return YES if the request was dispatched, NO otherwise. (This only happens in cases of force majeoure -- eg the app does not have a URL scheme for receiving because the registration contains incorrect data.)
 */
- (BOOL) sendRequestWithAttributes:(NSDictionary*) attributes toApplicationWithRegistration:(NSDictionary*) reg;

@end

/**
 This is the delegate protocol that SwapKit expects its delegate to have. The delegate can be set by changing the ILSwapService#delegate property, and ILSwapService#didFinishLaunchingWithOptions: will set it by default to be the same as UIApplication's delegate.
 */
@protocol ILSwapServiceDelegate <NSObject>

@optional

/**
 Called whenever SwapKit detects that another application sent us a request through ILSwapService#sendItems:ofType:forAction:toApplicationWithIdentifier: or an equivalent method.
 
 @param request The request that was received.
 */
- (void) swapServiceDidReceiveRequest:(ILSwapRequest*) request;


/**
 Called whenever SwapKit detects a request not matching any of the usual patterns (that is, not associated with any other methods in this protocol). This is usually called when ILSwapService#sendRequestWithAttributes:toApplicationWithRegistration: is used by another application for sending custom requests.
 
 @param attricutres Contains the attributes for this request, the same ones that were passed to ILSwapService#sendRequestWithAttributes:.
 */
- (void) swapServiceDidReceiveRequestWithAttributes:(NSDictionary*) attricutres;

@end


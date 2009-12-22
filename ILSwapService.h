//
//  ILSwapService.h
//  SwapKit
//
//  Created by ∞ on 21/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

// These constants are the keys in an app registration -- a dictionary that says what an app can do. You can -- indeed, if you use SwapKit, you're expected to -- add a registration for your app, and you can query the services for all registrations on the system.
// These constants are used:
// - in Info.plist, in a dictionary under the ILSwapRegistration key, if you're using +didFinishLaunchingWithOptions: (much easier), or
// - as an argument to -registerWithAttributes:, if you are using it, less commonly, or
// - in the dictionaries returned by -applicationRegistrations and related methods (and in dictionaries passed to any ...Registration: argument).

// String. A unique identifier for your app. Automatically taken from CFBundleIdentifier if not given.
#define kILAppIdentifier @"ILAppIdentifier"

// String. Localized, user-visible name for your app. Automatically taken from CFBundleDisplayName or CFBundleName or the bundle's name on the filesystem if not present.
#define kILAppVisibleName @"ILAppVisibleName"

// String. The URL scheme that can be used to send items to this application.
#define kILAppReceiveItemURLScheme @"ILAppReceiveItemURLScheme"

// Array of strings, 'actions'. An action marks the intended use of the received data for the receiving application. For example, an application may receive text to be made into a message, or a mood message change, so it can define two actions for that. The default action is "ILReceive" (that is, "Do your thing, whatever it is"), thus making the default value of this key '(ILReceive)'.
// PLEASE NOTE: If you specify custom actions AND you also want to receive stuff for the default action, you have to mention it explicitly. Example: '(ILReceive, new-tweet, new-direct-message)'.
// TODO: A better architecture to specify which actions apply to which types.
#define kILAppSupportedActions @"ILAppSupportedActions"

// Array of strings. UTIs advertised as accepted for receiving. Default is ('public.data') (ie. anything).
// TODO: The current stack does not look at type conformance, so you need to specify the EXACT UTIs you support. Saying 'public.image' is not enough; you have to add 'public.jpeg' and 'public.png', for example, to receive images in both formats.
#define kILAppSupportedReceivedItemsUTIs @"ILAppSupportedReceivedItemsUTIs" 

// Boolean (NSNumber). If YES, sending multiple items is meaningful. If NO (default), sending multiple items will only cause the first item to be received.
#define kILAppSupportsReceivingMultipleItems @"ILAppSupportsReceivingMultipleItems"

// String. Used to avoid registering multiple times. Will be ignored and overwritten by the internal registration machinery if given.
#define kILAppRegistrationUUID @"ILAppRegistrationUUID"

// Property list object. The bundle version (CFBundleVersion in Info.plist). Used to update the registration after an app update. Will be ignored and overwritten by the internal registration machinery if given.
#define kILAppVersion @"ILAppVersion"

// -- - --

// The key in Info.plist the swap service will look for when autoregistering in didFinishLaunchingWithOptions:.
#define kILSwapServiceRegistrationInfoDictionaryKey @"ILSwapRegistration"

// The name of the default action.
#define kILSwapDefaultAction @"ILReceive"

// -- - --

// These keys are used in the attributes array that's passed to -sendRequestWithAttributes:toApplicationWithRegistration: and -swapServiceDidReceiveItemsInPasteboard:attributes:.
// Those dictionaries can contain any custom key, so long that it does not have the @"swap." prefix.

#define kILSwapServicePasteboardNameKey @"swap.pasteboard"
#define kILSwapServiceActionKey @"swap.action"

// -- - --

@protocol ILSwapServiceDelegate;

@interface ILSwapService : NSObject {
	UIPasteboard* appCatalog;
	id <ILSwapServiceDelegate> delegate;
	NSDictionary* registrationAttributes;
	NSDictionary* appRegistrations;
}

+ sharedService;

@property(assign) id <ILSwapServiceDelegate> delegate;

// Registers this app to Swap Services. Most methods of this class DO NOT WORK unless this method is called first with valid attributes. Methods that only work after registration are noted in their comments below.
- (void) registerWithAttributes:(NSDictionary*) a;

// Called to perform appropriate delegate method calls based on the URL. Returns YES if it has performed any action based on the URL (such as calling a delegate method), NO otherwise.
- (BOOL) performActionsForURL:(NSURL*) u;

// Convenience method:
// - sets .delegate to the UIApplication delegate (if it conforms to ILSwapServiceDelegate), and
// - calls registerWithAttributes with the dictionary at the ILSwapRegistration key of Info.plist if present, and
// - if it's a URL being opened, calls performActionsForURL: (which may call appropriate delegate methods).
// Returns YES if performActionsForURL: acted upon the URL, NO otherwise. (This allows you to ignore SwapKit-handled URLs.)

// options must be the same dictionary that is passed to application:didFinishLaunchingWithOptions:.

+ (BOOL) didFinishLaunchingWithOptions:(NSDictionary*) options;

// Convenience method.
// Calls performActionsForURL: on the shared service instance. Useful as a mnemonic.
// Returns YES if performActionsForURL: acted upon the URL, NO otherwise. (This allows you to ignore SwapKit-handled URLs.)

+ (BOOL) handleOpenURL:(NSURL*) u;

// -- - --

// INTERACTING WITH OTHER APPLICATIONS

// Returns all application registrations. These contain any number of kILApp... keys as specified above, and may contain the registration for this app.
- (NSDictionary*) applicationRegistrations;

// Returns the registration info for the given application.
- (NSDictionary*) registrationForApplicationWithIdentifier:(NSString*) appID;

// Sends the given item(s) to the application with the given ID.
// Behavior:
// - if an app ID is specified (non-nil), its registration will be used to send the items to it.
// - if no app ID is specified, the first app that supports receiving their item type for the given action will receive them. If there's more than one item, and there is an app that has kILAppSupportsReceivingMultipleItems is YES, it is preferred; otherwise, only the first one will be sent to the first app that supports that type, if any. Note that apps that do not support the given action are not taken in consideration.
// Passing nil for the action is the same as passing kILSwapDefaultAction.
// Returns YES if the item was dispatched to an app, NO otherwise.

// items is an array of property list values, NSURLs, or NSData objects of a type identified for all items by the same UTI.
// type is said UTI.
- (BOOL) sendItems:(NSArray*) items ofType:(id) uti forAction:(NSString*) action toApplicationWithIdentifier:(NSString*) ident;

// Searches registrations as specified above in the case of nil app identifier. Returns the most appropriate registration if found, or nil otherwise.
// Passing nil for the action is the same as passing kILSwapDefaultAction.
- (NSDictionary*) applicationRegistrationForSendingItems:(NSArray*) items ofType:(id) uti forAction:(NSString*) action;

// Sends a request with the given attributes to the app with the given registration, which cannot be nil.
// This method does no checking -- it is assumed that this method is called with an attributes dictionary that will be successfully parsed by another app. Note that this at the moment means that it must contain the kILSwapServicePasteboardNameKey pointing to an actual persistent pasteboard. -sendItems:ofType:forAction:toApplicationWithIdentifier: uses this method to send appropriately-formatted requests.
// Returns YES if the item was dispatched to the app, NO otherwise. (This only happens in cases of force majeoure -- eg the app does not have a URL scheme for receiving.)
- (BOOL) sendRequestWithAttributes:(NSDictionary*) attributes toApplicationWithRegistration:(NSDictionary*) reg;

@end


@protocol ILSwapServiceDelegate <NSObject>

@optional

// Called whenever somebody calls our receive URL scheme. The pasteboard contains the passed-in items.
// Please note: the pasteboard will be automatically invalidated and deleted after this call. You must copy or retain any data you wish to keep.
- (void) swapServiceDidReceiveItemsInPasteboard:(UIPasteboard*) pasteboard attributes:(NSDictionary*) attributes;

@end


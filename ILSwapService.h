//
//  ILSwapService.h
//  SwapKit
//
//  Created by ∞ on 21/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

// String. Automatically taken from CFBundleIdentifier if not present.
#define kILAppIdentifier @"ILAppIdentifier"

// String. Automatically taken from CFBundleDisplayName or CFBundleName or the bundle's name on the filesystem if not present. Localized, user-visible.
#define kILAppVisibleName @"ILAppVisibleName" 

// String. The URL scheme that can be used to send items to this application.
#define kILAppReceiveItemURLScheme @"ILAppReceiveItemURLScheme"

// Array of strings. UTIs advertised as accepted for receiving. Default is ('public.data') (ie. anything).
#define kILAppSupportedReceivedItemsUTIs @"ILAppSupportedReceivedItemsUTIs" 

// Boolean (NSNumber). If YES, sending multiple items is meaningful. If NO (default), sending multiple items will only cause the first item to be received.
#define kILAppSupportsReceivingMultipleItems @"ILAppSupportsReceivingMultipleItems"

// String. Used to avoid registering multiple times. Will be ignored and overwritten by the internal registration machinery if given.
#define kILAppRegistrationUUID @"ILAppRegistrationUUID"

// Property list object. The bundle version (CFBundleVersion in Info.plist). Used to update the registration after an app update. Will be ignored and overwritten by the internal registration machinery if given.
#define kILAppVersion @"ILAppVersion"

// --

// The key in Info.plist the swap service will look for when autoregistering in didFinishLaunchingWithOptions:.
#define kILSwapServiceRegistrationInfoDictionaryKey @"ILSwapRegistration"

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
// - if no app ID is specified, the first app that supports receiving their item type will receive them. If there's more than one item, and there is an app that has kILAppSupportsReceivingMultipleItems is YES, it is preferred; otherwise, only the first one will be sent to the first app that supports that type, if any.
// This method will never dispatch the items to the same app that's sending them (ie this one).
// Returns YES if the item was dispatched to an app, NO otherwise.

// items is an array of property list values, NSURLs, or NSData objects of a type identified for all items by the same UTI.
// type is said UTI.
- (BOOL) sendItems:(NSArray*) items ofType:(id) uti toApplicationWithIdentifier:(NSString*) appID;

// Sends the given pasteboard to the app with the given app registration.
// This method does no checking -- it is assumed that you looked up appropriate info from the registration and checked yourself whether the app supports receiving the contents of the pasteboard (ie by looking at kILAppSupportsReceivingMultipleItems and kILAppSupportedReceivedItemsUTIs).
// Returns YES if the item was dispatched to the app, NO otherwise. (This only happens in cases of force majeoure -- eg the app does not have a URL scheme for receiving.)
- (BOOL) sendPasteboard:(UIPasteboard*) pb toApplicationWithRegistration:(NSDictionary*) reg;

@end


@protocol ILSwapServiceDelegate <NSObject>

@optional

// Called whenever somebody calls our receive URL scheme. The pasteboard contains the passed-in items.
// Please note: the pasteboard will be automatically invalidated and deleted after this call. You must copy or retain any data you wish to keep.
- (void) swapServiceDidReceiveItemsInPasteboard:(UIPasteboard*) pasteboard;

@end

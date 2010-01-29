//
//  ILSwapSendingController.h
//  SwapKit
//
//  Created by ∞ on 25/12/09.

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

@protocol ILSwapSendControllerDelegate;

/**
\addtogroup ILSwapKit SwapKit Classes and Protocols
*/

/**
\ingroup ILSwapKit
A ILSwapSendingController instance (a sending controller) provides a common "send to other application" user interface. Once invoked, it will search for appropriate destination applications for the given items, type and action, and present them to the user with an action sheet. Once chosen, it will send the items to that application.

Memory management is similar to UIAlertViews and UIActionSheets; you don't need to retain the instance explicitly if you just want to show it. You do have to retain it if you want to keep a reference to it alive, as per normal memory management rules.
*/
@interface ILSwapSendingController : NSObject {
@private
	NSArray* destinations;
	
	NSArray* items;
	id type;
	NSString* action;
	
	UIBarButtonItem* sendButtonItem;
	
	id <ILSwapSendControllerDelegate> delegate;
}

/** Creates a new sending controller. Designated initializer. */
- (id) init;

/**
 Sets the delegate of this instance. Not retained. */
@property(assign) id <ILSwapSendControllerDelegate> delegate;

/**
Creates a new sending controller that will allow users to pick an application able to receive items for the given item type and action.

@param items The items to send.
@param uti The UTI all items will be sent as.
@param action The desired action. Can be nil to use the default (kILSwapDefaultAction).
@see ILSwapService#sendItems:ofType:forAction:toApplicationWithIdentifier:
*/
- (id) initWithItems:(NSArray*) items ofType:(id) uti forAction:(NSString*) action;

/** Convenience method for returning an autoreleased sending controller initialized by ILSwapSendingController#initWithItems:ofType:forAction:. */
+ (id) controllerForSendingItems:(NSArray*) items ofType:(id) uti forAction:(NSString*) action;

/** The items to send. Must not be modified while sending. */
@property(copy) NSArray* items;

/** The type of the items to send as a UTI. Must not be modified while sending. */
@property(copy) id type;

/** The action to use. If nil, @ref kILSwapDefaultAction will be used. Must not be modified while sending. */
@property(copy) NSString* action;

/** Whether it's possible to send items to another application. You can use Key-Value Observing (KVO) to be notified of changes to this value.
 
 This property will be NO while there is no destination available or while the items and type properties are nil. If YES, calling #send or #send: will show the sending user interface; if NO, these methods will have no effect. */
@property(readonly) BOOL canSend;

/** A "share" button item that can be added to any button bar. It will use the system "Action" ('share') icon.
 
 This item will be enabled or disabled as you change this object's properties, and will call -send when touched.
 You can change any property of this object, except .enabled.
 */
@property(readonly) UIBarButtonItem* sendButtonItem;

/**
Performs the sending. If no applications are found, this method will do nothing; otherwise, it will show a list of destination applications in an action sheet. (Currently, it shows the list even if there is a single possible application, to give the user a opportunity to confirm the app switch.)

This method shows the action sheet in the key window. To specify what window or view to use, see ILSwapSendingController#send:.
*/
- (void) send;

/**
Performs the sending. If no applications are found, this method will do nothing; otherwise, it will show a list of destination applications in an action sheet. (Currently, it shows the list even if there is a single possible application, to give the user a opportunity to confirm the app switch.)

This method shows the action sheet in a way that is appropriate for the given view.

@param v The view to take the action sheet style from, or to display the action sheet in. If it's a UIToolbar or UITabBar, it will use the UIActionSheet's showFromToolbar: or showFromTabBar: methods, and will style the action sheet accordingly to the toolbar or tab bar's current style. Otherwise, it will show the action sheet within this view.
*/
- (void) send:(UIView*) v;

@end

/**
 \addtogroup ILSwapKitConstants Other Constants
 */

/**
 \ingroup ILSwapKitConstants
 A set of possible causes for errors during sending. See ILSwapSendingController and ILSwapSendControllerDelegate for more information.
*/
enum ILSwapSendingErrorCause {
	/// The user chose the Cancel button on a UI element displayed by the sending controller.
	kILSwapSendingCancelled = 0,
	
	/// The sending controller was asked to send, but had no possible destinations for sending.
	kILSwapNoKnownDestinationForSending = 1,
};
typedef NSInteger ILSwapSendingErrorCause;

/**
 This is the protocol for delegates of a ILSwapSendingController.
 */
@protocol ILSwapSendControllerDelegate <NSObject>

/**
 Called when sending (via ILSwapSendingController#send or ILSwapSendingController#send:) fails.
 
 @param sendController The controller that failed.
 @param cause Why the controller failed.
*/
- (void) sendController:(ILSwapSendingController*) sendController didNotSendItemsWithCause:(ILSwapSendingErrorCause) cause;

@end

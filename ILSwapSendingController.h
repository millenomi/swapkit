//
//  ILSwapSendingController.h
//  SwapKit
//
//  Created by ∞ on 25/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

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
}

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

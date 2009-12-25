//
//  ILSwapSendingController.h
//  SwapKit
//
//  Created by ∞ on 25/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ILSwapSendingController : NSObject {
	NSArray* destinations;
	
	NSArray* items;
	id type;
	NSString* action;
	
	
}

- (id) initWithItems:(NSArray*) items ofType:(id) uti forAction:(NSString*) action;
+ (id) controllerForSendingItems:(NSArray*) items ofType:(id) uti forAction:(NSString*) action;

- (void) send;

// if it shows an user interface, it will be appropriate for the given view.
// See the show* methods in UIActionSheet for more information. If unsure, use -send instead.
- (void) send:(UIView*) v;

@end

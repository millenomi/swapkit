//
//  ILSwapSendText.h
//  Catalog
//
//  Created by ∞ on 07/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "L0Keyboard.h"

@interface ILSwapSendText : UIViewController <L0KeyboardObserver> {
	IBOutlet UITextView* textView;
	
	NSString* type;
	NSString* app;
	
	id target;
	SEL didFinish;
}

// finish == - swapKitSendTextDidFinish:(ILSwapSendText*) s;
- (id) initWithApplicationIdentifier:(NSString*) app type:(NSString*) type target:(id) t didFinishSelector:(SEL) finish;
- (void) dismissModal;

@end

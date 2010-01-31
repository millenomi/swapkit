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
}

- (id) initWithApplicationIdentifier:(NSString*) app type:(NSString*) type;

- (void) dismissModal;

@end

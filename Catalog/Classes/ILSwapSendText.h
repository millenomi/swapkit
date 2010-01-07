//
//  ILSwapSendText.h
//  Catalog
//
//  Created by ∞ on 07/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ILSwapSendText : UIViewController {
	IBOutlet UITextView* textView;
	
	NSString* type;
	NSString* app;
}

- (id) initWithApplicationIdentifier:(NSString*) app type:(NSString*) type;

@end

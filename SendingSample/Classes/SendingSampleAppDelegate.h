//
//  SendingSampleAppDelegate.h
//  SendingSample
//
//  Created by ∞ on 27/12/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendingSampleAppDelegate : NSObject <UIApplicationDelegate, UITextViewDelegate> {
    UIWindow *window;
	
	IBOutlet UITextView* loremIpsumView;
	IBOutlet UIBarButtonItem* doneButton;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

- (IBAction) send;
- (IBAction) done;

@end


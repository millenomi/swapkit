//
//  SendingSampleAppDelegate.h
//  SendingSample
//
//  Created by ∞ on 27/12/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendingSampleAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	
	IBOutlet UITextView* loremIpsumView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

- (IBAction) send;

@end


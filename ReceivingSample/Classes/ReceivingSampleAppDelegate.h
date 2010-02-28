//
//  ReceivingSampleAppDelegate.h
//  ReceivingSample
//
//  Created by ∞ on 28/12/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReceivingSampleAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	IBOutlet UITextView* textView;
	IBOutlet UINavigationItem* currentNavigationItem;
	IBOutlet UINavigationController* rootController;
	IBOutlet UIViewController* imagePane;
	IBOutlet UIImageView* imageView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end


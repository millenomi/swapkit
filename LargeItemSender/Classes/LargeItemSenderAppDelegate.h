//
//  LargeItemSenderAppDelegate.h
//  LargeItemSender
//
//  Created by ∞ on 01/03/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LargeItemSenderAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

- (IBAction) send;

@property(readonly) NSString* path;

@end


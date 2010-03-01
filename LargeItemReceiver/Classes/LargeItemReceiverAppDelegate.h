//
//  LargeItemReceiverAppDelegate.h
//  LargeItemReceiver
//
//  Created by ∞ on 01/03/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SwapKit/SwapKit.h>

@interface LargeItemReceiverAppDelegate : NSObject <UIApplicationDelegate, ILSwapServiceDelegate, ILSwapReaderDelegate> {
    UIWindow *window;
	id <ILSwapReader> reader;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end


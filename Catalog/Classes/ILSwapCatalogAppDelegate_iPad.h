//
//  ILSwapCatalogAppDelegate_iPad.h
//  Catalog
//
//  Created by ∞ on 31/01/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ILSwapCatalogAppDelegate.h"

@interface ILSwapCatalogAppDelegate_iPad : NSObject <UIApplicationDelegate, ILSwapCatalogAppServices, UISplitViewControllerDelegate> {
	IBOutlet UISplitViewController* splitViewController;
	IBOutlet UIWindow* window;
	
	IBOutlet UINavigationController* detailsController;
	IBOutlet UIViewController* noItemController;
	
	UIPopoverController* popover;
	UIBarButtonItem* popoverItem;
}

@property(nonatomic, retain) UIWindow* window;

@property(nonatomic, retain) UIPopoverController* popover;
@property(nonatomic, retain) UIBarButtonItem* popoverItem;

@end

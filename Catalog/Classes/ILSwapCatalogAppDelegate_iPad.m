//
//  ILSwapCatalogAppDelegate_iPad.m
//  Catalog
//
//  Created by ∞ on 31/01/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ILSwapCatalogAppDelegate_iPad.h"
#import "ILSwapAppPane.h"

UILabel* ILSwapCatalogNavigationBarTitleViewForString(NSString* s) {
	UILabel* l = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	l.text = s;
	l.numberOfLines = 1;
	l.font = [UIFont boldSystemFontOfSize:20];
	l.textColor = [UIColor whiteColor];
	l.shadowColor = [UIColor grayColor];
	l.shadowOffset = CGSizeMake(0, -1);
	[l sizeToFit];
	l.opaque = NO;
	l.backgroundColor = [UIColor clearColor];
	return l;
}

@interface ILSwapCatalogAppDelegate_iPad ()

- (void) updatePopverBarItem;

@end



@implementation ILSwapCatalogAppDelegate_iPad

@synthesize window, popover, popoverItem;

- (void) dealloc
{
	[window release];
	[popoverItem release];
	[popover release];
	[detailsController release];
	[noItemController release];
	[splitViewController release];
	[super dealloc];
}


- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
{
	splitViewController.delegate = self;
	[window addSubview:splitViewController.view];
	[window makeKeyAndVisible];
	
	return YES;
}

- (void) displayApplicationRegistration:(NSDictionary *)reg;
{
	UIViewController* toDisplay;
	if (reg)
		toDisplay = [[[ILSwapAppPane alloc] initWithApplicationRegistrationRecord:reg] autorelease];
	else
		toDisplay = noItemController;
	
	detailsController.viewControllers = [NSArray arrayWithObject:toDisplay];
	[self updatePopverBarItem];
	
	[popover dismissPopoverAnimated:YES];
}

- (void) displaySendViewController:(UIViewController*) c;
{
	c.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:c action:@selector(dismissModal)] autorelease];
	
	UINavigationController* nav = [[[UINavigationController alloc] initWithRootViewController:c] autorelease];
	nav.modalPresentationStyle = UIModalPresentationPageSheet;
	
	[splitViewController presentModalViewController:nav animated:YES];
}

- (void) displayImagePickerController:(UIImagePickerController *)c comingFromView:(UIView *)v withinViewController:(UIViewController *)p;
{
	UIPopoverController* pc = [[UIPopoverController alloc] initWithContentViewController:c];
	[pc presentPopoverFromRect:v.bounds inView:v permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void) updatePopverBarItem;
{
	detailsController.topViewController.navigationItem.leftBarButtonItem = self.popoverItem;
}

- (void) splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc;
{
	self.popover = pc;
	self.popoverItem = barButtonItem;
	self.popover.popoverContentSize = CGSizeMake(320, 500);
	[self updatePopverBarItem];
}

- (void) splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem;
{
	self.popover = nil;
	self.popoverItem = nil;
	[self updatePopverBarItem];
}

- (void) showActionSheet:(UIActionSheet*) a invokedByBarButtonItem:(UIBarButtonItem*) item;
{
	[a showFromBarButtonItem:item];
}

- (void) showActionSheet:(UIActionSheet*) a invokedByView:(UIView*) view;
{
	[a showFromRect:view.bounds inView:view animated:YES];
}

- (BOOL) shouldSupportAdditionalOrientation:(UIInterfaceOrientation) o forViewController:(UIViewController*) vc;
{
	return YES; // on iPad, the interface orients YOU
}

@end

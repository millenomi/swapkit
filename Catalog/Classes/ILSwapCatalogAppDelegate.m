//
//  CatalogAppDelegate.m
//  Catalog
//
//  Created by ∞ on 04/01/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "ILSwapCatalogAppDelegate.h"
#import "ILSwapCatalogPane.h"
#import "ILSwapAppPane.h"

#import <SwapKit/SwapKit.h>

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

BOOL ILSwapIsiPad() {
	static BOOL checked = NO, isiPad;
	if (!checked) {
		isiPad = NO;
		UIDevice* d = [UIDevice currentDevice];
		
		if ([d respondsToSelector:@selector(userInterfaceIdiom)]) 
			isiPad = (d.userInterfaceIdiom == UIUserInterfaceIdiomPad);
		
		checked = YES;
	}
	
	return isiPad;
}

@interface ILSwapCatalogAppDelegate () <UISplitViewControllerDelegate>
- (void) updatePopverBarItem;
- (void) didFinishLaunhingOniPadWithOptions:(NSDictionary*) options;
@end

@implementation ILSwapCatalogAppDelegate

@synthesize popover, popoverItem;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary*) options {    
    
	if (ILSwapIsiPad())
		[self didFinishLaunhingOniPadWithOptions:options];
	else
		[window addSubview:[navigationController view]];
	
    [window makeKeyAndVisible];
	return YES;
}

- (BOOL) shouldSupportAdditionalOrientation:(UIInterfaceOrientation) o forViewController:(UIViewController*) vc;
{
	if (ILSwapIsiPad())
		return YES; // on iPad, the interface orients YOU
	else
		return NO; // only allow iPhonesque standard orientations.
}

- (void) showActionSheet:(UIActionSheet*) a invokedByBarButtonItem:(UIBarButtonItem*) item;
{
	if (ILSwapIsiPad() && [a respondsToSelector:@selector(showFromBarButtonItem:)])
		[a showFromBarButtonItem:item];
	else
		[a showInView:window];
}

- (void) showActionSheet:(UIActionSheet*) a invokedByView:(UIView*) view;
{
	if (ILSwapIsiPad() && [a respondsToSelector:@selector(showFromRect:inView:animated:)])
		[a showFromRect:view.bounds inView:view animated:YES];
	else
		[a showInView:window];
}

- (void) displayApplicationRegistration:(NSDictionary*) reg;
{
	if (ILSwapIsiPad()) {
		UIViewController* toDisplay;
		if (reg)
			toDisplay = [[[ILSwapAppPane alloc] initWithApplicationRegistrationRecord:reg] autorelease];
		else
			toDisplay = noItemController;
		
		detailsController.viewControllers = [NSArray arrayWithObject:toDisplay];
		[self updatePopverBarItem];
		
		[popover dismissPopoverAnimated:YES];
	} else if (reg) { // iPhone
		ILSwapAppPane* pane = [[[ILSwapAppPane alloc] initWithApplicationRegistrationRecord:reg] autorelease];
		[navigationController pushViewController:pane animated:YES];
	}
}

- (void) displaySendViewController:(UIViewController*) c;
{
	if (ILSwapIsiPad()) {
		c.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:c action:@selector(dismissModal)] autorelease];
		
		UINavigationController* nav = [[[UINavigationController alloc] initWithRootViewController:c] autorelease];
		nav.modalPresentationStyle = UIModalPresentationPageSheet;
		
		[splitController presentModalViewController:nav animated:YES];
	} else
		[navigationController pushViewController:c animated:YES];
}

- (void) displayImagePickerController:(UIImagePickerController*) c comingFromView:(UIView*) v withinViewController:(UIViewController*) p;
{
	if (ILSwapIsiPad()) {
		UIPopoverController* pc = [[ILSwapiPadClass(UIPopoverController) alloc] initWithContentViewController:c];
		[pc presentPopoverFromRect:v.bounds inView:v permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	} else
		[p presentModalViewController:c animated:YES];
}

#pragma mark iPad Split View Management

- (void) didFinishLaunhingOniPadWithOptions:(NSDictionary *)options;
{
	splitController = [[ILSwapiPadClass(UISplitViewController) alloc] init];
	splitController.delegate = self;
	splitController.viewControllers = [NSArray arrayWithObjects:navigationController, detailsController, nil];
	[window addSubview:splitController.view];
}

- (void) updatePopverBarItem;
{
	detailsController.topViewController.navigationItem.leftBarButtonItem = self.popoverItem;
}

- (void) splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc;
{
	self.popover = pc;
	self.popoverItem = barButtonItem;	
	self.popoverItem.title = NSLocalizedString(@"SwapKit Catalog", @"Title for master popover button");
	
	self.popover.popoverContentSize = CGSizeMake(320, 500);
	[self updatePopverBarItem];
}

- (void) splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem;
{
	self.popover = nil;
	self.popoverItem = nil;
	[self updatePopverBarItem];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

@end


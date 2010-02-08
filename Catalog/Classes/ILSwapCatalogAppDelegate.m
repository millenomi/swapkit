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


#if kILSwapCatalogPlatform_iPhone

@implementation ILSwapCatalogAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}

- (BOOL) shouldSupportAdditionalOrientation:(UIInterfaceOrientation) o forViewController:(UIViewController*) vc;
{
	return NO; // only allow iPhonesque standard orientations.
}

- (void) showActionSheet:(UIActionSheet*) a invokedByBarButtonItem:(UIBarButtonItem*) item;
{
	[a showInView:self.window];
}

- (void) showActionSheet:(UIActionSheet*) a invokedByView:(UIView*) view;
{
	[a showInView:self.window];
}

- (void) displayApplicationRegistration:(NSDictionary*) reg;
{
	if (reg) {
		ILSwapAppPane* pane = [[[ILSwapAppPane alloc] initWithApplicationRegistrationRecord:reg] autorelease];
		[self.navigationController pushViewController:pane animated:YES];
	}
}

- (void) displaySendViewController:(UIViewController*) c;
{
	[self.navigationController pushViewController:c animated:YES];
}

- (void) displayImagePickerController:(UIImagePickerController*) c comingFromView:(UIView*) v withinViewController:(UIViewController*) p;
{
	[p presentModalViewController:c animated:YES];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

@end

#endif

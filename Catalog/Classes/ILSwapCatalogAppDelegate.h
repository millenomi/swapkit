//
//  CatalogAppDelegate.h
//  Catalog
//
//  Created by ∞ on 04/01/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

extern UILabel* ILSwapCatalogNavigationBarTitleViewForString(NSString* s);
extern BOOL ILSwapIsiPad();

@protocol ILSwapCatalogAppServices <NSObject>

- (BOOL) shouldSupportAdditionalOrientation:(UIInterfaceOrientation) o forViewController:(UIViewController*) vc;

- (void) showActionSheet:(UIActionSheet*) a invokedByBarButtonItem:(UIBarButtonItem*) item;
- (void) showActionSheet:(UIActionSheet*) a invokedByView:(UIView*) view;

- (void) displayApplicationRegistration:(NSDictionary*) reg;
- (void) displaySendViewController:(UIViewController*) c;

@end

static inline id <ILSwapCatalogAppServices> ILSwapCatalogApp() {
	return (id <ILSwapCatalogAppServices>) UIApp.delegate;
}

@interface ILSwapCatalogAppDelegate : NSObject
<UIApplicationDelegate, UIActionSheetDelegate, ILSwapCatalogAppServices> {
    IBOutlet UIWindow* window;
    IBOutlet UINavigationController* navigationController;
		
	IBOutlet UINavigationController* detailsController;
	IBOutlet UIViewController* noItemController;
	
	UISplitViewController* splitController;
	
	UIPopoverController* popover;
	UIBarButtonItem* popoverItem;
}

@property(nonatomic, retain) UIPopoverController* popover;
@property(nonatomic, retain) UIBarButtonItem* popoverItem;

@end


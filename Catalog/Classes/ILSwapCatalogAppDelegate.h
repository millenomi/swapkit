//
//  CatalogAppDelegate.h
//  Catalog
//
//  Created by ∞ on 04/01/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#if kILSwapCatalogPlatform_iPad
extern UILabel* ILSwapCatalogNavigationBarTitleViewForString(NSString* s);
#endif

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

#if kILSwapCatalogPlatform_iPhone

@interface ILSwapCatalogAppDelegate : NSObject
<UIApplicationDelegate, UIActionSheetDelegate, ILSwapCatalogAppServices> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

#endif

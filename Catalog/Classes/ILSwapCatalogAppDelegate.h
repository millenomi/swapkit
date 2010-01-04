//
//  CatalogAppDelegate.h
//  Catalog
//
//  Created by ∞ on 04/01/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

@interface ILSwapCatalogAppDelegate : NSObject <UIApplicationDelegate, UIActionSheetDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

static inline ILSwapCatalogAppDelegate* ILSwapCatalogApp() {
	return (ILSwapCatalogAppDelegate*) UIApp.delegate;
}

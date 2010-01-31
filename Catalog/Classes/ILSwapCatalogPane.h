//
//  RootViewController.h
//  Catalog
//
//  Created by ∞ on 04/01/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

@interface ILSwapCatalogPane : UITableViewController {
	NSArray* displayedApplications;
	
	NSIndexPath* lastSelection;
	BOOL keepsLastSelection;
}

- (IBAction) deleteAllItems:(id) sender;

@property(copy) NSIndexPath* lastSelection;
@property BOOL keepsLastSelection;

@end

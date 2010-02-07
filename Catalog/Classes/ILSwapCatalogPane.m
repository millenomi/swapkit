//
//  RootViewController.m
//  Catalog
//
//  Created by ∞ on 04/01/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "ILSwapCatalogPane.h"
#import <SwapKit/SwapKit.h>
#import "ILSwapAppPane.h"
#import "ILSwapCatalogAppDelegate.h"

@interface ILSwapCatalogPane () <UIActionSheetDelegate>
@property(copy) NSArray* displayedApplications;
- (void) reloadData;
@end

static NSComparisonResult ILSwapCatalogPaneCompareRegistrationsAlphabetically(id a, id b, void* context) {
	id aName = [a objectForKey:kILAppVisibleName];
	id bName = [b objectForKey:kILAppVisibleName];
	
	return (aName && bName)? [aName compare:bName] : NSOrderedSame;
}


@implementation ILSwapCatalogPane

@synthesize displayedApplications, lastSelection, keepsLastSelection;

- (void) viewWillAppear:(BOOL)animated;
{
#if kILSwapCatalogPlatform_iPad
	keepsLastSelection = YES;
#endif
	
	self.title = NSLocalizedString(@"SwapKit Catalog", @"Title for the catalog pane");
	self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"\u21c4 Catalog", @"Back (shorter) title for the catalog pane") style:UIBarButtonItemStyleBordered target:nil action:NULL] autorelease];
	
	[self reloadData];
	[super viewWillAppear:animated];
	
	if (keepsLastSelection && self.lastSelection)
		[self.tableView selectRowAtIndexPath:self.lastSelection animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void) dealloc
{
	[displayedApplications release];
	[lastSelection release];
	[super dealloc];
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
{
	return UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ||
		[ILSwapCatalogApp() shouldSupportAdditionalOrientation:toInterfaceOrientation forViewController:self];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.displayedApplications count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	NSDictionary* d = [self.displayedApplications objectAtIndex:[indexPath row]];
	cell.textLabel.text = [d objectForKey:kILAppVisibleName];
	cell.detailTextLabel.text = [d objectForKey:kILAppIdentifier];
	
	NSString* scheme = [d objectForKey:kILAppReceiveItemURLScheme];
	NSURL* u = !scheme? nil : [NSURL URLWithString:[NSString stringWithFormat:@"%@:", scheme]];
	if (!u || ![[UIApplication sharedApplication] canOpenURL:u])
		cell.textLabel.textColor = [UIColor grayColor];
	
#if !kILSwapCatalogPlatform_iPad
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
#endif

    return cell;
}



// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary* record = [self.displayedApplications objectAtIndex:[indexPath row]];
	[ILSwapCatalogApp() displayApplicationRegistration:record];
	
	if (keepsLastSelection)
		self.lastSelection = indexPath;
}

- (IBAction) deleteAllItems:(id) sender;
{
	UIActionSheet* a = [[UIActionSheet new] autorelease];
	a.title = NSLocalizedString(@"Do you really want to clear the app catalog for this device?", @"Prompt for delete all items");
	a.destructiveButtonIndex = [a addButtonWithTitle:NSLocalizedString(@"Clear App Catalog", @"Delete all items button")];
	a.cancelButtonIndex = [a addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel button")];
	
	a.delegate = self;
	[ILSwapCatalogApp() showActionSheet:a invokedByBarButtonItem:sender];
}

- (void) actionSheet:(UIActionSheet *)a clickedButtonAtIndex:(NSInteger)buttonIndex;
{
	if (buttonIndex == a.cancelButtonIndex)
		return;
	
	[[ILSwapService sharedService] deleteAllApplicationRegistrations];
	[self reloadData];
}

- (void) reloadData;
{
	NSMutableArray* m = [[[ILSwapService sharedService] internalApplicationRegistrationRecords] mutableCopy];
	[m sortUsingFunction:&ILSwapCatalogPaneCompareRegistrationsAlphabetically context:NULL];
	self.displayedApplications = m;
	[m release];
	
	[self.tableView reloadData];
}

@end


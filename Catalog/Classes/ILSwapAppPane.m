//
//  ILSwapAppPane.m
//  Catalog
//
//  Created by ∞ on 04/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ILSwapAppPane.h"
#import <SwapKit/SwapKit.h>

static NSArray* ILSwapAppPaneCanonicalOrderOfRegistrationKeys() {
	static NSArray* a = nil; if (!a) {
		a = [[NSArray alloc] initWithObjects:
			 kILAppIdentifier,
			 kILAppVisibleName,
			 kILAppVersion,
			 kILAppReceiveItemURLScheme,
			 kILAppSupportedActions,
			 kILAppSupportedReceivedItemsUTIs,
			 kILAppSupportsReceivingMultipleItems,
			 kILAppRegistrationUUID,
			 nil];
	}
	
	return a;
}

static NSString* ILSwapAppPaneLabelForRegistrationKey(NSString* key) {
	static NSDictionary* a = nil; if (!a) {
		a = [[NSDictionary alloc] initWithObjectsAndKeys:
			 NSLocalizedString(@"ID", @"kILAppIdentifier label"), kILAppIdentifier,
			 NSLocalizedString(@"name", @"kILAppVisibleName label"), kILAppVisibleName,
			 NSLocalizedString(@"version", @"kILAppVersion label"), kILAppVersion,
			 NSLocalizedString(@"URL", @"kILAppReceiveItemURLScheme label"), kILAppReceiveItemURLScheme,
			 NSLocalizedString(@"actions", @"kILAppSupportedActions label"), kILAppSupportedActions,
			 NSLocalizedString(@"UTIs", @"kILAppSupportedReceivedItemsUTIs label"), kILAppSupportedReceivedItemsUTIs,
			 NSLocalizedString(@"multiple?", @"kILAppSupportsReceivingMultipleItems label"), kILAppSupportsReceivingMultipleItems,
			 NSLocalizedString(@"UUID", @"kILAppRegistrationUUID label"), kILAppRegistrationUUID,
			 nil];
	}
	
	NSString* label = [a objectForKey:key];
	if (!label)
		label = key;
	return label;
}

static NSComparisonResult ILSwapAppPaneCompareRegistrationKeys(id a, id b, void* context) {
	if ([a isEqual:b])
		return NSOrderedSame;
	
	NSArray* order = ILSwapAppPaneCanonicalOrderOfRegistrationKeys();
	
	NSInteger indexOfA = [order indexOfObject:a];
	NSInteger indexOfB = [order indexOfObject:b];
	
	BOOL hasA = indexOfA != NSNotFound;
	BOOL hasB = indexOfB != NSNotFound;
	
	if (hasA && !hasB)
		return NSOrderedAscending;
	else if (!hasA && hasB)
		return NSOrderedDescending;
	else if (!hasA && !hasB)
		return NSOrderedSame;
	else
		return indexOfA > indexOfB? NSOrderedDescending : NSOrderedAscending;
}


@implementation ILSwapAppPane

- (id) initWithApplicationRegistrationRecord:(NSDictionary*) r;
{
	if (!(self = [self initWithNibName:@"ILSwapAppPane" bundle:nil]))
		return nil;
	
	NSMutableArray* k = [NSMutableArray arrayWithArray:[r allKeys]];
	[k sortUsingFunction:&ILSwapAppPaneCompareRegistrationKeys context:NULL];
	
	NSMutableArray* v = [NSMutableArray arrayWithCapacity:[k count]];
	for (NSString* key in k)
		[v addObject:[r objectForKey:key]];
	
	keys = [k copy];
	values = [v copy];
	
	self.title = [r objectForKey:kILAppVisibleName];
	
	return self;
}

- (void) dealloc
{
	[keys release];
	[values release];
	[super dealloc];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [keys count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
    
	NSString* key = ILSwapAppPaneLabelForRegistrationKey([keys objectAtIndex:[indexPath row]]);
	NSString* value = [[values objectAtIndex:[indexPath row]] description];
    cell.textLabel.text = key;
	cell.detailTextLabel.text = value;
	
    return cell;
}

@end


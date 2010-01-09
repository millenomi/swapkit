//
//  ILSwapAppPane.m
//  Catalog
//
//  Created by ∞ on 04/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ILSwapAppPane.h"

#import <SwapKit/SwapKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "ILSwapSendText.h"

@interface ILSwapPickKindActionSheet : UIActionSheet
{
	NSString* sendingType;
}

- (id) initWithSendingType:(NSString*) sendingType;
@property(readonly) NSString* sendingType;

@end

@implementation ILSwapPickKindActionSheet

- (id) initWithSendingType:(NSString*) t;
{
	if (!(self = [super init]))
		return nil;
	
	sendingType = [t copy];
	
	self.title = [NSString stringWithFormat:
			   NSLocalizedString(@"Choose what to send as an item of type '%@':", @"Format for item kind action sheet title"), t];
	
	// kILSwapSendText
	[self addButtonWithTitle:NSLocalizedString(@"Text (NSString)", @"Text button in item kind action sheet")];
	
	self.cancelButtonIndex = [self addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel button")];
	
	return self;
}

@synthesize sendingType;

- (void) dealloc
{
	[sendingType release];
	[super dealloc];
}

@end



@interface ILSwapAppPane ()

- (UITableViewCell*) valueOnlyCellWithText:(NSString*) text fromTable:(UITableView*) tv identifier:(NSString*) ident;
- (UITableViewCell*) noValuesCellForTable:(UITableView*) tv identifier:(NSString*) ident;
- (UITableViewCell*) cellForType:(NSString*) type fromTable:(UITableView*) tv identifier:(NSString*) ident;

@end

enum {
	kILSwapAppSectionInfo,
	kILSwapAppSectionActions,
	kILSwapAppSectionTypes,
};

enum {
	kILSwapSendText,
	// kILSwapSendImage,
};


static NSArray* ILSwapAppPaneCanonicalOrderOfRegistrationKeys() {
	static NSArray* a = nil; if (!a) {
		a = [[NSArray alloc] initWithObjects:
			 kILAppIdentifier,
			 kILAppVisibleName,
			 kILAppVersion,
			 kILAppReceiveItemURLScheme,
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
	
	record = [r copy];
	
	NSMutableArray* k = [NSMutableArray arrayWithArray:[r allKeys]];
	[k removeObject:kILAppSupportedActions];
	[k removeObject:kILAppSupportedReceivedItemsUTIs];
	[k sortUsingFunction:&ILSwapAppPaneCompareRegistrationKeys context:NULL];
	
	NSMutableArray* v = [NSMutableArray arrayWithCapacity:[k count]];
	for (NSString* key in k)
		[v addObject:[r objectForKey:key]];
	
	keys = [k copy];
	values = [v copy];
	
	actions = [L0As(NSArray, [r objectForKey:kILAppSupportedActions]) mutableCopy];
	types = [L0As(NSArray, [r objectForKey:kILAppSupportedReceivedItemsUTIs]) mutableCopy];
	
	self.title = [r objectForKey:kILAppVisibleName];
	
	return self;
}

- (void) dealloc
{
	[record release];
	
	[keys release];
	[values release];
	[actions release];
	[types release];
	
	[super dealloc];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
		case kILSwapAppSectionInfo:
			return [keys count];			
		
		case kILSwapAppSectionActions:
			return actions && [actions count] != 0? [actions count] : 1;

		case kILSwapAppSectionTypes:
			return types && [types count] != 0? [types count] : 1;
			
		default:
			return 0;
	}
	
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* kILSwapAppKeyValueCell = @"keyValueCell";
    static NSString* kILSwapAppValueOnlyCell = @"valueOnlyCell";
    static NSString* kILSwapAppNoValuesCell = @"noValuesCell";
    
	if ([indexPath section] == kILSwapAppSectionInfo) {
	
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kILSwapAppKeyValueCell];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:kILSwapAppKeyValueCell] autorelease];
		}
		
		NSString* key = ILSwapAppPaneLabelForRegistrationKey([keys objectAtIndex:[indexPath row]]);
		NSString* value = [[values objectAtIndex:[indexPath row]] description];
		cell.textLabel.text = key;
		cell.detailTextLabel.text = value;
		cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		return cell;
		
	} else {
		
		switch ([indexPath section]) {
			case kILSwapAppSectionActions:
				if (!actions || [actions count] == 0)
					return [self noValuesCellForTable:tableView identifier:kILSwapAppNoValuesCell];
				else {
					id obj = [actions objectAtIndex:[indexPath row]];
					return [self valueOnlyCellWithText:[obj description] fromTable:tableView identifier:kILSwapAppValueOnlyCell];
				}
					
			case kILSwapAppSectionTypes:
				if (!types || [types count] == 0)
					return [self noValuesCellForTable:tableView identifier:kILSwapAppNoValuesCell];
				else {
					id obj = [types objectAtIndex:[indexPath row]];
					return [self cellForType:[obj description] fromTable:tableView identifier:kILSwapAppValueOnlyCell];
				}

			default:
				return nil; // Unsupported section
		}
		
	}
}

- (UITableViewCell*) valueOnlyCellWithText:(NSString*) text fromTable:(UITableView*) tv identifier:(NSString*) ident;
{
	UITableViewCell* cell = [tv dequeueReusableCellWithIdentifier:ident];
	
	if (!cell)
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident] autorelease];		
	
	cell.textLabel.text = text;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryNone;

	return cell;
}

- (UITableViewCell*) cellForType:(NSString*) type fromTable:(UITableView*) tv identifier:(NSString*) ident;
{
	UITableViewCell* cell = [self valueOnlyCellWithText:type fromTable:tv identifier:ident];
	
	if ([type isEqual:(id) kUTTypeUTF8PlainText])
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	return cell;
}


- (UITableViewCell*) noValuesCellForTable:(UITableView*) tv identifier:(NSString*) ident;
{
	UITableViewCell* cell = [tv dequeueReusableCellWithIdentifier:ident];

	if (!cell) 
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident] autorelease];
		
	cell.textLabel.text = NSLocalizedString(@"No values", @"No values cell label");
	cell.textLabel.textColor = [UIColor grayColor];
	cell.textLabel.textAlignment = UITextAlignmentCenter;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	return cell;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
	switch (section) {
		case 1:
			return NSLocalizedString(@"Actions", @"Actions section in app pane");
		case 2:
			return NSLocalizedString(@"Accepted types", @"UTI section in app pane");
			
		default:
			return nil;
	}
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
	if ([indexPath section] == kILSwapAppSectionTypes) {
		NSString* obj = L0As(NSString, [types objectAtIndex:[indexPath row]]);
		
		if ([obj isEqual:(id) kUTTypeUTF8PlainText]) {
			
			ILSwapSendText* t = [[[ILSwapSendText alloc] initWithApplicationIdentifier:[record objectForKey:kILAppIdentifier] type:obj] autorelease];
			[self.navigationController pushViewController:t animated:YES];
			
		} else if (obj) {
			ILSwapPickKindActionSheet* s = [[[ILSwapPickKindActionSheet alloc] initWithSendingType:obj] autorelease];
			s.delegate = self;
			[s showInView:self.view];
		}
	}
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
	switch (buttonIndex) {
		case kILSwapSendText: {
			ILSwapPickKindActionSheet* a = (ILSwapPickKindActionSheet*) actionSheet;
			
			ILSwapSendText* t = [[[ILSwapSendText alloc] initWithApplicationIdentifier:[record objectForKey:kILAppIdentifier] type:a.sendingType] autorelease];
			[self.navigationController pushViewController:t animated:YES];			
		} 
			break;
			
		default:
			break;
	}
	
	NSIndexPath* p = [self.tableView indexPathForSelectedRow];
	if (p)
		[self.tableView deselectRowAtIndexPath:p animated:YES];
}

@end


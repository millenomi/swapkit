//
//  ILSwapAppPane.h
//  Catalog
//
//  Created by ∞ on 04/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ILSwapAppPane : UITableViewController <UIActionSheetDelegate> {
	NSDictionary* record;
	NSArray* keys;
	NSArray* values;
	
	NSArray* actions, * types;
}

- (id) initWithApplicationRegistrationRecord:(NSDictionary*) record;

@end

//
//  ILSwapAppPane.h
//  Catalog
//
//  Created by ∞ on 04/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ILSwapAppPane : UITableViewController {
	NSArray* keys;
	NSArray* values;
}

- (id) initWithApplicationRegistrationRecord:(NSDictionary*) record;

@end

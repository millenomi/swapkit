//
//  ILSwapBinding.h
//  SwapKit
//
//  Created by ∞ on 27/02/10.
//  Copyright 2010 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ILSwapBinding : NSObject {
	NSDictionary* registrations;
	
	NSArray* items;
	NSString* action;
	BOOL allowMatchingThisApplication;
	
	NSArray* appropriateApplications;
	BOOL canSend;
}

+ binding;
- (id) initWithRegistrations:(NSDictionary*) regs;

@property(nonatomic, copy) NSArray* items;
@property(nonatomic, copy) NSString* action;
@property(nonatomic) BOOL allowMatchingThisApplication; // default is NO

@property(nonatomic, readonly) NSArray* appropriateApplications;
@property(nonatomic, readonly) BOOL canSend;

@end

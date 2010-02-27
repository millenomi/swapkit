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
}

+ binding;
- (id) initWithRegistrations:(NSDictionary*) regs;

@property(copy) NSArray* items;
@property(copy) NSString* action;

@property(readonly) NSArray* appropriateApplications;
@property(readonly) BOOL canSend;

@end

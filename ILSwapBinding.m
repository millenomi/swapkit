//
//  ILSwapBinding.m
//  SwapKit
//
//  Created by ∞ on 27/02/10.
//  Copyright 2010 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import "ILSwapBinding.h"
#import "ILSwapService.h"

@implementation ILSwapBinding

+ binding;
{
	return [[[self alloc] initWithRegistrations:[ILSwapService sharedService].applicationRegistrations] autorelease];
}

- (id) initWithRegistrations:(NSDictionary*) regs;
{
	if (self = [super init])
		registrations = [regs copy];
	
	return self;
}

- (void) dealloc
{
	[registrations release];
	[super dealloc];
}



@end

//
//  ILSwapKitGuards.h
//  SwapKit
//
//  Created by ∞ on 31/12/09.
//  Copyright 2009 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import <Foundation/Foundation.h>

extern BOOL ILSwapKitShouldThrowExceptionOnGuardTrip();
extern BOOL ILSwapKitGuardsShouldBeVerbose();

extern void ILSwapKitGuardWrongNumberOfItemsAfterRegistration(NSInteger expected, NSInteger actual);


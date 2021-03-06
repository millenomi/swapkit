//
//  ILSwapKitGuards.m
//  SwapKit
//
//  Created by ∞ on 31/12/09.
//  Copyright 2009 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import "ILSwapKitGuards.h"

#define ILSwapKitGuardLog(x, ...) NSLog(@"<SwapKit> " x, ## __VA_ARGS__)

static void ILSwapKitGuardTripped(NSString* exceptionMessage, const char* guardFunctionName) {
	NSString* message = [NSString stringWithFormat:@"<SwapKit> Postcondition mismatch. %@ (to catch in your code, place a breakpoint on '%s'.)", exceptionMessage, guardFunctionName];
	
	if (ILSwapKitShouldThrowExceptionOnGuardTrip())
		[NSException raise:@"ILSwapKitInconsistencyException" format:@"%@", message];
	else
		NSLog(@"%@", message);
}

BOOL ILSwapKitShouldThrowExceptionOnGuardTrip() {
#if DEBUG
	return [L0As(NSNumber, [[[NSProcessInfo processInfo] environment] objectForKey:@"ILSwapKitShouldThrowExceptionOnGuardTrip"]) boolValue];
#else
	return NO;
#endif
}

BOOL ILSwapKitGuardsShouldBeVerbose() {
#if DEBUG
	return YES;
#else
	return [L0As(NSNumber, [[[NSProcessInfo processInfo] environment] objectForKey:@"ILSwapKitGuardsShouldBeVerbose"]) boolValue];
#endif
}

void ILSwapKitGuardWrongNumberOfItemsAfterRegistration(NSInteger expected, NSInteger actual) {
	if (ILSwapKitGuardsShouldBeVerbose())
		ILSwapKitGuardLog(@"Performed app registration. Expected items in app catalog = %d, Actual = %d", expected, actual);
	
	if (expected != actual) {
		NSString* message = [NSString stringWithFormat:@"Expected a different number of items after registration than what was found (found %d, expected %d). This is probably an indication of a bug in the app catalog registration code ([ILSwapKit registerWithAttributes:]).", actual, expected];
		ILSwapKitGuardTripped(message, __func__);
	}
}

void ILSwapKitGuardBundleNotFoundInResources() {
	ILSwapKitGuardTripped(@"Expected to find SwapKit resource bundle, but couldn't. You should have embedded SwapKit.bundle or SwapKit.framework in your application (usually by copying it as a resource), or used ILSwapKitSetBundle() to set where the bundle is.", __func__);
}


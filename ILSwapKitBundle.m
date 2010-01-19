//
//  ILSwapKitBundle.m
//  SwapKit
//
//  Created by ∞ on 19/01/10.
//  Copyright 2010 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import "ILSwapKitBundle.h"
#import "ILSwapKitGuards.h"

static NSBundle* ILSwapKitBundleObject = nil;
static BOOL ILSwapKitBundleChecked = NO;

NSBundle* ILSwapKitBundle() {
	if (!ILSwapKitBundleObject) {
		if (!ILSwapKitBundleChecked) {
			NSString* path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"SwapKit.framework"];

			NSFileManager* fm = [NSFileManager defaultManager];
			BOOL isDir;
			if (![fm fileExistsAtPath:path isDirectory:&isDir] || !isDir) {
				
				path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"SwapKit.bundle"];
				if (![fm fileExistsAtPath:path isDirectory:&isDir] || !isDir)
					path = nil;
			
			}
			
			if (path)
				ILSwapKitBundleObject = [[NSBundle bundleWithPath:path] retain];
			else
				ILSwapKitGuardBundleNotFoundInResources();
			
			ILSwapKitBundleChecked = YES;
		}
	}
	
	return ILSwapKitBundleObject;
}

extern void ILSwapKitSetBundle(NSBundle* bundle) {
	if (bundle != ILSwapKitBundleObject) {
		[ILSwapKitBundleObject release];
		ILSwapKitBundleObject = [bundle retain];
		
		if (!bundle)
			ILSwapKitBundleChecked = NO;
	}
}

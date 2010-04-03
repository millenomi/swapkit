    //
//  ILDummyVC.m
//  Catalog
//
//  Created by ∞ on 31/01/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ILAutorotatingViewController.h"
#import "ILSwapCatalogAppDelegate.h"

@implementation ILAutorotatingViewController

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) o;
{
	return UIInterfaceOrientationIsPortrait(o) || [ILSwapCatalogApp() shouldSupportAdditionalOrientation:o forViewController:self];
}

@end

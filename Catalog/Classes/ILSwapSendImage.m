//
//  ILSwapSendImage.m
//  Catalog
//
//  Created by ∞ on 31/01/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ILSwapSendImage.h"
#import <SwapKit/SwapKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "ILSwapCatalogAppDelegate.h"

@implementation ILSwapSendImage

@synthesize application, type, actualImageType, delegate;

- (void) dealloc
{
	imagePicker.delegate = nil;	
	[imagePicker release];
	
	popover.delegate = nil;
	[popover release];
	
	[application release];
	[type release];
	[actualImageType release];
	[super dealloc];
}

- (void) sendFromView:(UIView*) v inViewController:(UIViewController*) c;
{
	[self retain];
	
	if (imagePicker)
		return;
	
	imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	imagePicker.mediaTypes = [NSArray arrayWithObject:(id) kUTTypeImage];
	
	if (ILSwapIsiPad() && NSClassFromString(@"UIPopoverController")) {
		if (popover)
			return;
		
		popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
		popover.delegate = self;
		[popover presentPopoverFromRect:v.bounds inView:v permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	} else
		[c presentModalViewController:imagePicker animated:YES];
}

- (void) finishPicking;
{
	imagePicker.delegate = nil;
	popover.delegate = nil;
	[delegate didFinishPickingImage:self];
	[self autorelease];
}	

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
	if (popover) {
		popover.delegate = nil;
		[popover dismissPopoverAnimated:YES];
	} else
		[picker dismissModalViewControllerAnimated:YES];
	
	[self finishPicking];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
{
	UIImage* i = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	if (i) {
		// TODO check .actualImageType
		NSData* d = UIImagePNGRepresentation(i);
		
		[[ILSwapService sharedService] sendItem:d ofType:(id) kUTTypePNG forAction:nil toApplicationWithIdentifier:[application objectForKey:kILAppIdentifier]];
	}
	
	if (popover) {
		popover.delegate = nil;
		[popover dismissPopoverAnimated:YES];
	} else
		[picker dismissModalViewControllerAnimated:YES];
	
	[self finishPicking];
}

- (void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController;
{
	[self finishPicking];
}

@end

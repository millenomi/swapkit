//
//  SendingSampleAppDelegate.m
//  SendingSample
//
//  Created by ∞ on 27/12/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "SendingSampleAppDelegate.h"
#import <SwapKit/SwapKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface SendingSampleAppDelegate ()
- (void) sendWithImage:(UIImage *)i;
@end

@implementation SendingSampleAppDelegate

@synthesize window;


- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
{

	[ILSwapService didFinishLaunchingWithOptions:launchOptions];
    
	[window addSubview:rootController.view];
	[window makeKeyAndVisible];
	doneButton.enabled = NO;
	 
	return YES;
}

- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url;
{
	return [ILSwapService handleOpenURL:url];
}


- (void)dealloc {
    [window release];
    [super dealloc];
}

- (IBAction) send;
{
	UIActionSheet* sheet = [[UIActionSheet new] autorelease];
	sheet.title = @"What should be sent?";
	[sheet addButtonWithTitle:@"Just the text"];
	[sheet addButtonWithTitle:@"Text + Image"];
	sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
	
	sheet.delegate = self;
	[sheet showInView:window];
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
	if (buttonIndex == actionSheet.cancelButtonIndex)
		return;
	
	switch (buttonIndex) {
		case 0:
			[self sendWithImage:nil];
			break;
		case 1: {
		
			UIImagePickerController* picker = [[UIImagePickerController new] autorelease];
			picker.delegate = self;
			
			[rootController presentModalViewController:picker animated:YES];
			
		}
		break;
	}
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
	[picker dismissModalViewControllerAnimated:YES];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
{
	UIImage* i = [info objectForKey:UIImagePickerControllerOriginalImage];
	if (i)
		[self sendWithImage:i];
	
	[picker dismissModalViewControllerAnimated:YES];
}

- (void) sendWithImage:(UIImage*) i;
{
	NSMutableArray* items = [NSMutableArray array];
	
	ILSwapMutableItem* item = [ILSwapMutableItem item];
	item.value = loremIpsumView.text;
	item.attributes = [NSDictionary dictionaryWithObjectsAndKeys:
					   @"From Sender…", kILSwapItemTitleAttribute,
					   nil];
	item.type = (id) kUTTypeUTF8PlainText;
	
	[items addObject:item];
	
	if (i) {
		item = [ILSwapMutableItem item];
		item.value = i;
		item.type = (id) kUTTypePNG;
		[items addObject:item];
	}
	
	ILSwapSendController* sender = [ILSwapSendController controllerForSendingItems:items forAction:nil];
	[sender send];
}

- (IBAction) done;
{
	[loremIpsumView resignFirstResponder];
}

- (void) textViewDidBeginEditing:(UITextView *)textView;
{
	doneButton.enabled = YES;
}

- (void) textViewDidEndEditing:(UITextView *)textView;
{
	doneButton.enabled = NO;
}

@end

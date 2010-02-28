//
//  ILSwapSendText.m
//  Catalog
//
//  Created by ∞ on 07/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ILSwapSendText.h"

#import <SwapKit/SwapKit.h>


@implementation ILSwapSendText

- (id) initWithApplicationIdentifier:(NSString*) a type:(NSString*) t;
{
	if (!(self = [super initWithNibName:@"ILSwapSendText" bundle:nil]))
		return nil;
	
	self.title = NSLocalizedString(@"Send Text", @"Send text pane title");
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", @"Send button") style:UIBarButtonItemStyleBordered target:self action:@selector(send)] autorelease];
	
	app = [a copy];
	type = [t copy];
	
	return self;
}

- (void) dealloc
{
	[app release];
	[type release];
	[super dealloc];
}


- (void) viewDidUnload;
{
	[textView release];
	textView = nil;
}

- (void) viewWillAppear:(BOOL)animated;
{
	[super viewWillAppear:animated];
	if (animated)
		[textView flashScrollIndicators];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	[textView becomeFirstResponder];
}

- (void) viewWillDisappear:(BOOL)animated;
{
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void) keyboardDidShow:(NSNotification*) n;
{
	CGPoint p = L0UIKeyboardGetOriginForKeyInView(n, UIKeyboardCenterEndUserInfoKey, textView);
	
	CGRect f = textView.frame;
	f.size.height = p.y;
	textView.frame = f;
}

- (void) keyboardWillHide:(NSNotification*) n;
{
	textView.frame = self.view.bounds;
}


- (void) send;
{
	[[ILSwapService sharedService] sendItem:[ILSwapItem itemWithValue:textView.text type:type attributes:nil] forAction:nil toApplicationWithIdentifier:app];
}

@end

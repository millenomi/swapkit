//
//  ILSwapSendImage.h
//  Catalog
//
//  Created by ∞ on 31/01/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ILSwapSendImage;
@protocol ILSwapSendImageDelegate <NSObject>

- (void) didFinishPickingImage:(ILSwapSendImage*) i;

@end


@interface ILSwapSendImage : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate
#if kILSwapCatalogPlatform_iPad
	, UIPopoverControllerDelegate
#endif
> {
	NSDictionary* application;
	NSString* type;
	NSString* actualImageType;
	
	id <ILSwapSendImageDelegate> delegate;
	
	UIImagePickerController* imagePicker;
#if kILSwapCatalogPlatform_iPad
	UIPopoverController* popover;
#endif
}

@property(copy) NSDictionary* application;
@property(copy) NSString* type;
@property(copy) NSString* actualImageType;

@property(assign) id <ILSwapSendImageDelegate> delegate;

- (void) sendFromView:(UIView*) v inViewController:(UIViewController*) c;

@end

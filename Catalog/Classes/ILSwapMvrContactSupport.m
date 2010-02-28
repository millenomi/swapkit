//
//  ILSwapMvrContactSupport.h
//  SwapKit
//
//  Created by ∞ on 07/02/10.

/*
 
 The MIT License
 
 Copyright (c) 2009 Emanuele Vulcano ("∞labs")
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */
 
#import "ILSwapMvrContactSupport.h"

#define kMvrContactMultiValueItemValue @"L0AddressBookValue"
#define kMvrContactMultiValueItemLabel @"L0AddressBookLabel"

#define kMvrContactProperties @"L0AddressBookPersonInfoProperties"
#define kMvrContactImageData @"L0AddressBookPersonInfoImageData"


static void MvrEnsureABFrameworkIsLoaded() {
	static BOOL initialized = NO; if (!initialized) {
		ABAddressBookRef ab = ABAddressBookCreate();
		CFRelease(ab);
		// this causes constants to have the right value and such.
	}
}

// We use this to iterate among known AB properties.
#define kMvrCountOfABProperties (23) // sizeof(properties) / sizeof(ABPropertyID);

static ABPropertyID MvrGetABPropertyAtIndex(int idx) {
	static ABPropertyID L0AddressBookProperties[kMvrCountOfABProperties];
	static BOOL initialized = NO;
	
	if (!initialized) {
		MvrEnsureABFrameworkIsLoaded();
		
		ABPropertyID properties[] = {
			kABPersonFirstNameProperty,
			kABPersonLastNameProperty,
			kABPersonMiddleNameProperty,
			kABPersonPrefixProperty,
			kABPersonSuffixProperty,
			kABPersonNicknameProperty,
			kABPersonFirstNamePhoneticProperty,
			kABPersonLastNamePhoneticProperty,
			kABPersonMiddleNamePhoneticProperty,
			kABPersonOrganizationProperty,
			kABPersonJobTitleProperty,
			kABPersonDepartmentProperty,
			kABPersonEmailProperty,
			kABPersonBirthdayProperty,
			kABPersonNoteProperty,
			kABPersonCreationDateProperty,
			kABPersonModificationDateProperty,
			kABPersonAddressProperty,
			kABPersonDateProperty,
			kABPersonKindProperty,
			kABPersonPhoneProperty,
			kABPersonInstantMessageProperty,
			kABPersonURLProperty,
			kABPersonRelatedNamesProperty
		};
		
		L0CLog(@"kABPersonLastNameProperty == %d at %p", kABPersonLastNameProperty, &kABPersonLastNameProperty);
		
		int i; for (i = 0; i < kMvrCountOfABProperties; i++)
			L0AddressBookProperties[i] = properties[i];
		
		initialized = YES;
	}
	
	return L0AddressBookProperties[idx];
}

static id MvrKeyForABProperty(ABPropertyID prop) {
	return [NSString stringWithFormat:@"%d", prop];
}

#define MvrIsABMultiValueType(propertyType) (( (propertyType) & kABMultiValueMask ) != 0)

@implementation ILSwapItem (ILSwapMvrContactSupport)

+ (ILSwapItem*) moverContactItemFromPersonRecord:(ABRecordRef) record;
{
    NSMutableDictionary* info = [NSMutableDictionary dictionary];
	
	int i; for (i = 0; i < kMvrCountOfABProperties; i++) {
		ABPropertyID propertyID = MvrGetABPropertyAtIndex(i);
		
		ABPropertyType t = ABPersonGetTypeOfProperty(propertyID);
		if (!MvrIsABMultiValueType(t)) {
			// we simply lift the value from the record -- since
			// all nonmulti are, or should be, property list types, that's fine.
			
			id value = (id) ABRecordCopyValue(record, propertyID);
			if (value)
				[info setObject:value forKey:MvrKeyForABProperty(propertyID)];
			
			[value release];
		} else {
			// multis are transformed into arrays of dictionaries.
			// (this is fine because NSArray is not one of the types
			// used by the AB framework).
			
			NSMutableArray* multiTransposed = [NSMutableArray array];
			ABMultiValueRef multi = ABRecordCopyValue(record, propertyID);
			
			NSArray* values = (NSArray*) ABMultiValueCopyArrayOfAllValues(multi);
			int valueIndex = 0;
			for (id value in values) {
				id label = (id) ABMultiValueCopyLabelAtIndex(multi, valueIndex);
				if (!label) label = [@"-" retain]; // balances the release below
				NSDictionary* item = [NSDictionary dictionaryWithObjectsAndKeys:
									  value, kMvrContactMultiValueItemValue,
									  label, kMvrContactMultiValueItemLabel,
									  nil];
				[multiTransposed addObject:item];
				[label release];
				valueIndex++;
			}
			[values release];
			
			[info setObject:multiTransposed forKey:MvrKeyForABProperty(propertyID)];
			CFRelease(multi);
		}
	}
	
	NSMutableDictionary* person = [NSMutableDictionary dictionary];
	[person setObject:info forKey:kMvrContactProperties];
	
	if (ABPersonHasImageData(record)) {
		NSData* data = (NSData*) ABPersonCopyImageData(record);
		if (data)
			[person setObject:data forKey:kMvrContactImageData];
		[data release];
	}
	
	return [ILSwapItem itemWithValue:person type:kMvrContactAsPropertyListType attributes:nil];
}

- (ABRecordRef) copyPersonRecordFromMoverContactItem;
{
	id personInfoDictionary = self.propertyListValue;
	if (!personInfoDictionary || ![personInfoDictionary isKindOfClass:[NSDictionary class]])
		return NULL;
	
	NSDictionary* info = [personInfoDictionary objectForKey:kMvrContactProperties];
	if (!info)
		return NULL;
	
	ABRecordRef person = ABPersonCreate();
	
	for (NSString* propertyIDString in info) {
		ABPropertyID propertyID = [propertyIDString intValue];
		id propValue = [info objectForKey:propertyIDString];
		
		CFTypeRef setValue;
		BOOL shouldReleaseSetValue = NO;
		if (![propValue isKindOfClass:[NSArray class]]) 
			setValue = (CFTypeRef) propValue;
		else {
			ABPropertyType propertyType = ABPersonGetTypeOfProperty(propertyID);
			ABMultiValueRef multi = ABMultiValueCreateMutable(propertyType);
			
			for (NSDictionary* valuePart in propValue) {
				id multiValue = [valuePart objectForKey:kMvrContactMultiValueItemValue];
				id label = [valuePart objectForKey:kMvrContactMultiValueItemLabel];
				
				ABMultiValueAddValueAndLabel(multi, (CFTypeRef) multiValue, (CFStringRef) label, NULL);
			}
			
			setValue = (CFTypeRef) multi;
			shouldReleaseSetValue = YES;
		}
		
		CFErrorRef error = NULL;
		ABRecordSetValue(person, propertyID, setValue, &error);
		
		if (error) {
			NSLog(@"%@", (id) error);
			CFRelease(error);
		}
		
		if (shouldReleaseSetValue)
			CFRelease(setValue);
	}
	
	NSData* imageData;
	if (imageData = [personInfoDictionary objectForKey:kMvrContactImageData]) {
		CFErrorRef error = NULL;
		
		ABPersonSetImageData(person, (CFDataRef) imageData, &error);
		
		if (error) {
			NSLog(@"%@", (id) error);
			CFRelease(error);
		}
	}
	
	return person;
}

@end

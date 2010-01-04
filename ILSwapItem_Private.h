
#import "ILSwapItem.h"

#define kILSwapItemattributesUTI @"net.infinite-labs.SwapKit.Itemattributes"

@interface ILSwapItem (ILSwapItemPasteboard)

/** @internal */
- (NSDictionary*) pasteboardItemOfType:(NSString*) type;

/** @internal */
- (id) initWithPasteboardItem:(NSDictionary*) d ofType:(NSString*) type;

@end

#import "ILSwapRequest.h"

@interface ILSwapRequest ()

/** @internal */
- (id) initWithPasteboard:(UIPasteboard*) pb attributes:(NSDictionary*) attributes removePasteboardWhenDone:(BOOL) remove;

@end

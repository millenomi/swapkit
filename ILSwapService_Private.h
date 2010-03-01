
#import "ILSwapService.h"

enum {
	kILSwapPasteboardThisSessionOnly,
};
typedef NSInteger ILSwapPasteboardLifetime;


@interface ILSwapService (ILSwapPasteboardLifetime)

- (void) deleteInvalidatedPasteboards;
- (void) managePasteboard:(UIPasteboard*) pb withLifetimePeriod:(ILSwapPasteboardLifetime) lt;

@end


enum {
	kILSwapSendDone,
	kILSwapSendOngoing,
	kILSwapSendError
};
typedef NSInteger ILSwapSendResult;

@interface ILSwapService ()
- (void) sendingFinishedWithResult:(ILSwapSendResult) r;
@end
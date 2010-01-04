// Debug-only code.
// The argument to this macro is only inserted in the final code if DEBUG.
#if DEBUG
#define L0InsertIfDebug(x) do { x } while (0)
#else
#define L0InsertIfDebug(x)
#endif

// Logging.

// Labs logging has three code-selected "levels" of possible logging:
// - Debug-only. This means that the while the logging is useful during coding,
// it must never go in a release build (eg for performance considerations).
// - On request. This is logging that goes into release builds switched off.
// It can be useful for debugging on the field (eg ask user to enable and send
// console content). Note that to implement, this requires an external library,
// and as such lightweight implementations like this .h file fudge it by making it
// always visible or never visible rather than go checking.
// - Always visible. This is for displaying things to the user when it's important
// to do so, and is never switched off, even in compile builds.

// The L0Printf function family implements the above three
// levels for POSIX-only apps by printing via fprintf() and family.
// (L0Log() is used in Objective-C apps instead to print via NSLog()).
// To log, use:
// - Debug-only: L0PrintfDebug()
// - On request: L0Printf()
// - Always visible: L0PrintfAlways()

// There are two impls of the levels, as such:
// -- LIGHTWEIGHT (this .h)
// Maps the three levels as such:
// DEBUG-ONLY => inline printf call if DEBUG, removed otherwise.
// ON REQUEST => inline printf call if DEBUG, removed otherwise.
// ALWAYS VISIBLE => inline printf call.
// -- HEAVYWEIGHT (libLogging.a or libLogging-POSIX.a)
// Maps the three levels as such:
// DEBUG-ONLY => inline printf call if DEBUG, removed otherwise.
// ON REQUEST => inline printf call if DEBUG, calls to the library's implementation otherwise.
// ALWAYS VISIBLE => inline printf call.

// As you can see, using the lightweight impl basically turns on-demand logging into
// debug-only logging. If you want to enable on-demand logging, you must link libLogging*.a
// and define L0LogUseOnRequestLogging=1 to make the implementation defer to that one.

#include <stdio.h>
// This macro should not be referenced outside this .h.
// Use L0Printf, L0PrintfDebug or L0PrintfAlways instead.
#define L0Printf_PerformInline(x, ...) \
	fprintf(stderr, "<DEBUG: %s>: " x, __func__, ## __VA_ARGS__)

#define L0PrintfDebug(x, ...) L0InsertIfDebug(L0Printf_PerformInline(x, ## __VA_ARGS__))
#define L0PrintfAlways(x, ...) L0Printf_PerformInline(x, ## __VA_ARGS__)

// If you define this and don't link to libLogging*, you'll get missing
// symbol errors on link.
#if !L0LogUseOnRequestLogging
// #warning Defining L0Printf as L0PrintfDebug -- use libLogging.a instead if you want real on-request logging.
#define L0Printf(x, ...) L0PrintfDebug(x, ## __VA_ARGS__)

// The following emulate equivalent calls in libLogging*, for when it's not used.
#if DEBUG
#define L0PrintfShouldShowOnRequestLogging() 1
#else
#define L0PrintfShouldShowOnRequestLogging() 0
#endif

#endif // !L0LogUseOnRequestLogging

// Conditional logging:
// Same as the L0PrintfDebug() call, except it has an extra parameter for a condition.
// The condition will only be evaluated if the call is actually inserted, that is if DEBUG.
// This is useful if the condition has a long-ish execution time that you can avoid if
// not logging.
// Note that since you must check at runtime whether on-request logging is on, and always
// visible logging is always inserted in the program, this only makes sense with debug
// logging -- use if (L0PrintfShouldShowOnRequestLogging()) { ... } to similarly optimize
// on-request logging.
#define L0PrintfDebugIf(cond, x, ...) L0InsertIfDebug(if (cond) L0Printf_PerformInline(x, ## __VA_ARGS__))

// C linkage qualifier L0QualifyCallAsC
#ifdef __cplusplus
#define L0QualifyCallAsC extern "C"
#else
#define L0QualifyCallAsC extern
#endif

// printf-like marker L0AttributeLikePrintf(indexOfFormatArgument, indexOfFirstValueArgument)
#ifdef __GNUC__
#define L0AttributeLikePrintf(m, n) __attribute__((format(printf,m,n)))
#else
#define L0AttributeLikePrintf(...)
#endif

#if L0LogUseOnRequestLogging && !L0LogIsBuilding
#include <L0Log/L0Printf.h>
#endif

// Required for the __LINE__ uniquing trick.
#define L0ConcatMacroAfterExpanding(a, b) a ## b
#define L0ConcatMacro(a, b) L0ConcatMacroAfterExpanding(a, b)

// Produces a unique pointer constant.	
#define L0UniquePointerConstant(name) \
	static const uint8_t L0ConcatMacro(L0UniqueIntConstant, __LINE__) = 0;\
	static void* name = (void*) &L0ConcatMacro(L0UniqueIntConstant, __LINE__)


#if DEBUG
#define L0DebugTrap(variableName) { \
	volatile BOOL variableName = NO; while(!variableName) sleep(1); \
}
#else
#define L0DebugTrap(variableName) L0__ERROR_DISABLE_DEBUG_TRAP_TO_BUILD__();
#endif

// Logging for debug builds only.

#include "../POSIX/Common.h"

#ifdef __OBJC__

// ===========
// = Logging =
// ===========

// This header sets up L0Log() the same way POSIX/Common.h sets up L0Printf.
// See that header for details.

#import <Foundation/Foundation.h>

#if !kL0LogDisableMacrosAndOnRequest

// This macro should not be referenced outside this .h.
// Use L0Log, L0LogDebug or L0LogAlways instead.
#define L0Log_PerformInline(x, ...) \
	NSLog(@"<DEBUG: %s> " x, __func__, ## __VA_ARGS__)

#if DEBUG
#define L0LogDebug(x, ...) L0Log_PerformInline(x, ## __VA_ARGS__)
#else
#define L0LogDebug(x, ...)
#endif

#define L0LogAlways(x, ...) L0Log_PerformInline(x, ## __VA_ARGS__)

#if !L0LogUseOnRequestLogging
// #warning Defining L0Log as L0LogDebug -- use libLogging.a instead if you want real on-request logging.
#define L0Log(x, ...) L0LogDebug(@"(self: %@)\n" x @"\n\n", self, ## __VA_ARGS__)
#define L0CLog(x, ...) L0LogDebug(x, ## __VA_ARGS__)

// L0LogShouldShowOnRequestLoggingObjC in libLogging* can access defaults,
// not just the environment. Use it if you want to control L0Log rather than L0Printf.
#if DEBUG
#define L0LogShouldShowOnRequestLogging() YES
#else
#define L0LogShouldShowOnRequestLogging() NO
#endif

#else
// This is a hack to build the logging library
#if !L0LogIsBuilding
#include <L0Log/L0Log.h>
#endif
#endif // !L0LogUseOnRequestLogging

#if DEBUG
#define L0LogDebugIf(cond, x, ...) do { if (cond) L0Log_PerformInline(x, ## __VA_ARGS__); } while (0)
#else
#define L0LogDebugIf(...)
#endif

#endif // !kL0LogDisableMacrosAndOnRequest

#define L0Note() L0Log(@" -- entered -- ")

// ==============
// = Assertions =
// ==============

#define L0AssertOutlet(x) NSAssert((x), @"Missing outlet: " #x)

#define L0AbstractMethod() [NSException raise:@"L0AbstractMethodCalledException" format:@"%s was not implemented by a subclass ([self class] = %@)", __func__, [self class]]

// =============
// = Shorthand =
// =============

#define L0ObjCSingletonMethod(name) \
	+ (id) name {\
		static id myself = nil;\
		if (!myself)\
			myself = [[self alloc] init];\
		return myself;\
	}
	
#define L0PrivateSetterNamedForKey(name, type, variable, key, action) \
	- (void) name (type) newValue_ {\
		[self willChangeValueForKey:key];\
		if (newValue_ != variable) {\
			[variable release];\
			variable = [newValue_ action];\
		}\
		[self didChangeValueForKey:key];\
	}
	
#define L0PrivateSetter(name, type, key) \
	L0PrivateSetterNamedForKey(name, type, key, @#key, retain)

#define L0PrivateCopySetter(name, type, key) \
	L0PrivateSetterNamedForKey(name, type, key, @#key, copy)

#define L0PrivateAssignSetterNamedForKey(name, type, variable, key) \
	- (void) name (type) newValue_ {\
		[self willChangeValueForKey:key];\
		variable = newValue_;\
		[self didChangeValueForKey:key];\
	}

#define L0PrivateAssignSetter(name, type, key) \
	L0PrivateAssignSetterNamedForKey(name, type, @#key, key)

#define L0LogAtRetain() \
	- (id) retain;\
	{\
		L0Log(@"Retained.");\
		return [super retain];\
	}

#define L0LogAtRelease() \
	- (oneway void) release;\
	{\
		L0Log(@"Released.");\
		[super release];\
	}
	
#define L0AsClass(cls, value) \
	({ id v_ = (value); \
	  [v_ isKindOfClass:(cls)]? v_ : nil; })
#define L0As(cls, value) \
	L0AsClass([cls class], value)

#define L0SynthesizeUserDefaultsGetter(cls, key, name) \
	- (cls*) name \
	{ \
		id o = [[NSUserDefaults standardUserDefaults] objectForKey:(key)]; \
		if (![o isKindOfClass:[cls class]]) o = nil; \
		return o; \
	} \

#define L0SynthesizeUserDefaultsSetter(cls, key, setterName) \
	- (void) setterName (cls*) v_ \
	{ \
		[[NSUserDefaults standardUserDefaults] setObject:v_ forKey:(key)]; \
	}

#endif // def __OBJC__

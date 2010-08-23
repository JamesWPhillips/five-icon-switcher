
#import <SpringBoard/SpringBoard.h>
#import <UIKit/UIKit.h>

#define idForKeyWithDefault(dict, key, default)	 ([(dict) objectForKey:(key)]?:(default))
#define floatForKeyWithDefault(dict, key, default)   ({ id _result = [(dict) objectForKey:(key)]; (_result)?[_result floatValue]:(default); })
#define NSIntegerForKeyWithDefault(dict, key, default) (NSInteger)({ id _result = [(dict) objectForKey:(key)]; (_result)?[_result integerValue]:(default); })
#define BOOLForKeyWithDefault(dict, key, default)    (BOOL)({ id _result = [(dict) objectForKey:(key)]; (_result)?[_result boolValue]:(default); })

#define PreferencesFilePath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.chpwn.five-icon-switcher.plist"]
#define PreferencesChangedNotification "com.chpwn.five-icon-switcher.prefs"

#define GetPreference(name, type) type ## ForKeyWithDefault(prefsDict, @#name, (name))

@interface SBAppSwitcherBarView : UIView {
	id _delegate;
	int _orientation;
	NSMutableArray *_appIcons;
	UIView *_contentView;
	UIImageView *_backgroundImage;
	UIView *_auxView;
	id _scrollView;
	UIImageView *_topShadowView;
	UIImageView *_bottomShadowView;
}
@property(readonly, retain) NSMutableArray *appIcons;
@property(retain, nonatomic) UIView *auxiliaryView;
@property(assign, nonatomic) id delegate;
+ (unsigned)iconsPerPage:(int)page;
+ (CGSize)viewSize;
- (id)initWithOrientation:(int)orientation;
- (CGPoint)_firstPageOffset;
- (CGRect)_frameForIndex:(unsigned)index withSize:(CGSize)size;
- (void)_iconRemoveDidStop:(id)_iconRemove finished:(id)finished context:(id)context;
- (unsigned)_pageCount;
- (void)_positionAtFirstPage:(BOOL)firstPage;
- (void)_reflowContent:(BOOL)content;
- (void)_setOrientation:(int)orientation;
- (id)applicationIconForDisplayIdentifier:(id)displayIdentifier;
- (void)dealloc;
- (void)didMoveToSuperview;
- (BOOL)isScrollingOrOtherwiseBusy;
- (void)layoutSubviews;
- (BOOL)nowPlayingControlsVisible;
- (void)positionForHidden;
- (void)positionForRevealed;
- (void)prepareForDisplay:(id)display orientation:(int)orientation;
- (void)removeIcon:(id)icon;
- (void)replaceIcons:(id)icons with:(id)with;
- (BOOL)scrollView:(id)view shouldCancelInContentForView:(id)view2;
- (void)scrollViewDidEndScrollingAnimation:(id)scrollView;
- (void)setEditing:(BOOL)editing;
@end

static NSDictionary *prefsDict = nil;

static void preferenceChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[prefsDict release];
	prefsDict = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
}

%hook SBAppSwitcherBarView

+ (unsigned int)iconsPerPage:(int)page {
	return [[prefsDict objectForKey:@"FISIconCount"] intValue] ?: 5;
}

- (CGRect)_frameForIndex:(unsigned)index withSize:(CGSize)size {
	CGRect r = %orig;
	
	int page = index / [[self class] iconsPerPage:0];
	CGFloat gap = (320.0f - (r.size.width * [[self class] iconsPerPage:0])) / ([[self class] iconsPerPage:0] + 1);
	r.origin.x = [self _firstPageOffset].x + gap;
	r.origin.x += (gap + size.width) * index;
	r.origin.x += (gap * page);
	r.origin.x = floorf(r.origin.x);
	
	return r;
}

%end

__attribute__((constructor)) static void fis_init() {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// SpringBoard only!
	if (![[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"])
		return;
		
	prefsDict = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, preferenceChangedCallback, CFSTR(PreferencesChangedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);
	
	[pool release];
}

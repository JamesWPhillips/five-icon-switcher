
#import <SpringBoard/SpringBoard.h>
#import <UIKit/UIKit.h>

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



%hook SBAppSwitcherBarView

+ (unsigned)iconsPerPage:(int)page {
	return 5;
}

- (CGRect)_frameForIndex:(unsigned)index withSize:(CGSize)size {
	CGRect r = %orig;
	
	int page = index / 5;
	CGFloat gap = (320.0f - (r.size.width * 5)) / 6;
	r.origin.x = [self _firstPageOffset].x + gap;
	r.origin.x += (gap + size.width) * index;
	r.origin.x += (gap * page);
	r.origin.x = floorf(r.origin.x);
	
	return r;
}

%end

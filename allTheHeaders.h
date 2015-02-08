#import "FSSwitchDataSource.h"
#import "FSSwitchPanel.h"
#import "CydiaSubstrate.h"
#import "LAListener.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

@interface AnySpotSwitch : NSObject <FSSwitchDataSource>
@end

@interface UIViewController (extras)
@property (getter=_window,nonatomic,readonly) UIWindow * window;
-(id)viewControllerForRotation;
-(unsigned)supportedInterfaceOrientations;
-(id)_embeddedDelegate;
-(id)transitioningDelegate;
-(void)setInterfaceOrientation:(int)arg1 ;
-(id)_window; 
-(BOOL)window:(id)arg1 shouldAutorotateToInterfaceOrientation:(long long)arg2 ;
@end

@interface SBSearchTableView : UITableView
@property(nonatomic) float contentInset;
@end

@interface SBSearchViewController : UIViewController 
+(id)sharedInstance;
-(BOOL)shouldDisplayListLauncher;
-(void)searchGesture:(id)arg1 changedPercentComplete:(float)arg2;
-(BOOL)isVisible;
-(void)loadView;
-(void)cancelButtonPressed;
-(void)searchGesture:(id)arg1 completedShowing:(BOOL)arg2 ;
-(void)_setShowingKeyboard:(BOOL)arg1 ;
-(BOOL)_showingKeyboard;
-(void)_resetViewController;
-(id)_window;
-(void)_fadeForLaunchWithDuration:(double)arg1 completion:(/*^block*/ id)arg2 ;
-(void)window:(id)arg1 willAnimateRotationToInterfaceOrientation:(int)arg2 duration:(double)arg3 ;
-(void)window:(id)arg1 setupWithInterfaceOrientation:(int)arg2 ;
-(BOOL)_forwardRotationMethods;
-(void)_updateTableContents;
-(void)_updateHeaderHeightIfNeeded;
-(void)forceRotation;
-(void)dismiss;
-(BOOL)_hasNoQuery;
-(void)_lockScreenUIWillLock:(BOOL)arg1;
-(void)_rotatePresentingWindowIfNecessaryTo:(long long)arg1 withDuration:(double)arg2 ;
-(void)activeInterfaceOrientationDidChangeToOrientation:(int)activeInterfaceOrientation willAnimateWithDuration:(double)duration fromOrientation:(int)orientation;
-(void)activeInterfaceOrientationWillChangeToOrientation:(int)activeInterfaceOrientation;
-(void)repositionCells;
-(void)forceRotation;
-(void)setHeaderbyChangingFrame:(bool)changeFrame withPushDown:(int)pushDown;
-(void)show;
-(void)createToShow;
-(void)_searchFieldEditingChanged;
-(void)_updateClipping;
-(void)_updateCellClipping:(id)arg1 ;
- (void)maskCell:(UITableViewCell *)cell fromTopWithMargin:(CGFloat)margin;
- (CAGradientLayer *)visibilityMaskForCell:(UITableViewCell *)cell withLocation:(CGFloat)location;
-(void)dismissAnimated:(BOOL)arg1 completionBlock:(/*^block*/id)arg2 ;

@end

@interface NSConcreteNotification
+(id)notificationWithName:(id)arg1 object:(id)arg2 ;
-(id)initWithName:(id)arg1 object:(id)arg2 userInfo:(id)arg3 ;
@end

@interface SBSearchHeader : UIView
-(void)searchGesture:(id)arg1 changedPercentComplete:(float)arg2 ;
-(UITextField *)searchField;
@end

@interface SBSearchModel
-(id)launchingURLForResult:(id)arg1 withDisplayIdentifier:(id)arg2 andSection:(id)arg3;
@end

@interface SBApplication
-(id)contextHostViewForRequester:(id)requester enableAndOrderFront:(BOOL)front;
@end

@interface SpringBoard
-(void)_menuButtonUp:(id)arg1;
-(void)_revealSpotlight;
-(void)quitTopApplication:(id)arg1 ;
-(void)applicationSuspend:(id)arg1 ;
-(BOOL)isLocked;
-(BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2 ;
-(void)_rotateView:(id)arg1 toOrientation:(int)arg2;
-(void)showSpringBoardStatusBar;
-(id)statusBar;
-(int)interfaceOrientationForCurrentDeviceOrientation;
-(void)noteInterfaceOrientationChanged:(int)arg1 duration:(float)arg2 ;
-(id)_accessibilityFrontMostApplication;
-(id)_accessibilityTopDisplay;
-(id)_accessibilityRunningApplications;
-(int)_frontMostAppOrientation;
-(void)_revealSpotlight;

@end

@interface UIApplication (extras)
-(id)_accessibilityFrontMostApplication;
-(id)_accessibilityTopDisplay;
-(id)_accessibilityRunningApplications;
-(BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2 ;
@end

@interface SBSearchResultsBackdropView : UIView
@end

@interface UIWindow (extras)
+(void)setAllWindowsKeepContextInBackground:(BOOL)arg1;
-(BOOL)isInternalWindow;
-(void)setDelegate:(id)arg1 ;
-(id)_clientsForRotation;
-(void)setContentView:(id)arg1 ;
-(void)_setRotatableViewOrientation:(int)arg1 duration:(double)arg2 force:(BOOL)arg3 ;
-(int)_windowInterfaceOrientation;
-(void)setAutorotates:(BOOL)arg1 ;
-(void)_addRotationViewController:(id)arg1 ;
-(id)contentView;
-(id)delegate;
-(void)_updateInterfaceOrientationFromDeviceOrientationIfRotationEnabled:(BOOL)arg1 ;
-(void)_updateToInterfaceOrientation:(int)arg1 animated:(BOOL)arg2 ;
-(void)_updateToInterfaceOrientation:(int)arg1 duration:(double)arg2 force:(BOOL)arg3 ;
-(void)makeKeyAndOrderFront:(id)arg1 ;
-(int)interfaceOrientation;
@end

@interface SBRootFolderView : UIView
-(void)setOrientation:(int)arg1 ;
-(id)delegate;
-(id)_viewDelegate;
@end

@interface SBSearchGesture
+(id)sharedInstance;
-(void)revealAnimated:(BOOL)arg1 ;
-(void)resetAnimated:(BOOL)arg1;
-(void)updateForRotation;
-(void)setTargetView:(id)arg1 ;
@end

@interface SBSearchGestureObserver
-(void)searchGesture:(id)arg1 changedPercentComplete:(float)arg2;
@end

@interface SBIcon
-(void)launchFromLocation:(int)arg1 ;
-(id)badgeNumberOrString;
@end

@interface SBApplicationIcon : SBIcon
@end

@interface SBLockScreenManager 
+(id)sharedInstance;
-(id)lockScreenViewController;
-(void)_finishUIUnlockFromSource:(int)arg1 withOptions:(id)arg2;
@end 

@interface UIStatusBar
-(id)statusBarWindow;
-(void)setHidden:(BOOL)arg1 ;
-(void)setStatusBarWindow:(id)arg1 ;
@end

@interface _UIBackdropViewSettings
+(id)settingsForStyle:(long long)arg1 ;
@end

@interface SBlockScreenViewControllerBase
-(void)setPasscodeLockVisible:(BOOL)arg1 animated:(BOOL)arg2;
@end

@interface SBNotificationCenter
-(void)dismissAnimated:(BOOL)arg1;
@end

@interface SBWallpaperEffectView : UIView 
-(void)setStyle:(int)arg1;
@end

@interface SBUIController
+(id)sharedInstance;
-(BOOL)isAppSwitcherShowing;
@end

@interface SBIconScrollView : UIScrollView
@end

@interface AnySpotUIViewController : UIViewController
@end

@interface SBRootFolderController : UIViewController
-(void)setOrientation:(int)arg1 ;
-(void)willAnimateRotationToInterfaceOrientation:(int)arg1 ;
@end

@interface UIView (extras)
-(void)_updateContentSizeConstraints;
@end

@interface _UIBackdropView : UIView
-(void)setStyle:(int)arg1 ;
-(id)initWithStyle:(int)arg1 ;
-(id)initWithSettings:(id)arg1 ;
-(id)initWithFrame:(CGRect)arg1 autosizesToFitSuperview:(BOOL)arg2 settings:(id)arg3 ;
-(void)setBlursWithHardEdges:(BOOL)arg1 ;
-(void)setBlursBackground:(BOOL)arg1 ;
-(void)setBlurRadius:(double)arg1 ;
-(void)setBlurRadiusSetOnce:(BOOL)arg1 ;
@end

// Convergance support
@interface CVResources : NSObject
+(BOOL)lockScreenEnabled;
@end

@interface SBOrientationLockManager : NSObject
+(id)sharedInstance;
- (void)enableLockOverrideForReason:(id)arg1 forceOrientation:(long long)arg2;
@end

@interface ALApplicationList 
@property (nonatomic, readonly) NSDictionary *applications;
-(id)sharedApplicationList;
- (id)valueForKey:(NSString *)keyPath forDisplayIdentifier:(NSString *)displayIdentifier;
-(NSInteger)applicationCount;
- (UIImage *)iconOfSize:(int)iconSize forDisplayIdentifier:(NSString *)displayIdentifier;
@end

@interface SBIconModel
-(id)expectedIconForDisplayIdentifier:(id)arg1 ;
@end

@interface SBIconController
-(id)sharedInstance;
-(SBIconModel *)model;
@end

@interface UINavigationController (extras)
-(void)_setUseCurrentStatusBarHeight:(BOOL)arg1 ;
-(void)_setUseStandardStatusBarHeight:(BOOL)arg1 ;
@end

@interface UINavigationBar (extras)
-(void)_setBackgroundView:(id)arg1 ;
-(void)_updateBackgroundColor;
-(void)_setBarPosition:(long long)arg1 ;
-(void)_barSizeDidChangeAndSoDidHeight:(BOOL)arg1 ;
@end

@interface SBAppSwitcherModel : NSObject {
	NSMutableArray* _recentDisplayIdentifiers;
}
+(id) sharedInstance;
-(id)_recentFromPrefs;
-(void)_saveRecents;
-(void)appsRemoved:(id)arg1 added:(id)arg2;
-(id)snapshot;
-(id)snapshotOfFlattenedArrayOfAppIdentifiersWhichIsOnlyTemporary;
-(void)remove:(id)arg1;
@end

@interface SPSearchResult
-(id)initWithData:(id)arg1 ;
-(void)setTitle:(id)arg1 ;
-(void)setUrl:(id)arg1 ;
-(NSString *)url;
@end

@interface SBSearchResultsAction
-(SPSearchResult *)result;
@end

@interface SBSearchTableViewCell : UITableViewCell {
	float _leftSeparatorMargin;
}
+(void)initialize;
-(void)setTitle:(id)arg1;
-(void)setFirstInSection:(BOOL)arg1 ;
-(void)setIsLastInSection:(BOOL)arg1 ;
-(void)setTitleImage:(id)arg1 animated:(BOOL)arg2 ;
-(void)setHasImage:(BOOL)arg1 ;
@property (assign) float leftSeparatorMargin; 
@property (nonatomic,readonly) UIView * background;  
-(void)setLeftSeparatorMargin:(float)arg1 ;
-(void)updateConstraints;
-(void)clipToTopHeaderWithHeight:(float)arg1 inTableView:(id)arg2 ;
-(UIView *)clippingContainer;
- (void)maskCellFromTop:(CGFloat)margin;
- (CAGradientLayer *)visibilityMaskWithLocation:(CGFloat)location;
@property (nonatomic,readonly) NSArray * constantConstraints; 
@property (nonatomic,readonly) NSArray * variableConstraints; 
@end

@interface SBSearchStandardCell : SBSearchTableViewCell
@property (nonatomic,readonly) UILabel* titleLabel; 
+(id)unreadImage;
@property (nonatomic,readonly) UIImageView * vipBadge;                           //@synthesize vipBadge=_vipBadge - In the implementation block
-(float)leftTextMargin;
-(void)updateLabel:(id)arg1 withValue:(id)arg2 ;
-(void)updateFonts;
-(id)leftTextView;
-(UIView *)leftView;
@property (nonatomic,readonly) UILabel * auxiliaryTitleLabel;                    //@synthesize auxiliaryTitleLabel=_auxiliaryTitleLabel - In the implementation block
@property (nonatomic,readonly) UILabel * auxiliarySubtitleLabel; 
@property (nonatomic,readonly) UILabel * subtitleLabel; 
@property (nonatomic,readonly) UILabel * summaryLabel; 
@property (nonatomic,readonly) UIImageView * unreadBadge;                        //@synthesize unreadBadge=_unreadBadge - In the implementation block

@end

@interface SBSearchImageCell : SBSearchStandardCell  {
	UIImageView* _titleImageView;
}
@property (nonatomic,readonly) UILabel* titleLabel; 
@property (nonatomic,readonly) UIImageView* titleImageView;
+(id)placeHolderImageForDomain:(unsigned)arg1 result:(id)arg2 size:(CGSize)arg3 ;
-(void)updateWithSection:(id)arg1 result:(id)arg2 traitCollection:(id)arg3 ;
-(void)setTitleTextAttributes:(id)arg1 ;
- (id)leftTextView;
- (id)leftView;
- (id)variableConstraints;
- (id)constantConstraints;
-(id)recursiveDescription;
@end




@interface SBSearchTableHeaderView : UIView 
-(void)setTitle:(id)arg1;
-(id)initWithReuseIdentifier:(id)arg1 ;
-(id)separatorView;
-(id)recursiveDescription;
@end

@interface SBNotificationCenterViewController : UIViewController
-(void)presentGrabberView;
@end

@interface SBNotificationCenterController
-(void)beginPresentationWithTouchLocation:(CGPoint)arg1 ;
-(void)presentAnimated:(BOOL)arg1 ;

@end


@interface LAActivator
-(id)hasSeenListenerWithName:(id)arg1;
-(id)assignEvent:(id)arg1 toListenerWithName:(id)arg2;
-(id)registerListener:(id)arg1 forName:(id)arg2;
@end

@interface LAEvent
+(id)eventWithName:(id)arg1; 
-(void)setHandled:(BOOL)arg1;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *mode;
@property (nonatomic, getter=isHandled) BOOL handled;
@property (nonatomic, copy) NSDictionary *userInfo;
@end

@interface SearchLightActivator : NSObject <LAListener>
@end

@interface SBApplicationController {
	NSMutableDictionary* _applicationsByBundleIdentifer;
}
+(id)sharedInstance;
-(id)allApplications;
@end

@interface SBBacklightController
- (void)_resetLockScreenIdleTimerWithDuration:(double)delay mode:(int)mode;
- (double)_currentLockScreenIdleTimerInterval;
-(id)sharedInstance;
-(void)resetLockScreenIdleTimer;
@end

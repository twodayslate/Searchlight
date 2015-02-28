#import "allTheHeaders.h"

static ALApplicationList *applicationList = nil;
static NSArray *sortedDisplayIdentifiers = nil;
static NSArray *enabledSections = nil;
static NSMutableArray *favoritesDisplayIdentifiers = nil;
static NSMutableArray *listLauncherDisplayIdentifiers = nil;
static NSMutableArray *recentApplications = nil;
static int maxRecent = 3; 
static NSString *recentName = @"RECENT";
static NSString *applicationListName = @"APPLICATION LIST";
static NSString *favoritesName = @"FAVORITES";
static NSString *lockscreenIdentifier = nil;
static NSString *applicationIdentifier = nil;
static _UIBackdropView *background = nil;
static int headerStyle = 2060;
static bool logging, hideKeyboard, selectall, replace_nc, show_badges, clearResults, changeHeader = false;
static bool force_rotation, ls_enabled, blur_section_header_enabled = true;
static NSCache *nameCache = [NSCache new];
static NSCache *iconCache = [NSCache new];

static NSMutableArray *indexValues = nil;
static NSMutableArray *indexPositions = nil; 

static UIWindow *window = nil;
static UIWindow *originalWindow = nil;
static SBRootFolderView *fv = nil; 
static SBRootFolderController *fvd = nil;
static UIView *gesTargetview = nil;

static int beforeWindowLevel = -1;

static SearchlightViewController *cusViewController = nil;

static bool didAddViewController, didNotAddViewController, statusBarWasHidden = NO;


static void createAlphabet() {
	if(logging) NSLog(@"ListLauncher7 - Inside createAlphabet");
	NSMutableArray *baseAlphabet = [NSMutableArray arrayWithObjects:@"#",@"A",@"B",@"C",@"D",@"E",@"F",@"G", @"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",nil];
	indexValues = [[@[] mutableCopy] retain];

	if([enabledSections containsObject:@"Application List"]) {

		if(logging) NSLog(@"enabledSections = %@",enabledSections);

		for(id spec in enabledSections) {
			if([spec isEqual:@"Recent"]) {
				[indexValues insertObject:@"▢" atIndex:[indexValues count]];
			} else if([spec isEqual:@"Favorites"]) {
				[indexValues insertObject:@"☆" atIndex:[indexValues count]];
			} else {
				NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-Z]" options:0 error:NULL];
				NSString *firstAppName = [[applicationList valueForKey:@"displayName" forDisplayIdentifier:[listLauncherDisplayIdentifiers objectAtIndex:0]] substringToIndex:1];
				NSTextCheckingResult *match = [regex firstMatchInString:firstAppName options:0 range:NSMakeRange(0, [firstAppName length])];
				if(match) { NSLog(@" removed first inside"); 
					[baseAlphabet removeObjectAtIndex:0];
				}
				for(id letter in baseAlphabet) {
					[indexValues insertObject:letter atIndex:[indexValues count]];
				}
			}
		}

		if(logging) NSLog(@"base index values have been created");

		if(logging) NSLog(@"indexValues = %@",indexValues);

		indexPositions = [[NSMutableArray arrayWithArray:indexValues] retain]; 

		//NSMutableArray *copyOfIndexes = [NSMutableArray arrayWithArray:indexValues]; 

		for(int i = 0; i < [indexValues count]; i++) {
			if([[indexValues objectAtIndex:i] isEqual:@"▢"] || [[indexValues objectAtIndex:i] isEqual:@"☆"] || [[indexValues objectAtIndex:i] isEqual:@"#"]) {
				[indexPositions replaceObjectAtIndex:i withObject:[[NSNumber alloc] initWithInt:i]];
			} else {
				BOOL hasLetter = NO; 
				for(int j = 0; j < [listLauncherDisplayIdentifiers count]; j++) {
					if([[[applicationList valueForKey:@"displayName" forDisplayIdentifier:[listLauncherDisplayIdentifiers objectAtIndex:j]] uppercaseString] hasPrefix:[indexValues objectAtIndex:i]]) {
						[indexPositions replaceObjectAtIndex:i withObject:[[NSNumber alloc] initWithInt:j]];
						hasLetter = YES;
						if(logging) NSLog(@"has letter = %@",[indexValues objectAtIndex:i]);
						break;
					}
				}
				if(!hasLetter) {
					if(logging) NSLog(@"does NOT have letter = %@",[indexValues objectAtIndex:i]);
					[indexValues removeObjectAtIndex:i];
					[indexPositions removeObjectAtIndex:i];
					i = 0;
				}
			}
		}

		if(logging) NSLog(@"done with the awesome loop");
		if(logging) NSLog(@"indexValues = %@",indexValues);
		if(logging) NSLog(@"indexPositions = %@",indexPositions);

	}
}

static void setApplicationListDisplayIdentifiers (NSMutableDictionary *settings) {
	if(logging) NSLog(@"inside setApplicationListDisplayIdentifiers");
	listLauncherDisplayIdentifiers = [[NSMutableArray arrayWithArray:sortedDisplayIdentifiers] retain];
	NSArray *disabledApps = [settings objectForKey:@"disabled"] ?: @[];

	for(id spec in disabledApps) {
		[listLauncherDisplayIdentifiers removeObject:spec];
	}
	[disabledApps release];
}

static void setFavorites (NSMutableDictionary *settings) {
	if(logging) NSLog(@"inside setFavorites");
	favoritesDisplayIdentifiers = [(NSMutableArray *) [settings valueForKey:@"myfavorites"] retain];
	// NSMutableArray *favoriteList = [(NSMutableArray *) [settings valueForKey:@"favorites"] retain];
	// favoriteList =  [[favoriteList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
	//     return 	[[obj1 objectAtIndex:1] integerValue] > [[obj2 objectAtIndex:1] integerValue]	;}] mutableCopy];
	// for(id spec in favoriteList) {
	// 	[favoritesDisplayIdentifiers insertObject:[spec objectAtIndex:0] atIndex:[favoritesDisplayIdentifiers count]];
	// }
	// [favoriteList release];

}

static void generateAppList () {
	NSString *plistPath = @"/var/mobile/Library/Preferences/org.thebigboss.searchlight.applist.plist";
	NSMutableDictionary *appsettings = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
	if(!appsettings) {
			appsettings = [NSMutableDictionary dictionary];
			[appsettings writeToFile:plistPath atomically:YES];
	}
	[appsettings setValue:sortedDisplayIdentifiers forKey:@"applications"];
	[appsettings writeToFile:plistPath atomically:YES];
}

static void loadPrefs() {

	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/org.thebigboss.searchlight.plist"];

	logging = [settings objectForKey:@"logging_enabled"] ? [[settings objectForKey:@"logging_enabled"] boolValue] : NO;

	if(logging) NSLog(@"Searchlight Settings = %@",settings);

	hideKeyboard = [settings objectForKey:@"hide_keyboard"] ? [[settings objectForKey:@"hide_keyboard"] boolValue] : NO;

	selectall = [settings objectForKey:@"hide_keyboard"] ? [[settings objectForKey:@"selectall"] boolValue] : NO;

	headerStyle = [settings objectForKey:@"header_style"] ? [[settings objectForKey:@"header_style"] integerValue] : 2060;
	
	force_rotation = [settings objectForKey:@"rotation_enabled"] ? [[settings objectForKey:@"rotation_enabled"] boolValue] : YES;
	
	replace_nc = [settings objectForKey:@"nc_replace_enabled"] ? [[settings objectForKey:@"nc_replace_enabled"] boolValue] : NO;
	show_badges = [settings objectForKey:@"show_badges"] ? [[settings objectForKey:@"show_badges"] boolValue] : NO;
	
	ls_enabled = [settings objectForKey:@"ls_enabled"] ? [[settings objectForKey:@"ls_enabled"] boolValue] : YES;
	
	blur_section_header_enabled = [settings objectForKey:@"blur_section_header_enabled"] ? [[settings objectForKey:@"blur_section_header_enabled"] boolValue] : YES;
	clearResults = [settings objectForKey:@"clearResults"] ? [[settings objectForKey:@"clearResults"] boolValue] : NO;
	changeHeader = [settings objectForKey:@"changeHeader"] ? [[settings objectForKey:@"changeHeader"] boolValue] : NO;


	enabledSections = [settings objectForKey:@"enabledSections"] ?: @[]; [enabledSections retain];
    maxRecent = [settings objectForKey:@"maxRecent"] ? [[settings objectForKey:@"maxRecent"] integerValue] : 3;
	applicationList = [[ALApplicationList sharedApplicationList] retain];
	recentName = [settings objectForKey:@"recentName"] ?: recentName; recentName = [recentName isEqual:@""] ? @"RECENT" : recentName;
	applicationListName = [settings objectForKey:@"applicationListName"] ?: applicationListName; applicationListName = [applicationListName isEqual:@""] ? @"APPLICATION LIST" : applicationListName;
	favoritesName = [settings objectForKey:@"favoriteName"] ?: favoritesName; favoritesName = [favoritesName isEqual:@""] ? @"FAVORITES" : favoritesName;


	//sortedDisplayIdentifiers = [[[applicationList.applications allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
	//    return [[applicationList.applications objectForKey:obj1] caseInsensitiveCompare:[applicationList.applications objectForKey:obj2]];}] retain];

	NSDictionary *tempApplications = applicationList.applications;
	sortedDisplayIdentifiers = [[[tempApplications allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
	   return [[tempApplications objectForKey:obj1] caseInsensitiveCompare:[tempApplications objectForKey:obj2]];}] retain];


	setApplicationListDisplayIdentifiers(settings);

	setFavorites(settings);

	if(logging) NSLog(@"favorites = %@",favoritesDisplayIdentifiers);

	createAlphabet();

	if(logging) NSLog(@"Done creating alphabet");
	
	

	generateAppList();

	//[[%c(SBSearchViewController) sharedInstance] setHeaderbyChangingFrame:NO withPushDown:20];


	SBAppSwitcherModel *switcherModel = [%c(SBAppSwitcherModel) sharedInstance];
	recentApplications = [[[switcherModel snapshotOfFlattenedArrayOfAppIdentifiersWhichIsOnlyTemporary] mutableCopy] retain];
	//recentApplications = [[[NSMutableArray alloc] initWithArray:[switcherModel snapshotOfFlattenedArrayOfAppIdentifiersWhichIsOnlyTemporary] copyItems:YES] autorelease];

	//NSLog(@"all applications = %@",[[%c(SBApplicationController) sharedInstance] allApplications]);
	//NSMutableDictionary *appdic = MSHookIvar<NSMutableDictionary *>([%c(SBApplicationController) sharedInstance], "_applicationsByBundleIdentifer");
	//NSLog(@"applciation dictionary = %@",appdic);
	//NSLog(@"recent apps = %@", recentApplications);
	NSLog(@"snapshot = %@",[[%c(SBAppSwitcherModel) sharedInstance] snapshot]);
	NSLog(@"class of snapshot = %@",[[[%c(SBAppSwitcherModel) sharedInstance] snapshot] class]);
	//dictionary of "<SBDisplayLayout: 0x170838540> {\n    SBDisplayLayoutDisplayItemsPlistKey =     (\n                {\n            SBDisplayItemDisplayIdentifierPlistKey = \"com.apple.Preferences\";\n            SBDisplayItemTypePlistKey = App;\n        }\n    );\n    SBDisplayLayoutSizePlistKey =     (\n        0\n    );\n}",




	if(logging) NSLog(@"Done with settings");
}

static void savePrefs() {
	loadPrefs();
	SBSearchViewController *sview = [%c(SBSearchViewController) sharedInstance];
	//[sview _updateTableContents];
	UITableView *stable = MSHookIvar<UITableView *>(sview, "_tableView");
	[stable reloadData];
}

@implementation CustomTransitionAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.3f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    // Grab the from and to view controllers from the context
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    // Set our ending frame. We'll modify this later if we have to
    CGRect endFrame = [[UIScreen mainScreen] bounds];
    
    SBSearchHeader *sheader = MSHookIvar<SBSearchHeader *>([%c(SBSearchViewController) sharedInstance], "_searchHeader");
    UITableView *tableView = MSHookIvar<UITableView *>([%c(SBSearchViewController) sharedInstance], "_tableView");
    SBSearchResultsBackdropView *backDrop = MSHookIvar<SBSearchResultsBackdropView *>([%c(SBSearchViewController) sharedInstance], "_tableBackdrop");


    if (self.presenting) {
        //fromViewController.view.userInteractionEnabled = NO;
        
        [transitionContext.containerView addSubview:fromViewController.view];
        [transitionContext.containerView addSubview:toViewController.view];
        
        CGRect startFrame = endFrame;
        startFrame.origin.y -= 64;
        
        toViewController.view.frame = startFrame;
        sheader.alpha = 1.0;
        tableView.alpha = 0.3;
        backDrop.alpha = 0.3;

        [UIView animateWithDuration:0.1f animations:^{
            fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
            toViewController.view.frame = endFrame;
            tableView.alpha = 0.6;
        	backDrop.alpha = 0.6;
        } completion:^(BOOL finished) {
        	[UIView animateWithDuration:[self transitionDuration:transitionContext]-0.1f animations:^{
	        	tableView.alpha = 1.0;
        		backDrop.alpha = 1.0;
	        } completion:^(BOOL finished) {
	            [transitionContext completeTransition:YES];
	        }];
        }];
        
    }
    else {
        //toViewController.view.userInteractionEnabled = YES;
        
        [transitionContext.containerView addSubview:toViewController.view];
        [transitionContext.containerView addSubview:fromViewController.view];
        
        endFrame.origin.y -= 64;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
            fromViewController.view.frame = endFrame;
            sheader.alpha = 1.0;
       	 	tableView.alpha = 0.0;
        	backDrop.alpha = 0.0;
        } completion:^(BOOL finished) {
        	if([[%c(SpringBoard) sharedApplication].keyWindow.rootViewController isEqual:cusViewController] || cusViewController) {
        		dispatch_async(dispatch_get_main_queue(), ^{
        			//[cusViewController dismissViewControllerAnimated:NO  completion:nil];
					[cusViewController.view removeFromSuperview];
					NSLog(@"this was called");
				});
        		// [cusViewController release];
        		// cusViewController = nil;
        		[%c(SpringBoard) sharedApplication].keyWindow.rootViewController = nil;
        		[%c(SpringBoard) sharedApplication].keyWindow.windowLevel = beforeWindowLevel;
        	} 
        	if(statusBarWasHidden) {
        		[[%c(SpringBoard) sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        		statusBarWasHidden = NO;
        	}
            [transitionContext completeTransition:YES];
        }];
    }
}
@end

@implementation SearchlightViewController
-(BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return (NSUInteger)UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}
@end

%hook SBNotificationCenterViewController
-(void)presentGrabberView {
	if(!replace_nc) %orig;
}
%end

// %hook SBBacklightController
// -(double)_currentLockScreenIdleTimerInterval {
//     if(logging) %log;
//     NSLog(@"orig = %f",(float)%orig);
// 	return %orig;
// }

// -(void)_resetLockScreenIdleTimerWithDuration:(double)delay mode:(int)mode {
//     if(logging) %log;
//     NSLog(@"_currentLockScreenIdleTimerInterval = %f",(float)[self _currentLockScreenIdleTimerInterval]);
// 	%orig;
// }
// %end




%hook SBNotificationCenterController
-(void)beginPresentationWithTouchLocation:(CGPoint)arg1 {
	%log;
	if(!replace_nc) { %orig; } else {
		[[%c(SBSearchViewController) sharedInstance] show];
	}
}

-(void)updateTransitionWithTouchLocation:(CGPoint)arg1 velocity:(CGPoint)arg2 {
	//%log;
	if(!replace_nc) { %orig; } else {
		// double screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
		// //double screenHeight = [UIScreen mainScreen].bounds.size.height;
		// CGFloat y = arg1.y;
		// double ans = y/screenHeight;
		// NSLog(@"screen height = %f",screenHeight);
		// NSLog(@"y = %f",y);
		// NSLog(@"y/screenheight = %f",ans);
		// [[%c(SBSearchViewController) sharedInstance] searchGesture:[%c(SBSearchGesture) sharedInstance] changedPercentComplete:ans];
	}
}
%end


%hook SBSearchViewController

-(void)_searchFieldEditingChanged {
	if(logging) %log;
	%orig;
	[[%c(SBBacklightController) sharedInstance] resetLockScreenIdleTimer];
}

-(void)viewDidLayoutSubviews {
	if(logging) %log;
	%orig;

	static dispatch_once_t initialPreferenceLoadToken;
	dispatch_once(&initialPreferenceLoadToken, ^{
		loadPrefs();
	});

	SBSearchTableView *table = MSHookIvar<SBSearchTableView *>(self, "_tableView");
	table.sectionIndexColor = [UIColor whiteColor]; // text color
	table.sectionIndexTrackingBackgroundColor = [UIColor clearColor]; //bg touched
	table.sectionIndexBackgroundColor = [UIColor clearColor]; //bg touched
	[table reloadData];

	self.modalPresentationStyle = UIModalPresentationCustom;
	self.transitioningDelegate = self;
	//SBSearchTableHeaderView *header = [[%c(SBSearchTableHeaderView) alloc] initWithReuseIdentifier:@"SBSearchTableViewHeaderFooterView"];
	//[table setTableHeaderView:header];
}

-(BOOL)gestureRecognizerShouldBegin:(id)arg1 { %log; return %orig; }

%new
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
   
   CustomTransitionAnimator *animator = [CustomTransitionAnimator new];
   animator.presenting = YES;
   return animator;
}
%new
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
   CustomTransitionAnimator *animator = [CustomTransitionAnimator new];
   return animator;
}


%new
-(void)show {
	UIView *view = MSHookIvar<UIView *>(self, "_view");
	originalWindow = MSHookIvar<UIWindow *>(self, "_presentingWindow");
	UIViewController *vc = MSHookIvar<UIViewController *>(self, "_mainViewController");	
	SBSearchGesture *ges = [%c(SBSearchGesture) sharedInstance];
	id topDisplay = [[%c(SpringBoard) sharedApplication] _accessibilityFrontMostApplication];
	if(!gesTargetview)	gesTargetview = [MSHookIvar<SBIconScrollView *>(ges, "_targetView") retain];
	
	if ([[view superview] isKindOfClass:[%c(SBRootFolderView) class]]) {
		fv = [(SBRootFolderView *)[view superview] retain];
		if([[fv delegate] isKindOfClass:[%c(SBRootFolderController) class]]) 
			fvd = [[fv delegate] retain];
	}

	if(logging) {
		NSLog(@"Searchlight: presenting Window = %@", originalWindow);	
		NSLog(@"Searchlight: main View Controller = %@",vc);
		NSLog(@"Searchlight: frontmostapplication = %@",topDisplay);
		NSLog(@"Searchlight: topDisplay = %@",[[%c(SpringBoard) sharedApplication] _accessibilityTopDisplay]);
		NSLog(@"Searchlight: runningapps = %@",[[%c(SpringBoard) sharedApplication] _accessibilityRunningApplications]);
		NSLog(@"Searchlight: sharedApplication = %@",[%c(SpringBoard) sharedApplication]);
		NSLog(@"Searchlight: keyWindow = %@",[%c(SpringBoard) sharedApplication].keyWindow);
		NSLog(@"Searchlight: keyWindow root view Controller = %@",[UIApplication sharedApplication].keyWindow.rootViewController);
		NSLog(@"Searchlight: keyWindow root view Controller = %@",[%c(SpringBoard) sharedApplication].keyWindow.rootViewController);
		NSLog(@"Searchlight: keyWindow delegate = %@",[[[UIApplication sharedApplication] keyWindow] delegate]);
		NSLog(@"Searchlight: keyWindow delegate = %@",[[[%c(SpringBoard) sharedApplication] keyWindow] delegate]);
		NSLog(@"Searchlght: SBSearchGesture's observers = %@",MSHookIvar<NSHashTable *>(ges, "_observers"));
		NSLog(@"Searchlght: SBSearchGesture's scrollview = %@",MSHookIvar<SBSearchScrollView *>(ges, "_scrollView"));
		NSLog(@"Searchlght: SBSearchGesture's _panGestureRecognizer = %@",MSHookIvar<UIPanGestureRecognizer *>(ges, "_panGestureRecognizer"));


	}

	// HBPassthroughWindow when on homescreen

	if(![[%c(SBSearchViewController) sharedInstance] isVisible] && fv && fvd && gesTargetview) {
		if([%c(SpringBoard) sharedApplication].keyWindow) {
			if(!topDisplay && [[%c(SpringBoard) sharedApplication].keyWindow isKindOfClass:%c(SBAppWindow)] && 
					![(SpringBoard*)[%c(SpringBoard) sharedApplication] isLocked] && 
					![[%c(SBUIController) sharedInstance] isAppSwitcherShowing]) {

				// is on homescreen
				NSLog(@"Searchlight: on home screen!");
				[[%c(SpringBoard) sharedApplication] _revealSpotlight];

			} else if(![%c(SpringBoard) sharedApplication].keyWindow.rootViewController) {

				NSLog(@"Searchlight: setting rootViewController to Search");
				NSLog(@"Searchlight:window.level = %f",[%c(SpringBoard) sharedApplication].keyWindow.windowLevel);
				UIStatusBar *status = [(SpringBoard *)[%c(SpringBoard) sharedApplication] statusBar];
				NSLog(@"statusbar = %f",((UIWindow *)[status statusBarWindow]).windowLevel);

				NSLog(@"Searchlight: statusbar.windowLevel %f",UIWindowLevelStatusBar);
				beforeWindowLevel = [%c(SpringBoard) sharedApplication].keyWindow.windowLevel;
				[%c(SpringBoard) sharedApplication].keyWindow.windowLevel = ((UIWindow *)[status statusBarWindow]).windowLevel - 1;
				if(!cusViewController)
					cusViewController = [[SearchlightViewController alloc] init];
				if(logging) NSLog(@"Searchlight: about to set root controller");
				NSLog(@"cusViewControllerWindow = %@",cusViewController.window);
				NSLog(@"cusViewControllerWindowLevel = %f",cusViewController.window.windowLevel);
				
				//UINavigationController *navController = MSHookIvar<UINavigationController *>([%c(SBSearchViewController) sharedInstance], "_navigationController");
				
				@try {
					//[ges setTargetView:[%c(SpringBoard) sharedApplication].keyWindow];

					[%c(SpringBoard) sharedApplication].keyWindow.rootViewController = cusViewController;
					[ges revealAnimated:YES];

					if([UIApplication sharedApplication].statusBarHidden) {
						statusBarWasHidden = YES;
						NSLog(@"Searchlight: statusbar is hidden");
						[[%c(SpringBoard) sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
					}

					[cusViewController presentViewController:self animated:YES completion:^{
						if([UIApplication sharedApplication].statusBarHidden) {
							statusBarWasHidden = YES;
							NSLog(@"Searchlight: statusbar is hidden - trying again");
							[[%c(SpringBoard) sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
						}
					}];

					 // this is needed for it to actually show

					[ges revealAnimated:YES];
					didAddViewController = YES;
				} @catch (NSException * e) {
					NSLog(@"Searchlight: error! = %@",e);
					if(statusBarWasHidden) {
						statusBarWasHidden = NO;
						[[%c(SpringBoard) sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
					}
					[[%c(SBSearchGesture) sharedInstance] resetAnimated:YES];
					[[%c(SBSearchViewController) sharedInstance] _fadeOutAndHideKeyboardAnimated:YES completionBlock:nil];
				}

				
			}
			else {
				@try {
					//[ges setTargetView:[%c(SpringBoard) sharedApplication].keyWindow];

					if([UIApplication sharedApplication].statusBarHidden) {
						NSLog(@"Searchlight: setting rootViewController to Search");
						NSLog(@"Searchlight:window.level = %f",[%c(SpringBoard) sharedApplication].keyWindow.windowLevel);
						UIStatusBar *status = [(SpringBoard *)[%c(SpringBoard) sharedApplication] statusBar];
						NSLog(@"statusbar = %f",((UIWindow *)[status statusBarWindow]).windowLevel);
						beforeWindowLevel = [%c(SpringBoard) sharedApplication].keyWindow.windowLevel;
						NSLog(@"Searchlight: statusbar.windowLevel %f",UIWindowLevelStatusBar);
						// window.windowLevel = UIWindowLevelStatusBar - 5; //one less than the statusbar
						[%c(SpringBoard) sharedApplication].keyWindow.windowLevel = ((UIWindow *)[status statusBarWindow]).windowLevel - 1;
						statusBarWasHidden = YES;
						NSLog(@"Searchlight: statusbar is hidden");
						[[%c(SpringBoard) sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
					}

					if(logging) NSLog(@"Searchlight: Attempting to present view controller");
					[(UIViewController *)[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:self animated:YES completion:^{
					}];

					[ges revealAnimated:YES];

					didNotAddViewController = YES;

				} @catch (NSException * e) {
					NSLog(@"Searchlight: error! = %@",e);
					if(statusBarWasHidden) {
						statusBarWasHidden = NO;
						[[%c(SpringBoard) sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
					}
					[[%c(SBSearchGesture) sharedInstance] resetAnimated:YES];
					[[%c(SBSearchViewController) sharedInstance] _fadeOutAndHideKeyboardAnimated:YES completionBlock:nil];
				}
				
			}
		}
	}
}


%new
-(void)forceRotation {
	if(force_rotation) {
		float orientation = [(SpringBoard *)[%c(SpringBoard) sharedApplication] interfaceOrientationForCurrentDeviceOrientation];
		NSLog(@"rotatating to %f",orientation);
		
		//is on the home screen so open in the orientation of the icons
		id topDisplay = [[%c(SpringBoard) sharedApplication] _accessibilityFrontMostApplication];
		if(fv && !topDisplay && [[%c(SpringBoard) sharedApplication].keyWindow isKindOfClass:%c(SBAppWindow)] && 
			![(SpringBoard*)[%c(SpringBoard) sharedApplication] isLocked] && 
			![[%c(SBUIController) sharedInstance] isAppSwitcherShowing]) {
				NSLog(@"fv orientation = %f",(float)fv.orientation);
				if(fv.orientation >= 0.0) {
					orientation = fv.orientation;
				}
		}

	     [UIView animateWithDuration:0.5f animations:^{
	     	switch((int)orientation) {
		     	case 1: { // normal
		     		self.view.transform = CGAffineTransformMakeRotation(0);
		     		self.view.frame = [UIScreen mainScreen].bounds;
		     		break;
		     	}
		     	case 2: { //upside down = good
		     		self.view.transform = CGAffineTransformMakeRotation(M_PI);
		     		self.view.frame = [UIScreen mainScreen].bounds;
		     		break;
		     	}
		     	case 3: { // left = good
		     		self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
		     		self.view.frame = [UIScreen mainScreen].bounds;
		     		break;
		     	}
		     	default:  {//4 = right
		     		self.view.transform = CGAffineTransformMakeRotation(M_PI + M_PI_2);
		     		self.view.frame = [UIScreen mainScreen].bounds;
		     		break;
		     	}
		     } 
	     } completion:^(BOOL finished){
	     	[[%c(SBSearchViewController) sharedInstance] setHeaderBackground];
	     }];
	     
	}
}

%new
-(void)setHeaderBackground {
	UINavigationController *nav = MSHookIvar<UINavigationController *>([%c(SBSearchViewController) sharedInstance], "_navigationController");
	if(logging) {
		NSLog(@"before");
		NSLog(@"navigation controller view = %@",nav.view);
		NSLog(@"navigation controller bar = %@",nav.navigationBar);
	}

	
			// nav.navigationBar.clipsToBounds = NO;
			// nav.edgesForExtendedLayout = UIRectEdgeNone;
			// nav.automaticallyAdjustsScrollViewInsets = NO;	

	if(changeHeader) {
		for(UIView *subview in [nav.navigationBar subviews]) {
			if([subview isKindOfClass:[%c(SBWallpaperEffectView) class]]) {
				NSLog(@"SBwallpapereffectview = %@",subview);
				//subview.alpha = 0.0;
				[subview removeFromSuperview];
				//[(SBWallpaperEffectView *)subview setStyle:0];
				// Creating blur view using settings object

			}
		}
		if(background) {
			[background removeFromSuperview];
		}
		
		_UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForStyle:headerStyle];

	// initialization of the blur view
		background = [[_UIBackdropView alloc] initWithFrame:CGRectMake(0,-20,nav.navigationBar.frame.size.width,nav.navigationBar.frame.size.height+20) autosizesToFitSuperview:NO settings:settings];
		//[nav.navigationBar _setBackgroundView:background];
		background.clipsToBounds = NO;
		//nav.navigationBar.frame = CGRectMake(0,0,background.frame.size.width,background.frame.size.height+15);
		//nav.navigationBar.frame = CGRectMake(-15,0,background.frame.size.width,background.frame.size.height);
		//background.frame = CGRectMake(-15,0,background.frame.size.width,background.frame.size.height);
		// UIView *bgview = MSHookIvar<UIView *>(nav.navigationBar, "_backgroundView");
		// bgview = background;

		[nav.navigationBar insertSubview:background atIndex:0];
	}




	//[nav.navigationBar addSubview:background];
	// [nav.navigationBar setBarStyle:UIBarStyleBlack];
	//[nav.navigationBar _setBarPosition:UIBarPositionTopAttached];
	if(logging) {
		NSLog(@"after");
		NSLog(@"navigation controller view = %@",nav.view);
		NSLog(@"navigation bar = %@",nav.navigationBar);
		NSLog(@"navigation bar frame = %@",NSStringFromCGRect(nav.navigationBar.frame));
		NSLog(@"nav background frame = %@",NSStringFromCGRect(background.frame));
	}

	//[[%c(SBSearchViewController) sharedInstance] repositionCells];
	//[[%c(SBSearchViewController) sharedInstance] _updateHeaderHeightIfNeeded];
}

%new 
- (UIStatusBarStyle) preferredStatusBarStyle { 
    return UIStatusBarStyleLightContent; 
}


%new 
-(BOOL)shouldDisplayListLauncher {
	return [self _hasNoQuery] && [enabledSections count] > 0;
}

%new 
- (BOOL) prefersStatusBarHidden {
    return NO;
}

%new 
-(id)applicationList { return applicationList; }
%new 
-(id)sortedDisplayIdentifiers { return sortedDisplayIdentifiers; }

-(id)getIndex {
	return nil;
}

-(void)loadView {
	%orig;
	//[[%c(SBSearchViewController) sharedInstance] setHeaderbyChangingFrame:YES withPushDown:20];
}

-(BOOL)_showFirstTimeView { return false; }

%new
-(id)sectionIndexTitlesForTableView:(UITableView *)arg1 {
	if(logging) %log;
	if([self shouldDisplayListLauncher]) return indexValues;
	return nil;
}

-(void)searchGesture:(id)arg1 changedPercentComplete:(double)arg2 {
	if(logging) %log;
	%orig;
	//[[%c(SBSearchViewController) sharedInstance] repositionCells];
}

-(void)searchGesture:(id)arg1 completedShowing:(BOOL)arg2  {
	if(logging) %log;

	// https://github.com/Shrugs/ClearOnOpen with permission
	if(clearResults) {
		SBSearchHeader *sheader = MSHookIvar<SBSearchHeader *>([%c(SBSearchViewController) sharedInstance], "_searchHeader");
		sheader.searchField.text = @"";
		[self _searchFieldEditingChanged];
	}


	%orig;

	if(arg2) {
		[[%c(SBSearchViewController) sharedInstance] forceRotation];
		//UINavigationController *nav = MSHookIvar<UINavigationController *>([%c(SBSearchViewController) sharedInstance], "_navigationController");
		[[%c(SBSearchViewController) sharedInstance] setHeaderBackground];
		if(![[%c(SBSearchViewController) sharedInstance] _showingKeyboard] && !hideKeyboard) {
			[[%c(SBSearchViewController) sharedInstance] _setShowingKeyboard:YES];	
			SBSearchHeader *sheader = MSHookIvar<SBSearchHeader *>([%c(SBSearchViewController) sharedInstance], "_searchHeader");
			if(logging) NSLog(@"can become first responder? = %f",(float)[sheader.searchField canBecomeFirstResponder]);
			[sheader.searchField becomeFirstResponder];
		}
		//[[%c(SBSearchViewController) sharedInstance] repositionCells];
	}
	
}

-(void)_setShowingKeyboard:(BOOL)arg1 {
	if(arg1 && hideKeyboard) {
		return;
	}

	%orig;

	// if(arg1 && selectall) {
	// 	SBSearchHeader *sheader = MSHookIvar<SBSearchHeader *>(self, "_searchHeader");
	// 	if(![[sheader searchField].text isEqual:@""]) {
	// 		[[sheader searchField] selectAll:self];
	// 	}
	// }
}

-(int)tableView:(UITableView *)arg1 numberOfRowsInSection:(int)arg2 {
	if(logging) %log;
	if([self shouldDisplayListLauncher]) {
		NSLog(@"should display");
		@try {
			if(enabledSections && [enabledSections count] > arg2)  {
				if([[enabledSections objectAtIndex:arg2] isEqual:@"Application List"]) {
					if(logging) NSLog(@"inside application list");
					//NSLog(@"will return = %f",(float)[listLauncherDisplayIdentifiers count]);
					return [listLauncherDisplayIdentifiers count];
				} else if([[enabledSections objectAtIndex:arg2] isEqual:@"Favorites"]) {
					if(logging) NSLog(@"inside fav");
					return [favoritesDisplayIdentifiers count];
				} else if([[enabledSections objectAtIndex:arg2] isEqual:@"Recent"]) {
					if(logging) NSLog(@"inside recent");
					if(maxRecent > [recentApplications count]) return [recentApplications count];
					return maxRecent;
				}
			}
		}
		@catch (NSException * e) {
			NSLog(@"error! = %@",e);
			return 0;
		}
		
	}

	return %orig;
}

-(int)numberOfSectionsInTableView:(id)arg1 	{
	if(logging) %log;
	if([self shouldDisplayListLauncher]) {
		return [enabledSections count];
	}
	return %orig;
}

%new
-(int)tableView:(UITableView *)tableview sectionForSectionIndexTitle:(id)title atIndex:(int)index {
	if(logging) %log;

	int appSection = [enabledSections indexOfObject:@"Application List"];
	int recentSection = [enabledSections indexOfObject:@"Recent"];
	int favoriteSection = [enabledSections indexOfObject:@"Favorites"];


	SBSearchHeader *sheader = MSHookIvar<SBSearchHeader *>([%c(SBSearchViewController) sharedInstance], "_searchHeader");
	[sheader.searchField resignFirstResponder];


	if([title isEqual:@"▢"]) {
		return recentSection;
	} else if([title isEqual:@"☆"]) {
		return favoriteSection;
	} else {
		if(logging) NSLog(@"jump to (%@,%d) for title %@ at index %d",[indexPositions objectAtIndex:index],(int)appSection,title,index);
		if([title isEqualToString:@"#"]) return appSection;
		[tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[indexPositions objectAtIndex:index] integerValue] inSection:appSection] atScrollPosition:UITableViewScrollPositionTop animated:NO];
		return 99999999; // this allows for scrolling without jumping to some random ass section
	}




	return index;
}

-(BOOL)_hasResults {
	if(logging) %log;
	NSLog(@"number of enabled sections = %f",(float)[enabledSections count]);
	if([self shouldDisplayListLauncher] && [enabledSections count] > 0) {
		NSLog(@"_hasResults = YES");
		return YES;
	}
	return %orig;
}

-(id)tableView:(UITableView *)arg1 cellForRowAtIndexPath:(NSIndexPath *)arg2 {
	if(logging) %log;
	if(arg2.row > [listLauncherDisplayIdentifiers count]-1) { return %orig; } // fix for SpotDefine
	if([self shouldDisplayListLauncher]) {
		NSString *identifier = [@"" retain];

		@try {
			if([[enabledSections objectAtIndex:arg2.section] isEqual:@"Application List"]) {
				if(logging) NSLog(@"inside application list");
				identifier = [listLauncherDisplayIdentifiers objectAtIndex:arg2.row];
			} else if([[enabledSections objectAtIndex:arg2.section] isEqual:@"Favorites"]) {
				if(logging) NSLog(@"inside favs");
				identifier = [favoritesDisplayIdentifiers objectAtIndex:arg2.row];
			} else if([[enabledSections objectAtIndex:arg2.section] isEqual:@"Recent"]) {
				if(logging) NSLog(@"inside recent");
				identifier = [recentApplications objectAtIndex:arg2.row];
			}
		}
		@catch (NSException * e) { 
			NSLog(@"error! %@",e); 
			identifier = @"com.apple.Preferences"; 
		}
		

		NSString *name = @"";
		if ([nameCache objectForKey:identifier] == nil) { // Thanks @daementor
			NSString *value = [applicationList valueForKey:@"displayName" forDisplayIdentifier:identifier]; 
			NSString *newValue = value?value:@"";
			[nameCache setObject:newValue forKey:identifier];
		}
		name = [nameCache objectForKey:identifier];

		SBSearchStandardCell *cell = [arg1 dequeueReusableCellWithIdentifier:@"searchlight"];

		if(cell == nil) {
			//[%c(SBSearchImageCell) initialize];
			cell = [[[%c(SBSearchImageCell) alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"searchlight"] autorelease];
			//cell.titleLabel.frame = CGRectMake(105, cell.titleLabel.frame.origin.y, 0, 0);
			//NSLog(@"titleLabel = %@",cell.titleLabel);
			//cell.contentView.frame = CGRectMake(50, 0, 328, 20.5);
			//cell.leftView.frame = CGRectMake(50, 0, 328, 20.5);
			//[cell.titleLabel setFrame:CGRectMake(44, 16, 328, 20.5)];
			//cell.leftView.frame = CGRectMake(100, 0, 328, 20.5);
			//cell.titleLabel.frame = CGRectMake(100, 0, 328, 20.5);
			// [cell layoutSubviews];
			// CGRect textLabelFrame = cell.textLabel.frame;
			// textLabelFrame.origin.x -= 5;
			// textLabelFrame.size.width += 5;
			// cell.textLabel.frame = textLabelFrame;
			// [cell setNeedsLayout];
    		[cell clipToTopHeaderWithHeight:52.0f inTableView:arg1];
    		cell.layer.masksToBounds = YES;



			UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(48.0f, 3.0f, 150.0f, 20.0f)];
			lbl.text = name;
			lbl.tag = 666;
			lbl.textColor = [UIColor whiteColor];
			[cell.leftView addSubview:lbl];
			//[cell.clippingContainer addSubview:lbl];

			

			UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(-1.0f, -8.0f, 41.5f, 41.5f)];
			imgView.tag = 667;
			[cell.leftView addSubview:imgView];

			if(show_badges) {
				cell.autoresizesSubviews = YES;
				cell.leftView.autoresizesSubviews = YES;
				UILabel *countlbl = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width-75.0f,-11.0,50,50)];
				countlbl.text = @"";
				countlbl.tag = 668;
				countlbl.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f];
				countlbl.font=[countlbl.font fontWithSize:countlbl.font.pointSize - 6];
				countlbl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
				[cell.leftView addSubview:countlbl];
				//[cell.clippingContainer addSubview:countlbl];
			}
			//[cell.clippingContainer addSubview:imgView];
			// Instead of doing this... can make a custom cell and do this: http://stackoverflow.com/a/4209039/193772
			//UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(64.0f, 14.0f, 150.0f, 20.0f)];
			//[cell setBounds:CGRectMake(0.0f, 0.0f, cell.frame.size.width, cell.frame.size.height)];
		}
			
			//UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15.5f, 3.5f, 41.5f, 41.5f)];
		// CGRect cellFrame = cell.frame;
		// cellFrame.size.height = 20;
		// cell.frame = cellFrame;

		// cell.auxiliaryTitleLabel.text = @"title";
		// cell.auxiliarySubtitleLabel.text = @"asubtitle";
		// cell.subtitleLabel.text = @"subtitle";
		// cell.summaryLabel.text = @"summary";
		if(show_badges) {
			UILabel *countlbl = (UILabel *)[cell.leftView viewWithTag:668];
			SBIconController *cont = [%c(SBIconController) sharedInstance];
			SBIconModel *model = [cont model];
			SBIcon *sicon = [model expectedIconForDisplayIdentifier:identifier];
			NSLog(@"icon = %@",sicon);
			NSLog(@"badge = %@",[sicon badgeNumberOrString]);
			//NSLog(@"badge class = @",[[sicon badgeNumberOrString] className]);
			if([sicon badgeNumberOrString]) {
				if([[sicon badgeNumberOrString] isKindOfClass:[NSNumber class]]) {
					if([[sicon badgeNumberOrString] intValue] > 0)
						[countlbl setText:[[sicon badgeNumberOrString] stringValue]];
				}
			}
	    	else {
	    		[countlbl setText:@""];
	    	}
		}	


		CGRect labelFrame = cell.titleLabel.frame;
		labelFrame.origin.y = 10.0f;
		cell.titleLabel.frame = labelFrame;

		[cell updateLabel:cell.titleLabel withValue:@" "];
		//cell.titleLabel.text = name;
		//cell.textLabel.text = name;
		UILabel *lbl = (UILabel *)[cell.leftView viewWithTag:666];
    	[lbl setText:name];
  //   	NSLog(@"systom font size = %f",[UIFont systemFontSize]);
  //   	NSLog(@"label font size = %f",lbl.font.pointSize);
  //   	NSLog(@"titleLabel font size = %f",cell.titleLabel.font.pointSize);
		[lbl setFont:[UIFont systemFontOfSize:cell.titleLabel.font.pointSize]];
		//default = 17


    	CGRect rect = CGRectMake(0,0,26,26);
    	UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    	// CGContextRef context = UIGraphicsGetCurrentContext();
    	// CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
	    UIImage *icon = nil;
		if ([iconCache objectForKey:identifier] == nil) { // Thanks @daementor
			UIImage *tempIcon =  [applicationList iconOfSize:64 forDisplayIdentifier:identifier];
			UIImage *goodIcon = (tempIcon?tempIcon:UIGraphicsGetImageFromCurrentImageContext());
			[iconCache setObject:goodIcon forKey:identifier];
		}
		icon = [iconCache objectForKey:identifier];
	 	//cell.titleImageView.image = icon; 
		//cell.imageView.image = icon;
	    [icon drawInRect:rect];
	    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	    UIGraphicsEndImageContext();

	    UIImageView *actualimgView = MSHookIvar<UIImageView *>(cell, "_titleImageView");
	    actualimgView.frame = CGRectMake(-1.0f, -8.0f, 41.5f, 41.5f);
    	actualimgView.image = img;


    	UIImageView *imgView = (UIImageView *)[cell.leftView viewWithTag:667];

	    rect = CGRectMake(0,0,34,34);
    	UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    	// CGContextRef context = UIGraphicsGetCurrentContext();
    	// CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
	 	//cell.titleImageView.image = icon; 
		//cell.imageView.image = icon;
	    [icon drawInRect:rect];
	    img = UIGraphicsGetImageFromCurrentImageContext();
	    UIGraphicsEndImageContext();

	    imgView.image = img;

    	[cell clipToTopHeaderWithHeight:52.0f inTableView:arg1];

    	NSLog(@"image frame = %@", NSStringFromCGRect(imgView.frame));
    	NSLog(@"cell frame = %@",NSStringFromCGRect(cell.frame));
    	NSLog(@"label frame = %@",NSStringFromCGRect(cell.titleLabel.frame));
    	// NSLog(@"constantConstraints = %@",cell.constantConstraints);
    	// NSLog(@"variableConstraints = %@",cell.variableConstraints);
		NSLog(@"clipping container = %@",[[cell clippingContainer] subviews]);

		[cell updateConstraints];
		return cell;
	}

	return %orig;
}

-(void)actionManager:(id)arg1 presentViewController:(id)arg2 completion:(/*^block*/id)arg3 modally:(BOOL)arg4 {
	if(logging) %log;
	if(window && arg4) {
		[self presentModalViewController:arg2 animated:YES];
	} else {
		%orig;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(logging) %log;

    if ([self shouldDisplayListLauncher]) {
    	[self dismissAnimated:YES completionBlock:nil];

    	NSString *identifier = @"";

    	if([[enabledSections objectAtIndex:indexPath.section] isEqual:@"Application List"]) {
			identifier = [listLauncherDisplayIdentifiers objectAtIndex:indexPath.row];
		} else if([[enabledSections objectAtIndex:indexPath.section] isEqual:@"Favorites"]) {
			identifier = [favoritesDisplayIdentifiers objectAtIndex:indexPath.row];
		} else if([[enabledSections objectAtIndex:indexPath.section] isEqual:@"Recent"]) {
			if(logging) NSLog(@"inside recent");
			identifier = [recentApplications objectAtIndex:indexPath.row];
		}

	    [tableView deselectRowAtIndexPath:indexPath animated:YES];

	 //    SBIconController *cont = [%c(SBIconController) sharedInstance];
	 //    SBIconModel *model = [cont model];
		// SBIcon *icon = [model expectedIconForDisplayIdentifier:identifier];
		[self _fadeForLaunchWithDuration:0.3f completion:^void{
			//[icon launchFromLocation:0];
			@try {
				[[UIApplication sharedApplication] launchApplicationWithIdentifier:identifier suspended:NO];
			}
			@catch (NSException * e) {
				NSLog(@"error! = %@",e);
			}
		}];

		if ([(SpringBoard*)[%c(SpringBoard) sharedApplication] isLocked]) {
			lockscreenIdentifier = identifier;
		}

	} else	{
		%orig;
	}

	if ([(SpringBoard*)[%c(SpringBoard) sharedApplication] isLocked]) {
		[[[%c(SBLockScreenManager) sharedInstance] lockScreenViewController] setPasscodeLockVisible:YES animated:YES];
	}
}

-(id)tableView:(UITableView *)arg1 viewForHeaderInSection:(int)arg2 {
	if(logging) %log;
	SBSearchTableHeaderView *header = %orig;
	if([self shouldDisplayListLauncher]){
		if(header == nil) {
			//header = [[%c(SBSearchTableHeaderView) alloc] initWithReuseIdentifier:@"SBSearchTableViewHeaderFooterView"];
			header = [[%c(SBSearchTableHeaderView) alloc] initWithReuseIdentifier:@"SLSearchTableViewHeaderFooterView"];
		}
		
		// UIView *view = [[header subviews] objectAtIndex:1];
		// view.alpha = 1.0;
		if([[enabledSections objectAtIndex:arg2] isEqual:@"Application List"]) {
			[header setTitle:applicationListName];
		} else if([[enabledSections objectAtIndex:arg2] isEqual:@"Favorites"]) {
			[header setTitle:favoritesName];
		} else if([[enabledSections objectAtIndex:arg2] isEqual:@"Recent"]) {
			[header setTitle:recentName];
		}
		header.clipsToBounds = YES;

	}
	//NSLog(@"%@",[header recursiveDescription]);
	//NSLog(@"header background view = %@",[arg1 _tableHeaderBackgroundView]);
	//[arg1 setTableHeaderView:header];
	//SBSearchResultsBackdropView *tableBackdrop = [[%c(SBSearchResultsBackdropView) alloc] initWithFrame:header.frame];
	
	if(blur_section_header_enabled) {
		_UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForStyle:2];

		// initialization of the blur view
		_UIBackdropView *hbackground = [[_UIBackdropView alloc] initWithSettings:settings];
		[hbackground setBlurRadiusSetOnce:YES];
		[hbackground setBlursBackground:NO];
		[hbackground setBlurRadius:0.1];


		[header insertSubview:hbackground atIndex:0];
	}
	

	return header;
}
%end

// %hook UINavigationBar 
// -(long long)barPosition {
// 	UINavigationController *nav = MSHookIvar<UINavigationController *>([%c(SBSearchViewController) sharedInstance], "_navigationController");

// 	if(self == nav.navigationBar) {
// 		return UIBarPositionTopAttached;
// 	}
// 	return %orig;
// }
// %end

%hook SBSearchTableHeaderView
// -(id)initWithReuseIdentifier:(id)arg1 {
// 	%log;
// 	//SBSearchTableHeaderView *header = %orig;
// 	//NSLog(@"tableheader subviews = %@",[header subviews]);
// 	//NSLog(@"tableheader seperator = %@",[header separatorView]);
// 	return %orig;
// }
// -(void)setSeparatorView:(id)arg1 {
// 	%log;
// 	%orig;
// }
%end


%hook SBAppSwitcherModel
-(void)appsRemoved:(id)arg1 added:(id)arg2 {
	if(logging) %log;
	%orig;
	if(logging) NSLog(@"done with orig");
	recentApplications = [[[self snapshotOfFlattenedArrayOfAppIdentifiersWhichIsOnlyTemporary] mutableCopy] retain];
	//recentApplications = [[[NSMutableArray alloc] initWithArray:[self snapshotOfFlattenedArrayOfAppIdentifiersWhichIsOnlyTemporary] copyItems:YES] autorelease];

	SBSearchViewController *sview = [%c(SBSearchViewController) sharedInstance];
	//[sview _updateTableContents];
	UITableView *stable = MSHookIvar<UITableView *>(sview, "_tableView");
	[stable reloadData];
}
-(void)remove:(id)arg1 {
	if(logging) %log;
	%orig;
	if(logging) NSLog(@"done with orig");
	recentApplications = [[[self snapshotOfFlattenedArrayOfAppIdentifiersWhichIsOnlyTemporary] mutableCopy] retain];
	//recentApplications = [[[NSMutableArray alloc] initWithArray:[self snapshotOfFlattenedArrayOfAppIdentifiersWhichIsOnlyTemporary] copyItems:YES] autorelease];
	SBSearchViewController *sview = [%c(SBSearchViewController) sharedInstance];
	//[sview _updateTableContents];
	UITableView *stable = MSHookIvar<UITableView *>(sview, "_tableView");
	[stable reloadData];
}
-(void)removeDisplayItem:(id)arg1  {
	if(logging) %log;
	%orig;
	if(logging) NSLog(@"done with orig");
	recentApplications = [[[self snapshotOfFlattenedArrayOfAppIdentifiersWhichIsOnlyTemporary] mutableCopy] retain];
	//recentApplications = [[[NSMutableArray alloc] initWithArray:[self snapshotOfFlattenedArrayOfAppIdentifiersWhichIsOnlyTemporary] copyItems:YES] autorelease];
	SBSearchViewController *sview = [%c(SBSearchViewController) sharedInstance];
	//[sview _updateTableContents];
	UITableView *stable = MSHookIvar<UITableView *>(sview, "_tableView");
	[stable reloadData];
}
-(void)addToFront:(id)arg1 {
	if(logging) %log;
	%orig;
	recentApplications = [[[self snapshotOfFlattenedArrayOfAppIdentifiersWhichIsOnlyTemporary] mutableCopy] retain];
	//recentApplications = [[[NSMutableArray alloc] initWithArray:[self snapshotOfFlattenedArrayOfAppIdentifiersWhichIsOnlyTemporary] copyItems:YES] autorelease];
	SBSearchViewController *sview = [%c(SBSearchViewController) sharedInstance];
	//[sview _updateTableContents];
	UITableView *stable = MSHookIvar<UITableView *>(sview, "_tableView");
	[stable reloadData];
}
%end

// %hook UITextField
// -(void)_becomeFirstResponder {
// 	%orig; 
// 	SBSearchHeader *sheader = MSHookIvar<SBSearchHeader *>([%c(SBSearchViewController) sharedInstance], "_searchHeader");
// 	UITextField *tfield = [sheader searchField];
// 	if(selectall && self == tfield) {
// 		if(![tfield.text isEqual:@""]) {
// 			[tfield selectAll:[%c(SBSearchViewController) sharedInstance]];
// 		}
// 	}
// }
// %end

%hook SBLockScreenManager
-(void)_finishUIUnlockFromSource:(int)arg1 withOptions:(id)arg2 {
	%orig;
	%log;
	@try {
		if(lockscreenIdentifier) {
			if([lockscreenIdentifier rangeOfString:@"://"].location != NSNotFound) {
				NSLog(@"is a url");
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:lockscreenIdentifier]];
			} else {
				NSLog(@"is not a url");
				[[UIApplication sharedApplication] launchApplicationWithIdentifier:lockscreenIdentifier suspended:NO];
			}
			
		}
	}
	@catch (NSException * e) {
			NSLog(@"error! = %@",e);
	}
	@finally {
		lockscreenIdentifier = nil;
	}

	
}
%end
%hook SBSearchResultsAction
// -(id)performWithCompletionBlock:(/*^block*/id)arg1 {
// 	%log;
// 	NSLog(@"result = %@", [self result]);

// 	if ([(SpringBoard*)[%c(SpringBoard) sharedApplication] isLocked]) {
// 		lockscreenIdentifier = [self result][@"url"];
// 	}

// 	return %orig;
//}
-(void)cancelAnimated:(BOOL)arg1 withCompletionBlock:(/*^block*/id)arg2 {
//Dec  7 16:04:08 Zacs-iPhone SpringBoard[60431] <Warning>: -[<SBSearchResultsAction: 0x171648010> cancelAnimated:1 withCompletionBlock:<__NSMallocBlock__: 0x171648100>]
	if(logging) %log;
	NSLog(@"result = %@", [self result]);

	applicationIdentifier = [[self result] url];

	if ([(SpringBoard*)[%c(SpringBoard) sharedApplication] isLocked]) {
		lockscreenIdentifier = [[self result] url];
		NSLog(@"url = %@", lockscreenIdentifier);
	}
	//[[UIApplication sharedApplication] launchApplicationWithIdentifier:[self result][@"url"] suspended:NO];
	%orig;
}
%end

// %hook SpringBoard
// -(id)init {
// 	id sb = %orig;
// 	if(sb) loadPrefs();
// 	return sb;
// }
// %end

// %hook SBSearchImageCell
// -(void)clipToTopHeaderWithHeight:(double)arg1 inTableView:(id)arg2 {
// 	%log;
// 	// if(arg1 < 52) {
// 	// 	%orig(65.0f,arg2);
// 	// } else {
// 	// 	%orig;
// 	// }
// 	%orig;
// }
// %end;

%hook SBSearchTableViewCell 
-(id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2 {
	if(logging) %log;
	return %orig;
}
// -(void)clipToTopHeaderWithHeight:(double)arg1 inTableView:(id)arg2 {
// 	%log;
// 	%orig;
// }
%end


%hook SBSearchStandardCell
-(id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2 {
	if(logging) %log;
	return %orig;
}
// -(void)clipToTopHeaderWithHeight:(double)arg1 inTableView:(id)arg2 {
// 	%log;
// 	%orig;
// }
%end



%hook SBSearchImageCell
// +(id)placeHolderImageForDomain:(unsigned)arg1 result:(id)arg2 size:(CGSize)arg3 {
// 	%log;
// 	return %orig;
// }

- (void)layoutSubviews {
    %orig;
    self.layer.masksToBounds = YES;
    self.layer.mask.frame = self.bounds;
}

- (void)setBounds:(CGRect)bounds
{
    %orig;

    self.layer.masksToBounds = YES;
}

 -(id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 {
	if(logging) %log;
	//SBSearchImageCell *cell = %orig;
	//NSLog(@"clipping container = %@",[[cell clippingContainer] subviews]);
	return %orig;
}
-(id)dequeueReusableCellWithIdentifier:(id)arg1 {
	if(logging) %log; 
	//SBSearchImageCell *cell = %orig;
	//NSLog(@"cell orig frame = (%f,%f,%f,%f)", cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
	return %orig;
}
// -(void)updateWithSection:(id)arg1 result:(id)arg2 traitCollection:(id)arg3 {
// 	%log;
// 	%orig;
// }
// -(void)setTitleTextAttributes:(id)arg1 {
// 	%log;
// 	%orig;
// }
%end

// %hook SPSearchResult
// -(id)initWithData:(id)arg1 {
// 	%log;
// 	return %orig;
// }
// %end

// %hook SBSearchHeader
// -(id)initWithFrame:(CGRect)arg1 {
// 	%log;
// 	SBSearchHeader *header = %orig;
// 	NSLog(@"header subviews = %@",[header subviews]);
// 	return %orig;	
// }
// %end

%hook SBSearchTableView 
// -(void)loadView {
// 	%orig;
// 	NSLog(@"did loadView");
// 	self.sectionIndexColor = [UIColor whiteColor]; // text color
// 	self.sectionIndexTrackingBackgroundColor = [UIColor clearColor]; //bg touched
// 	self.sectionIndexBackgroundColor = [UIColor clearColor]; //bg touched
// }
// - (void)viewDidLoad {
// 	%orig;
// 	NSLog(@"did viewDidLoad");
// 	self.sectionIndexColor = [UIColor whiteColor]; // text color
// 	self.sectionIndexTrackingBackgroundColor = [UIColor clearColor]; //bg touched
// 	self.sectionIndexBackgroundColor = [UIColor clearColor]; //bg touched
// }
// -(id)initWithFrame:(CGRect)arg1 {
// 	NSLog(@"initWithFrame launched");
// 	return %orig;
// }
// -(id)initWithFrame:(CGRect)arg1 style:(long long)arg2 {
// 	NSLog(@"initWithFrame style launched");
// 	SBSearchTableView *table = %orig;
// 	table.sectionIndexColor = [UIColor whiteColor]; // text color
// 	table.sectionIndexTrackingBackgroundColor = [UIColor clearColor]; //bg touched
// 	table.sectionIndexBackgroundColor = [UIColor clearColor]; //bg touched
// 	//SBSearchTableHeaderView *header = [[%c(SBSearchTableHeaderView) alloc] initWithReuseIdentifier:@"SBSearchTableViewHeaderFooterView"];
// 	//[table setTableHeaderView:header];
// 	return table;
// }


%end

%hook SBSearchModel
// - (void)searchDaemonQuery:(id)arg1 addedResults:(id)arg2 {
// 	%log; 
// 	%orig;
// }
// - (void)searchDaemonQueryCompleted:(id)arg1 {
// 	%log;
// 	%orig;
// }

%end








@implementation SearchLightActivator
- (void)activator:(id)activator receiveEvent:(LAEvent *)event {
	NSLog(@"event = %@",event);

	if([[%c(SBSearchViewController) sharedInstance] isVisible]) {
		[[%c(SBSearchGesture) sharedInstance] resetAnimated:YES];
	} else if (![(SpringBoard*)[%c(SpringBoard) sharedApplication] isLocked] || ([(SpringBoard*)[%c(SpringBoard) sharedApplication] isLocked] && ls_enabled)) {
		[[%c(SBSearchViewController) sharedInstance] show];
	}

	[event setHandled:YES];

}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
	return @"Searchlight";
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
	return @"Activate Searchlight.";
}

- (id)activator:(LAActivator *)activator requiresInfoDictionaryValueOfKey:(NSString *)key forListenerWithName:(NSString *)listenerName {
	return [NSNumber numberWithBool:YES]; // HAX so it can send raw events. <3 rpetrich
}

- (NSArray *)activator:(LAActivator *)activator requiresCompatibleEventModesForListenerWithName:(NSString *)listenerName {
	return [NSArray arrayWithObjects:@"springboard", @"lockscreen", @"application", nil];
}

@end

%hook SBSearchViewController
%new -(BOOL)shouldAutorotate {
	return YES;
}
%new
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}
%new
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationMaskAll;
}
-(void)_lockScreenUIWillLock:(BOOL)arg1 {
	%log;
	%orig;
}
%end




%hook SBSearchGesture


-(void)revealAnimated:(BOOL)arg1 {
	if(logging) %log;
	%orig;
	applicationIdentifier = nil;
	if(logging) {
		UIViewController *vc = MSHookIvar<UIViewController *>([%c(SBSearchViewController) sharedInstance], "_mainViewController");
		NSLog(@"main View Controller = %@",vc);
		originalWindow = MSHookIvar<UIWindow *>([%c(SBSearchViewController) sharedInstance], "_presentingWindow");
		NSLog(@"presenting Window = %@", originalWindow);
		UINavigationController *nc = MSHookIvar<UINavigationController *>([%c(SBSearchViewController) sharedInstance], "_navigationController");
		NSLog(@"main Nav Controller = %@",nc);
	}	
	[[%c(SBSearchViewController) sharedInstance] forceRotation];
}

-(void)resetAnimated:(BOOL)arg1 {
	
	if(logging) %log;
	UIViewController *vc = MSHookIvar<UIViewController *>([%c(SBSearchViewController) sharedInstance], "_mainViewController");
	
	originalWindow = MSHookIvar<UIWindow *>([%c(SBSearchViewController) sharedInstance], "_presentingWindow");
	
	UINavigationController *nc = MSHookIvar<UINavigationController *>([%c(SBSearchViewController) sharedInstance], "_navigationController");
	
	if(logging) {
		NSLog(@"main View Controller = %@",vc);
		NSLog(@"presenting Window = %@", originalWindow);
		NSLog(@"main Nav Controller = %@",nc);
		//NSLog(@"SBSearchViewController's window = %@",[%c(SBSearchViewController) sharedInstance].window);
		NSLog(@"main view controller's window = %@",vc.window);
	}

	// if(oldController) {
	// 	[[%c(SpringBoard) sharedApplication].keyWindow.rootViewController presentViewController:oldController animated:NO completion:nil];
	// 	oldController = nil;
	// }

	//if(logging) NSLog(@"orig complete.");

	if(didAddViewController || didNotAddViewController) {
		if(logging) NSLog(@"Searchlight: reseting view controller. ");

		if(statusBarWasHidden){
			[[%c(SpringBoard) sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
			statusBarWasHidden = NO;
			//[%c(SpringBoard) sharedApplication].keyWindow.windowLevel = beforeWindowLevel;

		}
		[(UIViewController *)[[UIApplication sharedApplication] keyWindow].rootViewController dismissViewControllerAnimated:YES completion:^{
			if(gesTargetview) {
				if(logging) NSLog(@"Searchlight: has gesTargetView");
				SBSearchGesture *ges = [%c(SBSearchGesture) sharedInstance];
	   			[ges setTargetView:gesTargetview];
	   			[ges setEnabled:YES];
	   			[ges _updateScrollingEnabled];
			}
			if(fv) {
				if(logging) NSLog(@"Searchlight: has fv");

				UIView *outview = MSHookIvar<UIView *>([%c(SBSearchViewController) sharedInstance], "_view");
				[fv addSubview:outview];
				// for(id view in [outview subviews]) {
				// 	[fv addSubview:view];
				// }
			}
			// if(didAddViewController || statusBarWasHidden) {
			// 	[%c(SpringBoard) sharedApplication].keyWindow.windowLevel = beforeWindowLevel;
			// 	statusBarWasHidden = NO;
			// }
			// if([[%c(SpringBoard) sharedApplication].keyWindow.rootViewController isEqual:cusViewController]) {
			// 	[%c(SpringBoard) sharedApplication].keyWindow.rootViewController = nil;
			// }

			@try {
				%orig;
			}
			@catch (NSException * e) {
					NSLog(@"error! = %@",e);
			}
			didAddViewController = NO;
			didNotAddViewController = NO;
		}];
	} else { 
		NSLog(@"Searchlight: just going to do orig;");
		@try {
			%orig;
		}
		@catch (NSException * e) {
				NSLog(@"Searchlight error! = %@",e);
		}
	 }

	if(applicationIdentifier) {
		if(logging) {
			NSLog(@"Searchlight: about to launch = %@",applicationIdentifier);
		}
		@try {
			[[UIApplication sharedApplication] launchApplicationWithIdentifier:applicationIdentifier suspended:NO];
		}
		@catch (NSException * e) {
			NSLog(@"Searchlight: error! = %@",e);
		}
	}
	applicationIdentifier = nil;

	if(logging) NSLog(@"Searchlight: done with resetAnimated");

	if(cusViewController) {
		dispatch_async(dispatch_get_main_queue(), ^{
			//[cusViewController dismissViewControllerAnimated:NO  completion:nil];
			[cusViewController.view removeFromSuperview];
			NSLog(@"this was called");
		});
	}
		
}
%end

%hook SBApplication
-(void)_didSuspend {
	if(logging) %log;
	%orig;
	if(cusViewController) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[cusViewController dismissViewControllerAnimated:NO  completion:nil];
			[cusViewController.view removeFromSuperview];
		});
	}
	[[%c(SBSearchViewController) sharedInstance] forceRotation];
}
%end

%hook SpringBoard

-(void)noteInterfaceOrientationChanged:(int)arg1 duration:(float)arg2 {
	//if(logging) %log;
	//[window _updateInterfaceOrientationFromDeviceOrientationIfRotationEnabled:YES];
	//[window _updateToInterfaceOrientation:arg1 duration:arg2 force:1];
	%orig;
	%log;

	[[%c(SBSearchViewController) sharedInstance] forceRotation];

	//[[%c(SBSearchViewController) sharedInstance] setHeaderbyChangingFrame:YES withPushDown:10];
}

// -(BOOL)homeScreenSupportsRotation{
// 	return YES;
// }

// -(long long)homeScreenRotationStyle{
// 	return 1;
// }
%end

%ctor {
	NSLog(@"Loading ListLauncher7...");

	dlopen("/Library/MobileSubstrate/DynamicLibraries/SpotDefine.dylib", RTLD_NOW);
	dlopen("/Library/MobileSubstrate/DynamicLibraries/SearchPlus.dylib", RTLD_NOW);
	dlopen("/Library/MobileSubstrate/DynamicLibraries/SmartSearch.dylib", RTLD_NOW);
    //CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("org.thebigboss.listlauncher7/settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)savePrefs, CFSTR("org.thebigboss.searchlight/saved"), NULL, CFNotificationSuspensionBehaviorCoalesce);

    //loadPrefs();
    NSLog(@"Done loading ListLauncher7!");


    dlopen("/usr/lib/libactivator.dylib", RTLD_LAZY);

    static SearchLightActivator *listener = [[SearchLightActivator alloc] init];

    //id la = [%c(LAActivator) sharedInstance];
    // if ([la respondsToSelector:@selector(hasSeenListenerWithName:)] && [la respondsToSelector:@selector(assignEvent:toListenerWithName:)]) {
    //     //if (![la hasSeenListenerWithName:@"com.twodayslate.anyspot8"]) {
    //         [la assignEvent:[%c(LAEvent) eventWithName:@"libactivator.menu.press.single"] toListenerWithName:@"com.twodayslate.slideback"];
    //     }
    // }

    // register our listener. do this after the above so it still hasn't "seen" us if this is first launch
    [[%c(LAActivator) sharedInstance] registerListener:listener forName:@"org.thebigboss.searchlight"];
}
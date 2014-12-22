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
static bool logging, hideKeyboard, selectall = false;

static NSMutableArray *indexValues = nil;
static NSMutableArray *indexPositions = nil; 

static void setHeader() {
	UINavigationController *nav = MSHookIvar<UINavigationController *>([%c(SBSearchViewController) sharedInstance], "_navigationController");
	NSLog(@"before");
	NSLog(@"navigation controller view = %@",nav.view);
	NSLog(@"navigation controller bar = %@",nav.navigationBar);
	CGRect navframe = nav.navigationBar.frame;
	// navframe.size.height = 44; 
	navframe.origin.y = 20;
	nav.navigationBar.frame = navframe;

	navframe = nav.view.frame;
	// navframe.size.height = 44; 
	navframe.origin.y = 20;
	nav.view.frame = navframe;

	// UIViewController *nmv = MSHookIvar<UIViewController *>([%c(SBSearchViewController) sharedInstance], "_mainViewController");
	// NSLog(@"main view controller = %@",nmv);
	nav.navigationBar.clipsToBounds = NO;
	nav.navigationBar.barStyle = UIBarStyleBlack;
	nav.edgesForExtendedLayout = UIRectEdgeNone;
	// [nav.navigationBar setBarStyle:UIBarStyleBlack];
	// nav.navigationBar.barTintColor = [UIColor blackColor];
	// [nav.navigationBar setBarTintColor:[UIColor blackColor]];
	nav.navigationBar.translucent = YES;
	nav.automaticallyAdjustsScrollViewInsets = NO;
	// //nav.edgesForExtendedLayout = UIRectEdgeAll;
	// nav.edgesForExtendedLayout = UIRectEdgeTop;
	// //nav.automaticallyAdjustsScrollViewInsets = YES;
	// nav.extendedLayoutIncludesOpaqueBars = NO;
	//[[UINavigationBar appearance] setTintColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
	// [nav.navigationBar _setBackgroundView:[[_UIBackdropView alloc] initWithStyle:2060]];
	// NSLog(@"navigation bar subviews = %@",[nav.navigationBar subviews]);
	for(UIView *subview in [nav.navigationBar subviews]) {
		if([subview isKindOfClass:[%c(SBWallpaperEffectView) class]]) {
			NSLog(@"SBwallpapereffectview = %@",subview);
			//subview.alpha = 0.0;
			//[subview removeFromSuperview];
			[(SBWallpaperEffectView *)subview setStyle:0];
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
	//[nav.navigationBar addSubview:background];
	// [nav.navigationBar setBarStyle:UIBarStyleBlack];
	//[nav.navigationBar _setBarPosition:UIBarPositionTopAttached];
	NSLog(@"after");
	NSLog(@"navigation controller view = %@",nav.view);
	NSLog(@"navigation bar = %@",nav.navigationBar);


	[[%c(SBSearchViewController) sharedInstance] repositionCells];
	//[[%c(SBSearchViewController) sharedInstance] _updateHeaderHeightIfNeeded];
}


%hook SBSearchViewController

// -(void)_updateCellClipping:(id)arg1 {
// 	%log;
// 	%orig;
// }
%new 
-(void)repositionCells {
	UITableView *tableView = MSHookIvar<UITableView *>(self, "_tableView");
	NSLog(@"contentOffset = %f",tableView.contentOffset.y);
	NSLog(@"contentSize = (%f,%f)",tableView.contentSize.width, tableView.contentSize.height);
	if(tableView.contentOffset.y <= 0) {
		//[tableView setContentOffset:CGPointMake(0, -44) animated:NO];
		[tableView scrollRectToVisible:CGRectMake(0,0,375,44) animated:NO];
		//tableView.contentSize = CGSizeMake(tableView.contentSize.width, tableView.contentSize.height+20);
	}
}

%new 
- (UIStatusBarStyle) preferredStatusBarStyle { 
    return UIStatusBarStyleLightContent; 
}


%new 
-(BOOL)shouldDisplayListLauncher {
	// SBSearchHeader *sheader = MSHookIvar<SBSearchHeader *>(self, "_searchHeader");
	// NSString *currentText = [sheader searchField].text;
	//NSLog(@"shouldDisplay _hasNoQuery = %f",(float)[self _hasNoQuery]);
	return [self _hasNoQuery];
	//return [currentText isEqualToString:@""];
}

// %new
// - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection: (NSInteger)section {
// 	if([self shouldDisplayListLauncher]){
// 		// if(header == nil) {
// 		// 	header = [[%c(SBSearchTableHeaderView) alloc] initWithReuseIdentifier:@"SBSearchTableViewHeaderFooterView"];
// 		// }
// 		// UIView *view = [[header subviews] objectAtIndex:1];
// 		// view.alpha = 1.0;
// 		if([[enabledSections objectAtIndex:section] isEqual:@"Application List"]) {
// 			return applicationListName;
// 		} else if([[enabledSections objectAtIndex:section] isEqual:@"Favorites"]) {
// 			return favoritesName;
// 		} else if([[enabledSections objectAtIndex:section] isEqual:@"Recent"]) {
// 			return recentName;
// 		}
// 	}
// 	//NSLog(@"%@",[header recursiveDescription]);
// 	//NSLog(@"header background view = %@",[arg1 _tableHeaderBackgroundView]);
// 	//[arg1 setTableHeaderView:header];
// 	return @"";
// }

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
	setHeader();
	//self.automaticallyAdjustsScrollViewInsets = NO;
	// UIEdgeInsets inset = UIEdgeInsetsMake(20, 0, 0, 0);
	//UITableView *tableView = MSHookIvar<UITableView *>(self, "_tableView");
	// CGRect newFrame = tableView.frame; 
	// newFrame.origin.y = newFrame.origin.y + 20;
	// tableView.frame = newFrame;
    // tableView.contentInset = inset;
    //tableView.contentOffset = CGPointMake(0, -44);
}

// -(BOOL)_hasNoQuery {
// 	return false;
// }

-(BOOL)_showFirstTimeView { return false; }

%new
-(id)sectionIndexTitlesForTableView:(UITableView *)arg1 {
	if(logging) %log;
	if([self shouldDisplayListLauncher]) return indexValues;
	arg1.sectionIndexColor = [UIColor whiteColor]; // text color
	arg1.sectionIndexTrackingBackgroundColor = [UIColor clearColor]; //bg touched
	arg1.sectionIndexBackgroundColor = [UIColor clearColor]; //bg touched
	return nil;
}

-(void)searchGesture:(id)arg1 changedPercentComplete:(double)arg2 {
	%orig;
	[[%c(SBSearchViewController) sharedInstance] repositionCells];
}

-(void)searchGesture:(id)arg1 completedShowing:(BOOL)arg2  {
	%orig;
	%log;
	//setHeader();
	[[%c(SBSearchViewController) sharedInstance] repositionCells];
	//setHeader();
}

// -(void)_setShowingKeyboard:(BOOL)arg1 {
// 	if(arg1 && hideKeyboard) {
// 		return;
// 	}

// 	%orig;

// 	if(arg1 && selectall) {
// 		SBSearchHeader *sheader = MSHookIvar<SBSearchHeader *>(self, "_searchHeader");
// 		if(![[sheader searchField].text isEqual:@""]) {
// 			[[sheader searchField] selectAll:self];
// 		}
// 	}
// }

-(int)tableView:(UITableView *)arg1 numberOfRowsInSection:(int)arg2 {
	if(logging) %log;
	if([self shouldDisplayListLauncher]) {
		NSLog(@"should display");
		if(enabledSections && [enabledSections count] > arg2)  {
			if([[enabledSections objectAtIndex:arg2] isEqual:@"Application List"]) {
				//NSLog(@"will return = %f",(float)[listLauncherDisplayIdentifiers count]);
				return [listLauncherDisplayIdentifiers count];
			} else if([[enabledSections objectAtIndex:arg2] isEqual:@"Favorites"]) {
				return [favoritesDisplayIdentifiers count];
			} else if([[enabledSections objectAtIndex:arg2] isEqual:@"Recent"]) {
				if(maxRecent > [recentApplications count]) return [recentApplications count];
				return maxRecent;
			}
		}
	}
		
	arg1.sectionIndexColor = [UIColor whiteColor]; // text color
	arg1.sectionIndexTrackingBackgroundColor = [UIColor clearColor]; //bg touched
	arg1.sectionIndexBackgroundColor = [UIColor clearColor]; //bg

	return %orig;
}

-(int)numberOfSectionsInTableView:(id)arg1 	{
	if(logging) %log;
	if([self shouldDisplayListLauncher]) {
		if([enabledSections containsObject:@"Recent"]) {
			// if([recentApplications count] == 0) {
			// 	hideRecent = YES;
			// 	return [enabledSections count] - 1;
			// }
		}
		return [enabledSections count];
	}
	return %orig;
}

%new
-(int)tableView:(UITableView *)tableview sectionForSectionIndexTitle:(id)title atIndex:(int)index {
	if(logging) %log;

	tableview.sectionIndexColor = [UIColor whiteColor]; // text color
	tableview.sectionIndexTrackingBackgroundColor = [UIColor clearColor]; //bg touched
	tableview.sectionIndexBackgroundColor = [UIColor clearColor]; //bg touched

	int appSection = [enabledSections indexOfObject:@"Application List"];
	int recentSection = [enabledSections indexOfObject:@"Recent"];
	int favoriteSection = [enabledSections indexOfObject:@"Favorites"];

	if([title isEqual:@"▢"]) {
		return recentSection;
	} else if([title isEqual:@"☆"]) {
		return favoriteSection;
	} else {
		if(logging) NSLog(@"jump to (%@,%d) for title %@ at index %d",[indexPositions objectAtIndex:index],(int)appSection,title,index);
		[tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[indexPositions objectAtIndex:index] integerValue] inSection:appSection] atScrollPosition:UITableViewScrollPositionTop animated:NO];
		return 99999999; // this allows for scrolling without jumping to some random ass section
	}

	return index;
}

// -(BOOL)tableView:(UITableView *)arg1 wantsHeaderForSection:(int)arg2 {
// 	if(logging) %log;
// 	arg1.sectionIndexColor = [UIColor whiteColor]; // text color
// 	arg1.sectionIndexTrackingBackgroundColor = [UIColor clearColor]; //bg touched
// 	arg1.sectionIndexBackgroundColor = [UIColor clearColor]; //bg
// 	return %orig;
// }

-(BOOL)_hasResults {
	if(logging) %log;
	NSLog(@"number of enabled sections = %f",(float)[enabledSections count]);
	if([self shouldDisplayListLauncher] && [enabledSections count] > 0) {
		NSLog(@"_hasResults = YES");
		return YES;
	}
	return %orig;
}
// - (void)searchAgentUpdatedResults:(id)arg1 {
// 	%log;
// 	%orig;
// }

-(id)tableView:(UITableView *)arg1 cellForRowAtIndexPath:(NSIndexPath *)arg2 {
	if(logging) %log;

	if(arg2.row > [listLauncherDisplayIdentifiers count]-1) { return %orig; } // fix for SpotDefine
	if([self shouldDisplayListLauncher]) {

		NSString *identifier = [@"" retain];

		if([[enabledSections objectAtIndex:arg2.section] isEqual:@"Application List"]) {
			NSLog(@"attemtping for applist");
			identifier = [listLauncherDisplayIdentifiers objectAtIndex:arg2.row];
		} else if([[enabledSections objectAtIndex:arg2.section] isEqual:@"Favorites"]) {
			NSLog(@"attemtping for favs");
			identifier = [favoritesDisplayIdentifiers objectAtIndex:arg2.row];
		} else if([[enabledSections objectAtIndex:arg2.section] isEqual:@"Recent"]) {
			NSLog(@"attemtping for recent");
			identifier = [recentApplications objectAtIndex:arg2.row];
		}


/*
Nov  2 19:53:54 Zacs-iPhone SpringBoard[2419] <Warning>: +[<SBSearchImageCell: 0x100636558> placeHolderImageForDomain:4 result:<SPSearchResult: 0x174aa8880> {
	    auxiliaryTitle = Games;
	    title = LootTheWorld;
	    url = "com.gearboxsoftware.BorderLoot";
	} size:{40, 40}]
	*/
		NSString *name = [applicationList valueForKey:@"displayName" forDisplayIdentifier:identifier];


		// SPSearchResult *result = [[%c(SPSearchResult) alloc] init];
		// [result setTitle:name];
		// [result setUrl:identifier];

		SBSearchImageCell *cell = [arg1 dequeueReusableCellWithIdentifier:@"searchlight"];

		//NSLog(@"cell = %@",cell);
		//NSLog(@"Name = %@",name);
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

			// Instead of doing this... can make a custom cell and do this: http://stackoverflow.com/a/4209039/193772
			//UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(64.0f, 14.0f, 150.0f, 20.0f)];
			UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(48.0f, 3.0f, 150.0f, 20.0f)];
			lbl.text = name;
			lbl.tag = 666;
			lbl.textColor = [UIColor whiteColor];
			[cell.leftView addSubview:lbl];
			
			//UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15.5f, 3.5f, 41.5f, 41.5f)];
			UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(-1.0f, -8.0f, 41.5f, 41.5f)];
			imgView.tag = 667;
			[cell.leftView addSubview:imgView];

		}
		 [cell updateLabel:cell.titleLabel withValue:@" "];
		//cell.titleLabel.text = name;
		//cell.textLabel.text = name;
		UILabel *lbl = (UILabel *)[cell.leftView viewWithTag:666];
    	[lbl setText:name];

    	UIImageView *imgView = (UIImageView *)[cell.leftView viewWithTag:667];

    	CGRect rect = CGRectMake(0,0,35,35);
    	UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    	// CGContextRef context = UIGraphicsGetCurrentContext();
    	// CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
	    UIImage *icon = [applicationList iconOfSize:40 forDisplayIdentifier:identifier];
	 //    //cell.titleImageView.image = icon; 
		//cell.imageView.image = icon;
	    [icon drawInRect:rect];
	    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	    UIGraphicsEndImageContext();

    	imgView.image = img;
		//cell.textLabel.text = name;
					// cell.textLabel.frame = CGRectMake(20,16,328,20.5);
					// cell.titleLabel.frame = CGRectMake(40,16,328,20.5);
					//[cell setNeedsLayout];
		

		//NSLog(@"titleLabel = %@",cell.titleLabel);
		//NSLog(@"leftView = %@",cell.leftView);
		//NSLog(@"leftTextView = %@",cell.leftTextView);



		// cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y,cell.frame.size.width, 44);
		// [cell setFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y,cell.frame.size.width, 44)];
		//cell.textLabel.text = name;
		// cell.textLabel.textColor = [UIColor whiteColor];
		// [arg1 _setHeight:44.0 forRowAtIndexPath:arg2];
		 //cell.indentationLevel = 1;
		 //cell.indentationWidth = 54;
	// 	-[<SBSearchImageCell: 0x129385930> setTitleTextAttributes:{
	//     NSColor = "UIDeviceWhiteColorSpace 1 1";
	//     NSFont = "<UICTFont: 0x125e9b030> font-family: \".HelveticaNeueInterface-Regular\"; font-weight: normal; font-style: normal; font-size: 17.00pt";
	//     SBSymbolicTraitAttributeName = 32768;
	//     SBTextStyleAttributeName = UICTFontTextStyleBody;
	// }]
		// NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
		// [attributes setObject:[UIColor whiteColor] forKey:@"NSColor"];
		// UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:17.0];
		// [attributes setObject:font forKey:@"NSFont"];
		// [attributes setObject:[NSNumber numberWithInt:32768] forKey:@"SBSymbolicTraitAttributeName"];
		// [attributes setObject:@"UICTFontTextStyleBody" forKey:@"SBTextStyleAttributeName"];

		// NSLog(@"cell frame 1 = (%f,%f,%f,%f)", cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
		//[cell setTitleTextAttributes:attributes];

		// [cell _setBackgroundInset:UIEdgeInsetsMake(0,0,0,0)];
		// [cell setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
		// NSLog(@"left text margin = %f",[cell leftTextMargin]);

		// cell.frame = CGRectMake(0,0, cell.frame.size.width, 44);
		// [cell setFrame:CGRectMake(0,0, cell.frame.size.width, 44)];
		// [cell updateConstraints];

		// NSLog(@"cell frame 2 = (%f,%f,%f,%f)", cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);

		//[cell clipToTopHeaderWithHeight:44.0 inTableView:arg1];

		//[cell setTitleTextAttributes:]
		//[cell setTitle:name];
		//cell.title = name;
		//NSLog(@"name = %@",name);
		// if(arg2.row == 0) {
		// 	[cell setFirstInSection:YES];
		// 	//[cell setFirstInTableView:YES];
		// } else {
		// 	[cell setFirstInSection:NO];
		// 	//[cell setFirstInTableView:NO];
		// }
		// if(arg2.row == [self tableView:arg1 numberOfRowsInSection:arg2.section]) {
		// 	[cell setIsLastInSection:YES];
		// } else {
		// 	[cell setIsLastInSection:NO];
		// }
		// UIImage *placeHolder = [%c(SBSearchImageCell) placeHolderImageForDomain:4 result:result size:CGSizeMake(40,40)];
		// UIImageView *placeHolderView = [[UIImageView alloc] initWithImage:placeHolder];
		// // Ivar ivar = object_getIvar(%c(SBSearchImageCell), @"_titleImageView");

		// // object_setIvar(cell, ivar, placeHolderView);

		// UIImageView *secWidth = MSHookIvar<UIImageView *>(cell, "_titleImageView");
		//  if (secWidth) {
		//     secWidth = placeHolderView;
		//  }

		//cell->_leftTextMargin = 54.0f;

		//cell.titleLabel.text = name;
		//NSLog(@"titleLabel frame 1 = (%f,%f,%f,%f)", cell.titleLabel.frame.origin.x, cell.titleLabel.frame.origin.y, cell.titleLabel.frame.size.width, cell.titleLabel.frame.size.height);

		
		//NSLog(@"titleLabel frame 2 = (%f,%f,%f,%f)", cell.titleLabel.frame.origin.x, cell.titleLabel.frame.origin.y, cell.titleLabel.frame.size.width, cell.titleLabel.frame.size.height);

		//NSLog(@"cell leftView = %@",[cell leftView]);
		//NSLog(@"cell leftTextView = %@",[cell leftTextView]);
		//[cell updateLabel:cell.titleLabel withValue:name];
		//[cell updateFonts];



	    //cell.imageView.image = icon;
	    // NSData *imageData = UIImagePNGRepresentation(picture1);
	    // UIImage *img=[UIImage imageWithData:imageData];
		//UIImage *icon = [applicationList iconOfSize:42 forDisplayIdentifier:identifier];
		// //cell.sectionHeaderWidth = 59.0f;
		//UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
		//[imageView setFrame:CGRectMake(15, 2, 40,40)];

		
		//[cell addSubview:imageView];
		//cell.valueImageView = imageView;
		// cell.titleImageView = icon;
		//[cell setHasImage:YES];
		//[cell clipToTopHeaderWithHeight:40.0f inTableView:arg1];

		//NSLog(@"subviews = %@",[cell subviews]);
		//NSLog(@"subviews's subviews = %@",[[cell subviews][0] subviews]);
		// NSLog(@"subviews before = %@",[[[cell subviews][1] subviews][0] subviews]);
		// NSArray *views = [[[cell subviews][1] subviews][0] subviews];
		// //UILabel *label = views[2];
		// UIImageView *imageView = views[5];

		// icon = [applicationList iconOfSize:40 forDisplayIdentifier:identifier];
		// imageView.image = icon;
		// NSLog(@"subviews after = %@",[[[cell subviews][1] subviews][0] subviews]);

		return cell;
	}

	// arg1.sectionIndexColor = [UIColor whiteColor]; // text color
	// arg1.sectionIndexTrackingBackgroundColor = [UIColor clearColor]; //bg touched
	// arg1.sectionIndexBackgroundColor = [UIColor clearColor]; //bg touched
	return %orig;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(logging) %log;



    if ([self shouldDisplayListLauncher]) {
    	[self dismiss];

    	NSString *identifier = @"";

    	if([[enabledSections objectAtIndex:indexPath.section] isEqual:@"Application List"]) {
			identifier = [listLauncherDisplayIdentifiers objectAtIndex:indexPath.row];
		} else if([[enabledSections objectAtIndex:indexPath.section] isEqual:@"Favorites"]) {
			identifier = [favoritesDisplayIdentifiers objectAtIndex:indexPath.row];
		} else if([[enabledSections objectAtIndex:indexPath.section] isEqual:@"Recent"]) {
			identifier = [recentApplications objectAtIndex:indexPath.row];
		}

	    [tableView deselectRowAtIndexPath:indexPath animated:YES];

	 //    SBIconController *cont = [%c(SBIconController) sharedInstance];
	 //    SBIconModel *model = [cont model];
		// SBIcon *icon = [model expectedIconForDisplayIdentifier:identifier];
		[self _fadeForLaunchWithDuration:0.3f completion:^void{
			//[icon launchFromLocation:0];
			[[UIApplication sharedApplication] launchApplicationWithIdentifier:identifier suspended:NO];
		}];

		if ([(SpringBoard*)[%c(SpringBoard) sharedApplication] isLocked]) {
			lockscreenIdentifier = identifier;
		}

	} else	%orig;

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
	}
	//NSLog(@"%@",[header recursiveDescription]);
	//NSLog(@"header background view = %@",[arg1 _tableHeaderBackgroundView]);
	//[arg1 setTableHeaderView:header];
	//SBSearchResultsBackdropView *tableBackdrop = [[%c(SBSearchResultsBackdropView) alloc] initWithFrame:header.frame];
	_UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForStyle:2];

	// initialization of the blur view
	_UIBackdropView *hbackground = [[_UIBackdropView alloc] initWithSettings:settings];
	[hbackground setBlurRadiusSetOnce:YES];
	[hbackground setBlursBackground:NO];
	[hbackground setBlurRadius:0.1];


	[header insertSubview:hbackground atIndex:0];

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
	favoritesDisplayIdentifiers = [[[NSMutableArray alloc] init] retain];
	NSMutableArray *favoriteList = [(NSMutableArray *) [settings valueForKey:@"favorites"] retain];
	favoriteList =  [[favoriteList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
	    return 	[[obj1 objectAtIndex:1] integerValue] > [[obj2 objectAtIndex:1] integerValue]	;}] mutableCopy];
	for(id spec in favoriteList) {
		[favoritesDisplayIdentifiers insertObject:[spec objectAtIndex:0] atIndex:[favoritesDisplayIdentifiers count]];
	}
	[favoriteList release];

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
	logging = YES;
	if(logging) NSLog(@"Searchlight Settings = %@",settings);

	hideKeyboard = [settings objectForKey:@"hide_keyboard"] ? [[settings objectForKey:@"hide_keyboard"] boolValue] : NO;

	selectall = [settings objectForKey:@"hide_keyboard"] ? [[settings objectForKey:@"selectall"] boolValue] : NO;

	headerStyle = [settings objectForKey:@"header_style"] ? [[settings objectForKey:@"header_style"] integerValue] : 2060;


	enabledSections = [settings objectForKey:@"enabledSections"] ?: @[]; [enabledSections retain];
    maxRecent = [settings objectForKey:@"maxRecent"] ? [[settings objectForKey:@"maxRecent"] integerValue] : 3;
	applicationList = [[ALApplicationList sharedApplicationList] retain];
	recentName = [settings objectForKey:@"recentName"] ?: recentName; recentName = [recentName isEqual:@""] ? @"RECENT" : recentName;
	applicationListName = [settings objectForKey:@"applicationListName"] ?: applicationListName; applicationListName = [applicationListName isEqual:@""] ? @"APPLICATION LIST" : applicationListName;
	favoritesName = [settings objectForKey:@"favoriteName"] ?: favoritesName; favoritesName = [favoritesName isEqual:@""] ? @"FAVORITES" : favoritesName;

	sortedDisplayIdentifiers = [[[applicationList.applications allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
	    return [[applicationList.applications objectForKey:obj1] caseInsensitiveCompare:[applicationList.applications objectForKey:obj2]];}] retain];

	setApplicationListDisplayIdentifiers(settings);

	setFavorites(settings);

	if(logging) NSLog(@"favorites = %@",favoritesDisplayIdentifiers);

	createAlphabet();

	if(logging) NSLog(@"Done creating alphabet");
	
	SBSearchViewController *sview = [%c(SBSearchViewController) sharedInstance];
	//[sview _updateTableContents];
	UITableView *stable = MSHookIvar<UITableView *>(sview, "_tableView");
	stable.sectionIndexColor = [UIColor whiteColor]; // text color
	stable.sectionIndexTrackingBackgroundColor = [UIColor clearColor]; //bg touched
	stable.sectionIndexBackgroundColor = [UIColor clearColor]; //bg
	[stable reloadData];

	generateAppList();

	setHeader();

	SBAppSwitcherModel *switcherModel = [%c(SBAppSwitcherModel) sharedInstance];
	recentApplications = [[switcherModel snapshotOfFlattenedArrayOfAppIdentifiersWhichIsOnlyTemporary] retain];

	NSLog(@"recent apps = %@", recentApplications);

	if(logging) NSLog(@"Done with settings");
}

%hook SBAppSwitcherModel
-(void)appsRemoved:(id)arg1 added:(id)arg2 {
	%orig;
	recentApplications = [[self snapshotOfFlattenedArrayOfAppIdentifiersWhichIsOnlyTemporary] retain];
}
-(void)remove:(id)arg1 {
	%orig;
	recentApplications = [[self snapshotOfFlattenedArrayOfAppIdentifiersWhichIsOnlyTemporary] retain];
	SBSearchViewController *sview = [%c(SBSearchViewController) sharedInstance];
	//[sview _updateTableContents];
	UITableView *stable = MSHookIvar<UITableView *>(sview, "_tableView");
	stable.sectionIndexColor = [UIColor whiteColor]; // text color
	stable.sectionIndexTrackingBackgroundColor = [UIColor clearColor]; //bg touched
	stable.sectionIndexBackgroundColor = [UIColor clearColor]; //bg
	[stable reloadData];
}
-(void)removeDisplayItem:(id)arg1  {
	%orig;
	recentApplications = [[self snapshotOfFlattenedArrayOfAppIdentifiersWhichIsOnlyTemporary] retain];
	SBSearchViewController *sview = [%c(SBSearchViewController) sharedInstance];
	//[sview _updateTableContents];
	UITableView *stable = MSHookIvar<UITableView *>(sview, "_tableView");
	stable.sectionIndexColor = [UIColor whiteColor]; // text color
	stable.sectionIndexTrackingBackgroundColor = [UIColor clearColor]; //bg touched
	stable.sectionIndexBackgroundColor = [UIColor clearColor]; //bg
	[stable reloadData];
}
-(void)addToFront:(id)arg1 {
		%orig;
	recentApplications = [[self snapshotOfFlattenedArrayOfAppIdentifiersWhichIsOnlyTemporary] retain];
	SBSearchViewController *sview = [%c(SBSearchViewController) sharedInstance];
	//[sview _updateTableContents];
	UITableView *stable = MSHookIvar<UITableView *>(sview, "_tableView");
	stable.sectionIndexColor = [UIColor whiteColor]; // text color
	stable.sectionIndexTrackingBackgroundColor = [UIColor clearColor]; //bg touched
	stable.sectionIndexBackgroundColor = [UIColor clearColor]; //bg
	[stable reloadData];
}
%end

%hook UITextField
-(void)_becomeFirstResponder {
	%orig; 
	SBSearchHeader *sheader = MSHookIvar<SBSearchHeader *>([%c(SBSearchViewController) sharedInstance], "_searchHeader");
	UITextField *tfield = [sheader searchField];
	if(selectall && self == tfield) {
		if(![tfield.text isEqual:@""]) {
			[tfield selectAll:[%c(SBSearchViewController) sharedInstance]];
		}
	}
}
%end

%hook SBLockScreenManager
-(void)_finishUIUnlockFromSource:(int)arg1 withOptions:(id)arg2 {
	%orig;
	%log;
	if(lockscreenIdentifier) {
		if([lockscreenIdentifier rangeOfString:@"://"].location != NSNotFound) {
			NSLog(@"is a url");
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:lockscreenIdentifier]];
		} else {
			NSLog(@"is not a url");
			[[UIApplication sharedApplication] launchApplicationWithIdentifier:lockscreenIdentifier suspended:NO];
		}
		
	}
	lockscreenIdentifier = nil;
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
	%log;
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

%hook SpringBoard
-(id)init {
	id sb = %orig;
	if(sb) loadPrefs();
	return sb;
}
%end

// %hook SBSearchStandardCell
// -(float)leftTextMargin {
// 	return 44.0f;
// }
// -(float)leftMargin {
// 	return 44;
// }
// %end;

%hook SBSearchImageCell
// +(id)placeHolderImageForDomain:(unsigned)arg1 result:(id)arg2 size:(CGSize)arg3 {
// 	%log;
// 	return %orig;
// }

 -(id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 {
	%log;
	SBSearchImageCell *cell = %orig;
	NSLog(@"clipping container = %@",[[cell clippingContainer] subviews]);
	return %orig;
}
-(id)dequeueReusableCellWithIdentifier:(id)arg1 {
	%log; 
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
-(id)initWithFrame:(CGRect)arg1 style:(long long)arg2 {
	NSLog(@"initWithFrame style launched");
	SBSearchTableView *table = %orig;
	table.sectionIndexColor = [UIColor whiteColor]; // text color
	table.sectionIndexTrackingBackgroundColor = [UIColor clearColor]; //bg touched
	table.sectionIndexBackgroundColor = [UIColor clearColor]; //bg touched
	//SBSearchTableHeaderView *header = [[%c(SBSearchTableHeaderView) alloc] initWithReuseIdentifier:@"SBSearchTableViewHeaderFooterView"];
	//[table setTableHeaderView:header];
	return table;
}
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

static UIWindow *window = nil;
static UIWindow *originalWindow = nil;
//static UIViewController *oldController = nil;
static SBSearchViewController *vcont = nil;
static SBRootFolderView *fv = nil; 
static SBRootFolderController *fvd = nil;
static UIView *gesTargetview = nil;

@implementation SearchLightActivator
- (void)activator:(id)activator receiveEvent:(LAEvent *)event {
	NSLog(@"event = %@",event);
	vcont = [%c(SBSearchViewController) sharedInstance];
	UIView *view = MSHookIvar<UIView *>(vcont, "_view");
	originalWindow = MSHookIvar<UIWindow *>(vcont, "_presentingWindow");
	NSLog(@"presenting Window = %@", originalWindow);
	UIViewController *vc = MSHookIvar<UIViewController *>(vcont, "_mainViewController");
	NSLog(@"main View Controller = %@",vc);
	SBSearchGesture *ges = [%c(SBSearchGesture) sharedInstance];
	if(!gesTargetview)	gesTargetview = MSHookIvar<SBIconScrollView *>(ges, "_targetView");


	NSLog(@"AnySpot: keyWindow root view Controller = %@",[[UIApplication sharedApplication] keyWindow].rootViewController);
	NSLog(@"AnySpot: keyWindow delegate = %@",[[[UIApplication sharedApplication] keyWindow] delegate]);

	if ([[view superview] isKindOfClass:[%c(SBRootFolderView) class]]) {
		fv = [(SBRootFolderView *)[view superview] retain];
		if([[fv delegate] isKindOfClass:[%c(SBRootFolderController) class]]) 
			fvd = [[fv delegate] retain];
	}

	if([vcont isVisible]) {

		[ges resetAnimated:YES];
	} else if ([(SpringBoard*)[%c(SpringBoard) sharedApplication] isLocked]) {
		[(UIViewController *)[[UIApplication sharedApplication] keyWindow].rootViewController presentModalViewController:vcont animated:YES];
		[ges revealAnimated:YES];
	}else {
		[%c(SearchLightActivator) rotate];
		//[[%c(SBSearchViewController) sharedInstance] forceRotation];

		//[[%c(SBSearchViewController) sharedInstance] activeInterfaceOrientationDidChangeToOrientation:[(SpringBoard *)[%c(SpringBoard) sharedApplication] interfaceOrientationForCurrentDeviceOrientation] willAnimateWithDuration:0.0f fromOrientation:0];
		

		[[%c(SBSearchViewController) sharedInstance] activeInterfaceOrientationWillChangeToOrientation:[(SpringBoard *)[%c(SpringBoard) sharedApplication] interfaceOrientationForCurrentDeviceOrientation]];

		//[[%c(SBSearchViewController) sharedInstance] _rotatePresentingWindowIfNecessaryTo:[(SpringBoard *)[%c(SpringBoard) sharedApplication] interfaceOrientationForCurrentDeviceOrientation] withDuration:0.0f];

			// SBSearchGesture *ges = [%c(SBSearchGesture) sharedInstance];
		 [ges updateForRotation];

		window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

		 // UIWindow *tempWindow = MSHookIvar<UIWindow *>(vcont, "_presentingWindow");
		 // if (tempWindow) {
		 //    tempWindow = window;
		 // }

		// window.rootViewController = vcont;
		// [window setRootViewController:vcont];
		UIStatusBar *status = [(SpringBoard *)[%c(SpringBoard) sharedApplication] statusBar];
		NSLog(@"statusbar = %f",((UIWindow *)[status statusBarWindow]).windowLevel);
		NSLog(@"statusbar.windowLevel %f",UIWindowLevelStatusBar);
		window.windowLevel = UIWindowLevelStatusBar - 5; //one less than the statusbar
		// if ([(SpringBoard*)[%c(SpringBoard) sharedApplication] isLocked]) {
		// 	window.windowLevel = 1051;
			
		// 	if ([objc_getClass("CVLockController") class]) {
		// 		// Convergance support
		// 		if ([objc_getClass("CVResources") lockScreenEnabled])
		// 			window.windowLevel = 1065;
		// 	}
		// }
		// if([[%c(SBUIController) sharedInstance] isAppSwitcherShowing]) {
		// 	window.windowLevel = 10000;
		// }

		 window.rootViewController = vcont;

        [window setRootViewController:vcont];
			
		[window setDelegate:vcont];
		[window setContentView:view];
		[window makeKeyAndVisible];
		//[window makeKeyAndOrderFront:nil];
		[ges setTargetView:window];
		[ges updateForRotation];
		[%c(SearchLightActivator) rotate];
		// [vcont _lockScreenUIWillLock:NO];

			
		// [ges setTargetView:window]; // This is for animations
		// [window setDelegate:vcont];
		// [window setContentView:vcont.view];
		// [window makeKeyAndVisible];
		// [window makeKeyAndOrderFront:nil];
		// UIViewController *
		// UIWindow *keyWindow = [%c(SpringBoard) sharedApplication].keyWindow;
		// NSLog(@"keyWindow = %@",keyWindow);
		// oldController = [%c(SpringBoard) sharedApplication].keyWindow.rootViewController;
		// NSLog(@"oldController = %@",oldController);
		// NSLog(@"UIApplication = %@",[UIApplication sharedApplication]);
		// [ges setTargetView:[%c(SpringBoard) sharedApplication].keyWindow];
		// [[%c(SpringBoard) sharedApplication].keyWindow addSubview:vcont.view];
		// //[[%c(SpringBoard) sharedApplication].keyWindow.rootViewController presentViewController:vcont animated:NO completion:nil];
		// [keyWindow makeKeyAndVisible];
		// if ([[view superview] isKindOfClass:[%c(SBRootFolderView) class]]) {
		// 	fv = [(SBRootFolderView *)[view superview] retain];
		// 	if([[fv delegate] isKindOfClass:[%c(SBRootFolderController) class]]) 
		// 		fvd = [[fv delegate] retain];
		// }

		//UIViewController *vc = MSHookIvar<UIViewController *>([%c(SBSearchViewController) sharedInstance], "_mainViewController");
		// NSLog(@"main View Controller = %@",vc);
		// originalWindow = MSHookIvar<UIWindow *>([%c(SBSearchViewController) sharedInstance], "_presentingWindow");
		// NSLog(@"presenting Window = %@", originalWindow);
		// UINavigationController *nc = MSHookIvar<UINavigationController *>([%c(SBSearchViewController) sharedInstance], "_navigationController");
		// NSLog(@"main Nav Controller = %@",nc);
		// NSLog(@"vcont's window = %@",vcont.window);
		//NSLog(@"main view controller's window = %@",vc.window);

		//vc.window.windowLevel = 100000;


		[ges revealAnimated:YES];
		
		[%c(SearchLightActivator) rotate];
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

+(void)rotate {
	float orientation = [(SpringBoard *)[%c(SpringBoard) sharedApplication] interfaceOrientationForCurrentDeviceOrientation];
	NSLog(@"rotatating to %f",orientation);
		[%c(SBSearchViewController) attemptRotationToDeviceOrientation];


		[vcont setInterfaceOrientation:orientation];

		[[%c(SBSearchViewController) sharedInstance] activeInterfaceOrientationWillChangeToOrientation:orientation];
		[[%c(SBSearchViewController) sharedInstance] _rotatePresentingWindowIfNecessaryTo:orientation withDuration:1.0f];


		SBSearchGesture *ges = [%c(SBSearchGesture) sharedInstance];
		 [ges updateForRotation];

		 [vcont activeInterfaceOrientationWillChangeToOrientation:orientation];
		 [vcont activeInterfaceOrientationDidChangeToOrientation:orientation willAnimateWithDuration:0.0 fromOrientation:1];
		
	//}
	if(window) {
		[vcont window:window shouldAutorotateToInterfaceOrientation:orientation];
		[[%c(SBSearchViewController) sharedInstance] window:window shouldAutorotateToInterfaceOrientation:orientation];
		[window _updateToInterfaceOrientation:orientation duration:0.0f force:YES];
		[window _setRotatableViewOrientation:orientation duration:0.0f force:YES];
	}

	setHeader();
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
	%orig;
	%log;
	UIViewController *vc = MSHookIvar<UIViewController *>([%c(SBSearchViewController) sharedInstance], "_mainViewController");
	NSLog(@"main View Controller = %@",vc);
	originalWindow = MSHookIvar<UIWindow *>([%c(SBSearchViewController) sharedInstance], "_presentingWindow");
	NSLog(@"presenting Window = %@", originalWindow);
	UINavigationController *nc = MSHookIvar<UINavigationController *>([%c(SBSearchViewController) sharedInstance], "_navigationController");
	NSLog(@"main Nav Controller = %@",nc);
	setHeader();
}
-(void)resetAnimated:(BOOL)arg1 {
	
	UIViewController *vc = MSHookIvar<UIViewController *>([%c(SBSearchViewController) sharedInstance], "_mainViewController");
	NSLog(@"main View Controller = %@",vc);
	originalWindow = MSHookIvar<UIWindow *>([%c(SBSearchViewController) sharedInstance], "_presentingWindow");
	NSLog(@"presenting Window = %@", originalWindow);
	UINavigationController *nc = MSHookIvar<UINavigationController *>([%c(SBSearchViewController) sharedInstance], "_navigationController");
	NSLog(@"main Nav Controller = %@",nc);
	NSLog(@"vcont's window = %@",vcont.window);
	NSLog(@"main view controller's window = %@",vc.window);
	%orig;
	%log;
	// if(oldController) {
	// 	[[%c(SpringBoard) sharedApplication].keyWindow.rootViewController presentViewController:oldController animated:NO completion:nil];
	// 	oldController = nil;
	// }

	if ([(SpringBoard*)[%c(SpringBoard) sharedApplication] isLocked]) {
		[(UIViewController *)[[UIApplication sharedApplication] keyWindow].rootViewController dismissModalViewControllerAnimated:YES];
		if(gesTargetview) {
			SBSearchGesture *ges = [%c(SBSearchGesture) sharedInstance];
   			[ges setTargetView:gesTargetview];
		}
		if(fv) {
			[fv addSubview:MSHookIvar<UIView *>(vcont, "_view")];
		}
	}


    if(window) {
		[vcont _fadeForLaunchWithDuration:0.3f completion:^void{
			SBSearchGesture *ges = [%c(SBSearchGesture) sharedInstance];
	   		[ges setTargetView:gesTargetview];

			for(id view in [window subviews]) {
				[fv addSubview:view];
			}

			[window resignKeyWindow];
			[window release];
			window = nil;
		}];
	}

	if(applicationIdentifier) {
		[[UIApplication sharedApplication] launchApplicationWithIdentifier:applicationIdentifier suspended:NO];
	}
	applicationIdentifier = nil;
	

}
%end

%hook SpringBoard

-(void)noteInterfaceOrientationChanged:(int)arg1 duration:(float)arg2 {
	//if(logging) %log;
	//[window _updateInterfaceOrientationFromDeviceOrientationIfRotationEnabled:YES];
	//[window _updateToInterfaceOrientation:arg1 duration:arg2 force:1];
	%orig;
	%log;

	[%c(SearchLightActivator) rotate];
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
    //CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("org.thebigboss.listlauncher7/settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("org.thebigboss.searchlight/saved"), NULL, CFNotificationSuspensionBehaviorCoalesce);

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
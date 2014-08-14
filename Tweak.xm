#import "CydiaSubstrate.h"
#import "headers.h"
#import <UIKit/UIKit.h>

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

static bool logging, hideKeyboard, selectall = false;

static NSMutableArray *indexValues = nil;
static NSMutableArray *indexPositions = nil; 

%hook SBSearchViewController
%new 
-(BOOL)shouldDisplayListLauncher {
	SBSearchHeader *sheader = MSHookIvar<SBSearchHeader *>(self, "_searchHeader");
	NSString *currentText = [sheader searchField].text;
	return [currentText isEqualToString:@""];
}

%new 
-(id)applicationList { return applicationList; }
%new 
-(id)sortedDisplayIdentifiers { return sortedDisplayIdentifiers; }

-(id)getIndex {
	return nil;
}

%new
-(id)sectionIndexTitlesForTableView:(id)arg1 {
	if(logging) %log;
	if([self shouldDisplayListLauncher]) return indexValues;
	return nil;
}

-(void)searchGesture:(id)arg1 completedShowing:(BOOL)arg2  {
	%orig;
	if(hideKeyboard && arg2)
		[self _setShowingKeyboard:NO];
}

-(void)_setShowingKeyboard:(BOOL)arg1 {
	%orig;
	if(arg1 && selectall) {
		SBSearchHeader *sheader = MSHookIvar<SBSearchHeader *>(self, "_searchHeader");
		if(![[sheader searchField].text isEqual:@""]) {
			[[sheader searchField] selectAll:self];
		}
	}
}

-(int)tableView:(UITableView *)arg1 numberOfRowsInSection:(int)arg2 {
	if(logging) %log;
	if([self shouldDisplayListLauncher]) {
		if([[enabledSections objectAtIndex:arg2] isEqual:@"Application List"]) {
			return [listLauncherDisplayIdentifiers count];
		} else if([[enabledSections objectAtIndex:arg2] isEqual:@"Favorites"]) {
			return [favoritesDisplayIdentifiers count];
		} else if([[enabledSections objectAtIndex:arg2] isEqual:@"Recent"]) {
			if(maxRecent > [recentApplications count]) return [recentApplications count];
			return maxRecent;
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

-(BOOL)tableView:(UITableView *)arg1 wantsHeaderForSection:(int)arg2 {
	if(logging) %log;
	arg1.sectionIndexColor = [UIColor whiteColor]; // text color
	arg1.sectionIndexTrackingBackgroundColor = [UIColor clearColor]; //bg touched
	arg1.sectionIndexBackgroundColor = [UIColor clearColor]; //bg
	return %orig;
}

-(BOOL)_hasResults {
	if(logging) %log;
	if([self shouldDisplayListLauncher] && [enabledSections count] > 0) {
		return YES;
	}
	return %orig;
}

-(id)tableView:(UITableView *)arg1 cellForRowAtIndexPath:(NSIndexPath *)arg2 {
	if(logging) %log;
	if(arg2.row > [listLauncherDisplayIdentifiers count]-1) { return %orig; } // fix for SpotDefine
	if([self shouldDisplayListLauncher]) {

		NSString *identifier = [@"" retain];

		if([[enabledSections objectAtIndex:arg2.section] isEqual:@"Application List"]) {
			identifier = [listLauncherDisplayIdentifiers objectAtIndex:arg2.row];
		} else if([[enabledSections objectAtIndex:arg2.section] isEqual:@"Favorites"]) {
			identifier = [favoritesDisplayIdentifiers objectAtIndex:arg2.row];
		} else if([[enabledSections objectAtIndex:arg2.section] isEqual:@"Recent"]) {
			identifier = [recentApplications objectAtIndex:arg2.row];
		}


		SBSearchTableViewCell *cell = [arg1 dequeueReusableCellWithIdentifier:@"dude"];
		NSString *name = [applicationList valueForKey:@"displayName" forDisplayIdentifier:identifier];
		//NSLog(@"Name = %@",name);
		if(!cell) {
			cell = [[[%c(SBSearchTableViewCell) alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"listlauncher7"] autorelease];
		}
		[cell setTitle:name];
		if(arg2.row == 0) {
			[cell setFirstInSection:YES];
			//[cell setFirstInTableView:YES];
		} else {
			[cell setFirstInSection:NO];
			//[cell setFirstInTableView:NO];
		}
		if(arg2.row == [self tableView:arg1 numberOfRowsInSection:arg2.section]) {
			[cell setIsLastInSection:YES];
		} else {
			[cell setIsLastInSection:NO];
		}

		UIImage *icon = [applicationList iconOfSize:59 forDisplayIdentifier:identifier];
		//cell.sectionHeaderWidth = 59.0f;
		[cell setTitleImage:icon animated:NO];
		[cell setHasImage:YES];
		return cell;
	}

	arg1.sectionIndexColor = [UIColor whiteColor]; // text color
	arg1.sectionIndexTrackingBackgroundColor = [UIColor clearColor]; //bg touched
	arg1.sectionIndexBackgroundColor = [UIColor clearColor]; //bg touched
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
			identifier = @"";
		}

	    [tableView deselectRowAtIndexPath:indexPath animated:YES];

	    SBIconController *cont = [%c(SBIconController) sharedInstance];
	    SBIconModel *model = [cont model];
		SBIcon *icon = [model expectedIconForDisplayIdentifier:identifier];
		[self _fadeForLaunchWithDuration:0.3f completion:^void{[icon launchFromLocation:4];}];
	} else	%orig;
}

-(id)tableView:(id)arg1 viewForHeaderInSection:(int)arg2 {
	if(logging) %log;
	SBSearchTableHeaderView *header = %orig;
	if([self shouldDisplayListLauncher]){
		if([[enabledSections objectAtIndex:arg2] isEqual:@"Application List"]) {
			[header setTitle:applicationListName];
		} else if([[enabledSections objectAtIndex:arg2] isEqual:@"Favorites"]) {
			[header setTitle:favoritesName];
		} else if([[enabledSections objectAtIndex:arg2] isEqual:@"Recent"]) {
			[header setTitle:recentName];
		}
	}
	return header;
}

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
	favoriteList =  [[[favoriteList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
	    return 	[[favoriteList objectAtIndex:[favoriteList indexOfObject:obj1]] objectAtIndex:1] > [[favoriteList objectAtIndex:[favoriteList indexOfObject:obj2]] objectAtIndex:1]	;}] mutableCopy] retain];
	for(id spec in favoriteList) {
		[favoritesDisplayIdentifiers insertObject:[spec objectAtIndex:0] atIndex:[favoritesDisplayIdentifiers count]];
	}
	[favoriteList release];

}

static void generateAppList () {
	NSString *plistPath = @"/var/mobile/Library/Preferences/org.thebigboss.listlauncher7.applist.plist";
	NSMutableDictionary *appsettings = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
	if(!appsettings) {
			appsettings = [NSMutableDictionary dictionary];
			[appsettings writeToFile:plistPath atomically:YES];
	}
	[appsettings setValue:sortedDisplayIdentifiers forKey:@"applications"];
	[appsettings writeToFile:plistPath atomically:YES];
}

static void loadPrefs() {

	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/org.thebigboss.listlauncher7.plist"];

	logging = [settings objectForKey:@"logging_enabled"] ? [[settings objectForKey:@"logging_enabled"] boolValue] : NO;

	if(logging) NSLog(@"ListLauncher7 Settings = %@",settings);

	hideKeyboard = [settings objectForKey:@"hide_keyboard"] ? [[settings objectForKey:@"hide_keyboard"] boolValue] : NO;

	selectall = [settings objectForKey:@"hide_keyboard"] ? [[settings objectForKey:@"selectall"] boolValue] : NO;


	enabledSections = [settings objectForKey:@"enabledSections"] ?: @[]; [enabledSections retain];
    maxRecent = [settings objectForKey:@"maxRecent"] ? [[settings objectForKey:@"maxRecent"] integerValue] : 3;
	applicationList = [[ALApplicationList sharedApplicationList] retain];
	recentName = [settings objectForKey:@"recentName"] ?: recentName; recentName = [recentName isEqual:@""] ? @"RECENT" : recentName;
	applicationListName = [settings objectForKey:@"applicationListName"] ?: applicationListName; applicationListName = [applicationListName isEqual:@""] ? @"APPLICATION LIST" : applicationListName;
	favoritesName = [settings objectForKey:@"applicationListName"] ?: favoritesName; favoritesName = [applicationListName isEqual:@""] ? @"FAVORITES" : favoritesName;

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

	SBAppSwitcherModel *switcherModel = [%c(SBAppSwitcherModel) sharedInstance];
	recentApplications = [[switcherModel identifiers] retain];

	if(logging) NSLog(@"Done with settings");
}

%hook SBAppSwitcherModel
-(void)appsRemoved:(id)arg1 added:(id)arg2 {
	%orig;
	recentApplications = [[self identifiers] retain];
}
-(void)remove:(id)arg1 {
	%orig;
	recentApplications = [[self identifiers] retain];
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

%ctor {
	dlopen("/Library/MobileSubstrate/DynamicLibraries/SpotDefine.dylib", RTLD_NOW);
	dlopen("/Library/MobileSubstrate/DynamicLibraries/SearchPlus.dylib", RTLD_NOW);
    //CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("org.thebigboss.listlauncher7/settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("org.thebigboss.listlauncher7/saved"), NULL, CFNotificationSuspensionBehaviorCoalesce);

    loadPrefs();
}
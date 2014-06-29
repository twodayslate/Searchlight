#import "CydiaSubstrate.h"
#import <UIKit/UIKit.h>

@interface SBSearchViewController : UIViewController <UITableViewDataSource>
-(BOOL)shouldDisplayListLauncher;
-(void)dismiss;
-(void)_fadeForLaunchWithDuration:(double)arg1 completion:(/*^block*/ id)arg2 ;
-(int)numberOfSectionsInTableView:(id)arg1;
-(void)_updateTableContents;
+(id)sharedInstance;
-(id)sectionIndexTitlesForTableView:(id)arg1;
-(int)tableView:(id)arg1 sectionForSectionIndexTitle:(id)arg2 atIndex:(int)arg3;
@end

@interface SBSearchHeader
-(UITextField *)searchField;
@end

@interface SBSearchTableViewCell : UITableViewCell
-(void)setTitle:(id)arg1;
-(void)setFirstInSection:(BOOL)arg1 ;
-(void)setIsLastInSection:(BOOL)arg1 ;
-(void)setTitleImage:(id)arg1 animated:(BOOL)arg2 ;
-(void)setHasImage:(BOOL)arg1 ;
@end

@interface ALApplicationList 
@property (nonatomic, readonly) NSDictionary *applications;
-(id)sharedApplicationList;
- (id)valueForKey:(NSString *)keyPath forDisplayIdentifier:(NSString *)displayIdentifier;
-(NSInteger)applicationCount;
- (UIImage *)iconOfSize:(int)iconSize forDisplayIdentifier:(NSString *)displayIdentifier;
@end

@interface SpringBoard
-(BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2 ;
@end

@interface SBSearchTableHeaderView : UIView 
-(void)setTitle:(id)arg1 ;
@end

@interface SBIcon
-(void)launchFromLocation:(int)arg1;
@end

@interface SBIconModel
-(id)expectedIconForDisplayIdentifier:(id)arg1 ;
@end

@interface SBIconController
-(id)sharedInstance;
-(SBIconModel *)model;
@end



static ALApplicationList *apps = nil;

static NSMutableArray *favoritesDisplayIdentifiers = nil;
static NSMutableArray *listLauncherDisplayIdentifiers = nil;

static bool favorites = false;
static bool listlauncher = true;
static NSMutableArray *alphabet = nil;
static NSMutableArray *indexPositions = nil; 

%hook SBSearchViewController
%new 
-(BOOL)shouldDisplayListLauncher {
	SBSearchHeader *sheader = MSHookIvar<SBSearchHeader *>(self, "_searchHeader");
	NSString *currentText = [sheader searchField].text;
	return [currentText isEqualToString:@""];
}

-(id)getIndex {
	return nil;
}

%new
-(id)sectionIndexTitlesForTableView:(id)arg1 {
	if([self shouldDisplayListLauncher] and listlauncher) return alphabet;
	return nil;
}

-(int)tableView:(UITableView *)arg1 numberOfRowsInSection:(int)arg2 {
	if([self shouldDisplayListLauncher]) {
		if(favorites) {
			if(listlauncher) {
				if(arg2 == [self numberOfSectionsInTableView:arg1]-2)
					return [favoritesDisplayIdentifiers count];
			} else if(arg2 == [self numberOfSectionsInTableView:arg1]-1) {
				return [favoritesDisplayIdentifiers count];
			}
		}
		if(listlauncher) {
			if(arg2 == [self numberOfSectionsInTableView:arg1]-1) return [listLauncherDisplayIdentifiers count];
		}
	}
	arg1.sectionIndexColor = [UIColor whiteColor]; // text color
	arg1.sectionIndexTrackingBackgroundColor = [UIColor clearColor]; //bg touched
	arg1.sectionIndexBackgroundColor = [UIColor clearColor]; //bg touched

	return %orig;
}

-(int)numberOfSectionsInTableView:(id)arg1 	{
	int ans = 0; 
	if(favorites) ans = ans + 1;
	if(listlauncher) ans = ans + 1;
	if([self shouldDisplayListLauncher]) return %orig + ans;
	return %orig;
}

%new
-(int)tableView:(id)tableview sectionForSectionIndexTitle:(id)title atIndex:(int)index {
	%log;
	// NSString *name = [apps valueForKey:@"displayName" forDisplayIdentifier:[listLauncherDisplayIdentifiers objectAtIndex:arg3]];

	// NSLog(@"Matches?  = %d",(int)[alphabet indexOfObject:[name substringToIndex:1]]);
	// if([alphabet indexOfObject:[name substringToIndex:1]]) {
	// 	return (int) [alphabet indexOfObject:[name substringToIndex:1]];
	// }
	// else { return 0; }
	int numSections = [tableview numberOfSections];
	NSLog(@"numSections = %d",numSections);

	if(favorites && index == numSections - 2) { return numSections - 2; }
	if(favorites && listlauncher && index > numSections - 2) {
		if(index == numSections - 1) return numSections - 1;

		NSLog(@"index positions = %@",indexPositions);

		NSLog(@"Before, indexPositions size = %i",(int)[indexPositions count]);
		id value = [indexPositions objectAtIndex:index];
		int i = [[indexPositions objectAtIndex:index] integerValue];
		NSLog(@"After value = %d = %@",i,value);

		[tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:numSections - 1] atScrollPosition:UITableViewScrollPositionTop animated:NO];
		// http://the-useful.blogspot.com/2011/10/uitableview-section-index-view-without.html
	}
	if(listlauncher) {
		id value = [indexPositions objectAtIndex:index];
		int i = [[indexPositions objectAtIndex:index] integerValue];
		NSLog(@"After value = %d = %@",i,value);

		[tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:numSections - 1] atScrollPosition:UITableViewScrollPositionTop animated:NO];
	}
	return index;
	//return (int)[alphabet indexOfObject:title];
}

-(BOOL)tableView:(id)arg1 wantsHeaderForSection:(int)arg2 {
	//if([self shouldDisplayListLauncher]) return NO;
	return %orig;
}

-(BOOL)_hasResults {
	if([self shouldDisplayListLauncher] && (listlauncher || favorites)) {
		return YES;
	}
	return %orig;
}

-(id)tableView:(id)arg1 cellForRowAtIndexPath:(NSIndexPath *)arg2 {
	if(arg2.row > [listLauncherDisplayIdentifiers count]-1) { return %orig; } // fix for SpotDefine
	if([self shouldDisplayListLauncher]) {

		NSMutableArray *displayIdentifiers = nil;

		if(favorites) {
			if(listlauncher) {
				if(arg2.section == [self numberOfSectionsInTableView:arg1]-2)
					displayIdentifiers = favoritesDisplayIdentifiers;
			} else if(arg2.section == [self numberOfSectionsInTableView:arg1]-1) {
				displayIdentifiers = favoritesDisplayIdentifiers;
			}
		}
		if(listlauncher) {
			if(arg2.section == [self numberOfSectionsInTableView:arg1]-1) displayIdentifiers = listLauncherDisplayIdentifiers;
		}


		SBSearchTableViewCell *cell = [arg1 dequeueReusableCellWithIdentifier:@"dude"];
		NSString *name = [apps valueForKey:@"displayName" forDisplayIdentifier:[displayIdentifiers objectAtIndex:arg2.row]];
		//NSLog(@"Name = %@",name);
		if(cell) {  }
		else {
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
		if(arg2.row == [self tableView:arg1 numberOfRowsInSection:arg2.row]) {
			[cell setIsLastInSection:YES];
		} else {
			[cell setIsLastInSection:NO];
		}

		NSString *displayIdentifier = [displayIdentifiers objectAtIndex:arg2.row];
		UIImage *icon = [apps iconOfSize:59 forDisplayIdentifier:displayIdentifier];
		//cell.sectionHeaderWidth = 59.0f;
		[cell setTitleImage:icon animated:NO];
		[cell setHasImage:YES];
		return cell;
	}
	return %orig;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self shouldDisplayListLauncher]) {
    	[self dismiss];

    	NSMutableArray *displayIdentifiers = nil;

    	if(favorites) {
			if(listlauncher) {
				if(indexPath.section == [self numberOfSectionsInTableView:tableView]-2)
					displayIdentifiers = favoritesDisplayIdentifiers;
			} else if(indexPath.section == [self numberOfSectionsInTableView:tableView]-1) {
				displayIdentifiers = favoritesDisplayIdentifiers;
			}
		}
		if(listlauncher) {
			if(indexPath.section == [self numberOfSectionsInTableView:tableView]-1) displayIdentifiers = listLauncherDisplayIdentifiers;
		}

	    NSString *displayIdentifier = [displayIdentifiers objectAtIndex:indexPath.row];

	    //[[objc_getClass("SBUIController") sharedInstance] activateApplicationAnimated:displayIdentifier];
	    
	    [tableView deselectRowAtIndexPath:indexPath animated:YES];

	    //NSLog(@"launching %@",displayIdentifier);

	    SBIconController *cont = [%c(SBIconController) sharedInstance];
	    SBIconModel *model = [cont model];
		SBIcon *icon = [model expectedIconForDisplayIdentifier:displayIdentifier];
		[self _fadeForLaunchWithDuration:0.3f completion:^void{[icon launchFromLocation:4];}];
		
	    //[(SpringBoard *)[UIApplication sharedApplication] launchApplicationWithIdentifier:displayIdentifier suspended:NO];
	} else	%orig;
}

-(id)tableView:(id)arg1 viewForHeaderInSection:(int)arg2 {
	SBSearchTableHeaderView *header = %orig;
	if(favorites) {
			if(listlauncher) {
				if(arg2 == [self numberOfSectionsInTableView:arg1]-2)
					[header setTitle:@"FAVORITES"];
			} else if(arg2 == [self numberOfSectionsInTableView:arg1]-1) {
				[header setTitle:@"FAVORITES"];
			}
		}
	if(listlauncher) {
		if(arg2 == [self numberOfSectionsInTableView:arg1]-1) [header setTitle:@"LISTLAUNCHER7"];
	}
	return header;
}

%end

static void createAlphabet() {
	NSLog(@"Inside");
	alphabet = [NSMutableArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G", @"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",nil];
	
	if(listlauncher) {
		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-Z]" options:0 error:NULL];
		NSString *firstAppName = [[apps valueForKey:@"displayName" forDisplayIdentifier:[listLauncherDisplayIdentifiers objectAtIndex:0]] substringToIndex:1];
		NSTextCheckingResult *match = [regex firstMatchInString:firstAppName options:0 range:NSMakeRange(0, [firstAppName length])];
		NSLog(@"Match = %@",match);
		if(!match) { NSLog(@" removed first inside"); 
			[alphabet insertObject:@"#" atIndex:0];
		}
	}

	indexPositions = [NSMutableArray arrayWithArray:alphabet]; 

	NSLog(@"Before modifying = %@",indexPositions);
	for(int i = 0; i < [indexPositions count]; i++) {
		for(int identifierIndex = 0; identifierIndex < [listLauncherDisplayIdentifiers count]; identifierIndex++) {
			if([[apps valueForKey:@"displayName" forDisplayIdentifier:[listLauncherDisplayIdentifiers objectAtIndex:identifierIndex]] hasPrefix:[alphabet objectAtIndex:i]]) {
				NSInteger myInt = identifierIndex;
				NSNumber *myNSNumber = [[NSNumber alloc] initWithInt:myInt];
				[indexPositions replaceObjectAtIndex:i withObject:myNSNumber];
				i++;
			}
		}
	}

	for(int i = 0; i < [indexPositions count]; i++) {
		if([[indexPositions objectAtIndex:i] integerValue] == 0 && i > 0) {
			if(!( [[indexPositions objectAtIndex:i] isEqual:@"#"] || [[indexPositions objectAtIndex:i] isEqual:@" "] || [[indexPositions objectAtIndex:i] isEqual:@"☆"])) {
				NSLog(@"Removing %@ at index %d",[alphabet objectAtIndex:i],i);
				[alphabet removeObjectAtIndex:i];
				[indexPositions removeObjectAtIndex:i];
				i = 0;
			}
		}
	}

	if(favorites) {
			[alphabet insertObject:@" " atIndex:0];
			[alphabet insertObject:@"☆" atIndex:0];
			[indexPositions insertObject:@"0" atIndex:0];
			[indexPositions insertObject:@"0" atIndex:0];
	}

	NSLog(@"After modifying = %@",indexPositions);

	[indexPositions retain];
	[alphabet retain];

}

static void loadPrefs() {
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/org.thebigboss.listlauncher7.plist"];

	NSLog(@"Settings = %@",settings);

    favorites = [[settings objectForKey:@"favorites_enabled"] boolValue]; 
    listlauncher = [[settings objectForKey:@"listlauncher_enabled"] boolValue]; 

	apps = [ALApplicationList sharedApplicationList];

	NSArray *listLauncherDisplayIdentifiersTemp = [[apps.applications allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
	    return [[apps.applications objectForKey:obj1] caseInsensitiveCompare:[apps.applications objectForKey:obj2]];}];

	listLauncherDisplayIdentifiers = [NSMutableArray arrayWithArray:listLauncherDisplayIdentifiersTemp];
	favoritesDisplayIdentifiers = [[NSMutableArray alloc] init];

	for(NSString* key in [settings allKeys]) {
		if([[settings valueForKey:key] boolValue] && [key rangeOfString:@"blacklist-"].location != NSNotFound) {
			[listLauncherDisplayIdentifiers removeObject:[key stringByReplacingOccurrencesOfString:@"blacklist-" withString:@""]];
		}
		if([[settings valueForKey:key] boolValue] && [key rangeOfString:@"whitelist-"].location != NSNotFound) {
			[favoritesDisplayIdentifiers addObject:[key stringByReplacingOccurrencesOfString:@"whitelist-" withString:@""]];
		}
	}

	favoritesDisplayIdentifiers = [NSMutableArray arrayWithArray:[favoritesDisplayIdentifiers sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
	    return [[apps.applications objectForKey:obj1] caseInsensitiveCompare:[apps.applications objectForKey:obj2]];}]];

		//for(NSString *key in listLauncherDisplayIdentifiers) {

	createAlphabet();


	// favoritesDisplayIdentifiers = [[NSMutableArray alloc] init];
	// for(NSString* key in [settings allKeys]) {
	// 	if([[settings valueForKey:key] boolValue] && [key rangeOfString:@"whitelist-"].location != NSNotFound) {
	// 		[favoritesDisplayIdentifiers addObject:[key stringByReplacingOccurrencesOfString:@"whitelist-" withString:@""]];
	// 	}
	// }
	//NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"text" ascending:YES];
	//[favoritesDisplayIdentifiers sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
	//NSLog(@"Before = %@",favoritesDisplayIdentifiers);

	//[favoritesDisplayIdentifiers sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

	//NSLog(@"After = %@",favoritesDisplayIdentifiers);

	[listLauncherDisplayIdentifiers retain];
	[favoritesDisplayIdentifiers retain];

	[settings release];
	SBSearchViewController *sview = [%c(SBSearchViewController) sharedInstance];
	//[sview _updateTableContents];
	UITableView *stable = MSHookIvar<UITableView *>(sview, "_tableView");
	[stable reloadData];
}

%ctor {
	dlopen("/Library/MobileSubstrate/DynamicLibraries/SpotDefine.dylib", RTLD_NOW);
    //CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("org.thebigboss.listlauncher7/settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("org.thebigboss.listlauncher7/saved"), NULL, CFNotificationSuspensionBehaviorCoalesce);

    loadPrefs();
}
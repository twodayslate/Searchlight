#import "CydiaSubstrate.h"
#import <UIKit/UIKit.h>

@interface SBSearchViewController
-(BOOL)shouldDisplayListLauncher;
-(void)dismiss;
-(void)_fadeForLaunchWithDuration:(double)arg1 completion:(/*^block*/ id)arg2 ;
-(int)numberOfSectionsInTableView:(id)arg1;
-(void)_updateTableContents;
+(id)sharedInstance;
@end

@interface SBSearchHeader
-(UITextField *)searchField;
@end

@interface SBSearchTableViewCell : UITableViewCell
-(void)setTitle:(id)arg1;
-(void)setFirstInSection:(BOOL)arg1 ;
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
static NSMutableDictionary *blacklist = nil;
static NSMutableArray *displayIdentifiers = nil;

%hook SBSearchViewController
%new 
-(BOOL)shouldDisplayListLauncher {
	SBSearchHeader *sheader = MSHookIvar<SBSearchHeader *>(self, "_searchHeader");
	NSString *currentText = [sheader searchField].text;
	return [currentText isEqualToString:@""];
}

-(int)tableView:(id)arg1 numberOfRowsInSection:(int)arg2 {
	if([self shouldDisplayListLauncher] && arg2 == [self numberOfSectionsInTableView:arg1]-1) return [displayIdentifiers count];
	return %orig;
}

-(int)numberOfSectionsInTableView:(id)arg1 	{
	if([self shouldDisplayListLauncher]) return %orig + 1;
	return %orig;
}

-(BOOL)tableView:(id)arg1 wantsHeaderForSection:(int)arg2 {
	//if([self shouldDisplayListLauncher]) return NO;
	return %orig;
}

-(BOOL)_hasResults {
	if([self shouldDisplayListLauncher]) {

		return YES;
	}
	return %orig;
}

-(id)tableView:(id)arg1 cellForRowAtIndexPath:(NSIndexPath *)arg2 {
	if(arg2.row > [displayIdentifiers count]-1) { return %orig; } // fix for SpotDefine
	if([self shouldDisplayListLauncher]) {
		SBSearchTableViewCell *cell = [arg1 dequeueReusableCellWithIdentifier:@"dude"];
		NSString *name = [apps valueForKey:@"displayName" forDisplayIdentifier:[displayIdentifiers objectAtIndex:arg2.row]];
		//NSLog(@"Name = %@",name);
		if(cell) {  }
		else {
			cell = [[[%c(SBSearchTableViewCell) alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"dude"] autorelease];
		}
		[cell setTitle:name];
		if(arg2.row == 0) {
			[cell setFirstInSection:YES];
			//[cell setFirstInTableView:YES];
		} else {
			[cell setFirstInSection:NO];
			//[cell setFirstInTableView:NO];
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
	if([self shouldDisplayListLauncher] && arg2 == [self numberOfSectionsInTableView:arg1]-1) {
		[header setTitle:@"LISTLAUNCHER7"];
	}
	return header;
}

%end

static void loadPrefs() {
    blacklist = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/org.thebigboss.listlauncher7.plist"];

	apps = [ALApplicationList sharedApplicationList];

	NSArray *displayIdentifiersTemp = [[apps.applications allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
	    return [[apps.applications objectForKey:obj1] caseInsensitiveCompare:[apps.applications objectForKey:obj2]];}];

	displayIdentifiers = [NSMutableArray arrayWithArray:displayIdentifiersTemp];

	for(NSString* key in [blacklist allKeys]) {
		if([[blacklist valueForKey:key] boolValue]) {
			[displayIdentifiers removeObject:[key stringByReplacingOccurrencesOfString:@"Blacklist-" withString:@""]];
		}
	}

	[displayIdentifiers retain];
	[blacklist release];
	SBSearchViewController *sview = [%c(SBSearchViewController) sharedInstance];
	//[sview _updateTableContents];
	UITableView *stable = MSHookIvar<UITableView *>(sview, "_tableView");
	[stable reloadData];
}

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("org.thebigboss.listlauncher7/settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    loadPrefs();
}
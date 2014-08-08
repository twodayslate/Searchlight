#import "Preferences.h"
#import "AboutPref.h"
// #import "LLRecentController.h"
// #import "LLFavoritesController.h"
// #import "LLApplicationController.h"

@interface ListLauncherPrefListController: PSEditableListController <UITableViewDelegate, UITableViewDataSource> {
	NSMutableArray *enabledIdentifiers;
	NSMutableArray *disabledIdentifiers;
	NSArray *_sortedDisplayIdentifiers;
	ALApplicationList *_applicationList;
}
@property (nonatomic, retain) ALApplicationList *applicationList;
@property (nonatomic, retain) NSArray *sortedDisplayIdentifiers;
-(void) generateAppList;
@end

static NSString *plistPath = @"/var/mobile/Library/Preferences/org.thebigboss.listlauncher7.plist";

@implementation ListLauncherPrefListController

- (id)specifiers {
	if(_specifiers == nil) {

		NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];

		if(!_sortedDisplayIdentifiers || !_applicationList) {
			[self performSelectorInBackground:@selector(generateAppList) withObject:nil];
		}

		if(!settings) {
			settings = [NSMutableDictionary dictionary];
			[settings writeToFile:plistPath atomically:YES];
		}
		
		enabledIdentifiers = [(NSMutableArray *) [settings valueForKey:@"enabledSections"] retain];
		disabledIdentifiers = [(NSMutableArray *) [settings valueForKey:@"disabledSections"] retain];


		if(settings == nil || !enabledIdentifiers || !disabledIdentifiers) {
			NSLog(@"Setting up defaults");
			//set defaults
			enabledIdentifiers = [[[NSMutableArray alloc] init] retain];
			disabledIdentifiers = [[@[@"Recent", @"Favorites", @"Application List"] mutableCopy] retain];
			[settings setValue:enabledIdentifiers forKey:@"enabledSections"];
			[settings setValue:disabledIdentifiers forKey:@"disabledSections"];
			[settings writeToFile:plistPath atomically:YES];
		}

		_specifiers = [[self loadSpecifiersFromPlistName:@"ListLauncherPref" target:self] retain];

		for(id spec in [[enabledIdentifiers reverseObjectEnumerator] allObjects]) {
			NSString *classString = [@"LL" stringByAppendingString:[[[spec componentsSeparatedByString:@" "] objectAtIndex:0] stringByAppendingString:@"Controller"]];
			NSLog(@"Class String = %@",classString);
			PSSpecifier* firstSpecifier = [PSSpecifier preferenceSpecifierNamed:spec target:self set:nil get:nil detail:NSClassFromString(classString) cell:[PSTableCell cellTypeFromString:@"PSLinkCell"] edit:1];
			[_specifiers insertObject:firstSpecifier atIndex:1];
		}

		for(id spec in [[disabledIdentifiers reverseObjectEnumerator] allObjects]) {
			NSString *classString = [@"LL" stringByAppendingString:[[[spec componentsSeparatedByString:@" "] objectAtIndex:0] stringByAppendingString:@"Controller"]];
			NSLog(@"Class String = %@",classString);
			PSSpecifier* firstSpecifier = [PSSpecifier preferenceSpecifierNamed:spec target:self set:nil get:nil detail:NSClassFromString(classString) cell:[PSTableCell cellTypeFromString:@"PSLinkCell"] edit:1];
			[_specifiers insertObject:firstSpecifier atIndex:2+[enabledIdentifiers count]];
		}

		NSLog(@"settings = %@",settings);

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable:) name:@"reloadTable" object:nil];

		
	}

	NSLog(@"_specifiers = %@",_specifiers);
	
	return _specifiers;

}

- (void)dealloc {
	[disabledIdentifiers release];
	[enabledIdentifiers release];
	[super dealloc];
}

-(void)reloadTable:(NSNotification *)notification {
	NSLog(@"Reloading table");
	[self reload];
	[self reloadSpecifiers];
	[[self table] reloadData];
}

-(void)respring {
	system("killall -9 SpringBoard");
}

static CFStringRef aCFString = CFStringCreateWithCString(NULL, "org.thebigboss.listlauncher7/saved", kCFStringEncodingMacRoman);
-(void)save {
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), aCFString, NULL, NULL, YES);
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	tableView.allowsSelectionDuringEditing = YES;	
    if(indexPath.section == 0 || indexPath.section == 1) return YES;
    return NO;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}

- (BOOL) tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath { 
	return NO;
}
-(id)_editButtonBarItem { 
	return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	if (proposedDestinationIndexPath.section > 1) {
	    NSInteger row = 0;
	    if (sourceIndexPath.section < proposedDestinationIndexPath.section) {
	      row = [tableView numberOfRowsInSection:sourceIndexPath.section] - 1;
	    }
	    return [NSIndexPath indexPathForRow:row inSection:sourceIndexPath.section];     
	  }

  return proposedDestinationIndexPath;
}
// - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath 
// {
//     NSString *stringToMove = self.tableData[sourceIndexPath.row];
//     [self.tableData removeObjectAtIndex:sourceIndexPath.row];
//     [self.tableData insertObject:stringToMove atIndex:destinationIndexPath.row];
// }


-(int)inPathToIndex:(NSIndexPath *)index {
	return 1; 
}

-(void)tableView: (UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndex toIndexPath:(NSIndexPath *)toIndex {
	NSMutableDictionary *settings = [[[NSMutableDictionary alloc] initWithContentsOfFile:plistPath] retain];
	NSString *title = [@"" retain];

	NSLog(@"Before changes in settings = %@",settings);

	if(fromIndex.section == 0) { // Enabled 
		title = [enabledIdentifiers objectAtIndex:fromIndex.row];
		[enabledIdentifiers removeObjectAtIndex:fromIndex.row];
		[settings setValue:enabledIdentifiers forKey:@"enabledSections"];
	} else {
		title = [disabledIdentifiers objectAtIndex:fromIndex.row];
		[disabledIdentifiers removeObjectAtIndex:fromIndex.row];
		[settings setValue:disabledIdentifiers forKey:@"disabledSections"];
	}

	NSLog(@"Moving title = %@",title);

	if(toIndex.section == 0) { // Enabled 
		[enabledIdentifiers insertObject:title atIndex:toIndex.row];
		[settings setValue:enabledIdentifiers forKey:@"enabledSections"];
	} else { // disabled
		[disabledIdentifiers insertObject:title atIndex:toIndex.row];
		[settings setValue:disabledIdentifiers forKey:@"disabledSections"];
	}

	[settings writeToFile:plistPath atomically:YES];
	NSLog(@"After changes in settings = %@",settings);
	
	[title release];
	tableView.allowsSelectionDuringEditing = YES; 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	NSLog(@"accessoryType = %d",(int)cell.accessoryType);
	cell.editingAccessoryView = cell.accessoryView;
	if(indexPath.section < 2 || indexPath.section > 3)
		cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	tableView.allowsSelectionDuringEditing = YES; 
	tableView.editing = YES;
	[super setEditingButtonHidden:NO animated:NO];
	[super setEditButtonEnabled:NO];

	return cell;
}
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 5;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section == 0) return [enabledIdentifiers count]; //count
	if(section == 1) return [disabledIdentifiers count]; //count
	if(section == 2) return 1;
	if(section == 3) return 2; 
	if(section == 4) return 1;
	return 0; 
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	tableView.allowsSelectionDuringEditing = YES; 
	NSLog(@"attempting to select (%d,%d)",(int)indexPath.section,(int)indexPath.row);

	if(indexPath.section == 0) { // enabled 
		NSString *spec = [enabledIdentifiers objectAtIndex:indexPath.row];
		NSString *classString = [@"LL" stringByAppendingString:[[[spec componentsSeparatedByString:@" "] objectAtIndex:0] stringByAppendingString:@"Controller"]];
		LLFavoritesAddController *_controller = [[NSClassFromString(classString) alloc] init];
		_controller.sortedDisplayIdentifiers = [self sortedDisplayIdentifiers];
		_controller.applicationList = [self applicationList];
		if (_controller) {
			[self.navigationController pushViewController:_controller animated:YES];
		}
	} else if(indexPath.section == 1) { // disabled
		NSString *spec = [disabledIdentifiers objectAtIndex:indexPath.row];
		NSString *classString = [@"LL" stringByAppendingString:[[[spec componentsSeparatedByString:@" "] objectAtIndex:0] stringByAppendingString:@"Controller"]];
		LLFavoritesAddController *_controller = [[NSClassFromString(classString) alloc] init];
		_controller.sortedDisplayIdentifiers = [self sortedDisplayIdentifiers];
		_controller.applicationList = [self applicationList];
		if (_controller) {
			[self.navigationController pushViewController:_controller animated:YES];
		}
	} else { 
		[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	}
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

- (id) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *header = [super tableView:tableView titleForHeaderInSection:section];
	return header;
}

-(void)github {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/twodayslate"]];
}
-(void)paypal {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=2R9WDZCE7CPZ8"]];
}

-(void)bitcoin {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://coinbase.com/checkouts/59ead722b181591150e7de4ed6769cb4"]];
}

-(void)generateAppList {
	Class var = NSClassFromString(@"SBSearchViewController");

	SBSearchViewController *vcont = [var sharedInstance];
	NSLog(@"SBSearchViewController = %@",vcont);
	NSLog(@"applicationList = %@",[vcont applicationList]);

	_applicationList = [vcont applicationList] ?: [[ALApplicationList sharedApplicationList] retain];


	NSLog(@"before sort = %@",[_applicationList.applications allKeys]);
	NSLog(@"sortedDisplayIdentifiers = %@",[vcont sortedDisplayIdentifiers]);
	_sortedDisplayIdentifiers =  [vcont sortedDisplayIdentifiers] ?: [[[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/org.thebigboss.listlauncher7.applist.plist"] valueForKey:@"applications"] ?: [[[_applicationList.applications allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
	    return [[_applicationList.applications objectForKey:obj1] caseInsensitiveCompare:[_applicationList.applications objectForKey:obj2]];}] retain];
	
	NSLog(@"after sort = %@",_sortedDisplayIdentifiers);
	NSLog(@"DONE GENERATING APPLIST");
}

-(ALApplicationList *)applicationList {
	if(!_applicationList) [self generateAppList];
	return _applicationList;
}
-(NSArray *)sortedDisplayIdentifiers {
	if(!_sortedDisplayIdentifiers) [self generateAppList];
	return _sortedDisplayIdentifiers;
}

@end

// vim:ft=objc

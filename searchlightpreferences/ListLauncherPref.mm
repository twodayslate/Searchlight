#import "Preferences.h"
// #import "LLRecentController.h"
// #import "LLFavoritesController.h"
// #import "LLApplicationController.h"

@interface ListLauncherPrefListController: PSEditableListController <UITableViewDelegate, UITableViewDataSource> {
	NSMutableArray *_enabledIdentifiers;
	NSMutableArray *_disabledIdentifiers;
	NSArray *_sortedDisplayIdentifiers;
	ALApplicationList *_applicationList;
}
@property (nonatomic, retain) ALApplicationList *applicationList;
@property (nonatomic, retain) NSArray *sortedDisplayIdentifiers;
@property (nonatomic, retain) NSArray *enabledIdentifiers;
@property (nonatomic, retain) NSArray *disabledIdentifiers;
-(void) generateAppList;
@end

static NSString *plistPath = @"/var/mobile/Library/Preferences/org.thebigboss.searchlight.plist";

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
		
		_enabledIdentifiers = [(NSMutableArray *) [settings valueForKey:@"enabledSections"] retain];
		_disabledIdentifiers = [(NSMutableArray *) [settings valueForKey:@"disabledSections"] retain];


		if(settings == nil || !_enabledIdentifiers || !_disabledIdentifiers) {
			NSLog(@"Setting up defaults");
			//set defaults
			_enabledIdentifiers = [[NSMutableArray alloc] init];
			_disabledIdentifiers = [@[@"Recent", @"Favorites", @"Application List"] mutableCopy];
			[settings setValue:_enabledIdentifiers forKey:@"enabledSections"];
			[settings setValue:_disabledIdentifiers forKey:@"disabledSections"];
			[settings writeToFile:plistPath atomically:YES];
		}

		_specifiers = [[self loadSpecifiersFromPlistName:@"ListLauncherPref" target:self] retain];

		//NSLog(@"_specifiers = %@",_specifiers);
		for(id spec in [[_enabledIdentifiers reverseObjectEnumerator] allObjects]) {
			NSString *classString = [@"LL" stringByAppendingString:[[[spec componentsSeparatedByString:@" "] objectAtIndex:0] stringByAppendingString:@"Controller"]];
			PSSpecifier* firstSpecifier = [PSSpecifier preferenceSpecifierNamed:spec target:self set:nil get:nil detail:NSClassFromString(classString) cell:[PSTableCell cellTypeFromString:@"PSLinkCell"] edit:1];
			
			if([spec isEqual:@"Recent"]) {
				[firstSpecifier setProperty:@"Recents.png" forKey:@"icon"];
			} else if([spec isEqual:@"Favorites"]) {
				[firstSpecifier setProperty:@"Favorites.png" forKey:@"icon"];
			} else if([spec isEqual:@"Application List"]) {
				[firstSpecifier setProperty:@"Applications.png" forKey:@"icon"];
			}

			[_specifiers insertObject:firstSpecifier atIndex:5];
		}
		NSLog(@"_specifiers after enabled = %@",_specifiers);

		for(id spec in [[_disabledIdentifiers reverseObjectEnumerator] allObjects]) {
			NSString *classString = [@"LL" stringByAppendingString:[[[spec componentsSeparatedByString:@" "] objectAtIndex:0] stringByAppendingString:@"Controller"]];
			PSSpecifier* firstSpecifier = [PSSpecifier preferenceSpecifierNamed:spec target:self set:nil get:nil detail:NSClassFromString(classString) cell:[PSTableCell cellTypeFromString:@"PSLinkCell"] edit:1];
			[_specifiers insertObject:firstSpecifier atIndex:6+[_enabledIdentifiers count]];
		}

		NSLog(@"settings = %@",settings);

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable:) name:@"reloadTable" object:nil];

		
	}

	NSLog(@"_specifiers = %@",_specifiers);
	
	return _specifiers;

}

- (void)dealloc {
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

static CFStringRef aCFString = CFStringCreateWithCString(NULL, "org.thebigboss.searchlight/saved", kCFStringEncodingMacRoman);
-(void)save {
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), aCFString, NULL, NULL, YES);
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	tableView.allowsSelectionDuringEditing = YES;	
    if(indexPath.section == 1 || indexPath.section == 2) return YES;
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
	NSLog(@"proposed: %f",(float)proposedDestinationIndexPath.section);
	if (proposedDestinationIndexPath.section < 1 || proposedDestinationIndexPath.section > 2) {
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
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
	NSString *title = @"";

	if(fromIndex.section == 1) { // Enabled 
		title = [_enabledIdentifiers objectAtIndex:fromIndex.row];
		[_enabledIdentifiers removeObjectAtIndex:fromIndex.row];
		[settings setValue:_enabledIdentifiers forKey:@"enabledSections"];
	} else {
		title = [_disabledIdentifiers objectAtIndex:fromIndex.row];
		[_disabledIdentifiers removeObjectAtIndex:fromIndex.row];
		[settings setValue:_disabledIdentifiers forKey:@"disabledSections"];
	}

	if(toIndex.section == 1) { // Enabled 
		[_enabledIdentifiers insertObject:title atIndex:toIndex.row];
		[settings setValue:_enabledIdentifiers forKey:@"enabledSections"];
	} else { // disabled
		[_disabledIdentifiers insertObject:title atIndex:toIndex.row];
		[settings setValue:_disabledIdentifiers forKey:@"disabledSections"];
	}

	[settings writeToFile:plistPath atomically:YES];

	//[title release];
	tableView.allowsSelectionDuringEditing = YES; 
}

- (PSTableCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	PSTableCell *cell = (PSTableCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
	NSLog(@"setting cell");
	cell.editingAccessoryView = cell.accessoryView;
	if(indexPath.section <= 4 || (indexPath.section == 5 && indexPath.row == 0))
		cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	if(indexPath.section == 1) {
		// Or use +[UIImage imageNamed:(NSString *)name inBundle:(NSBundle *)bundle
		NSString *imageName = [@"/Library/Application Support/Searchlight/assets/" stringByAppendingString:[_enabledIdentifiers objectAtIndex:indexPath.row]];
		imageName = [imageName stringByAppendingString:@".png"];
		UIImage *icon =  [UIImage imageWithContentsOfFile:imageName];
		NSLog(@"inserting image %@ for %@",imageName,icon);
		cell.imageView.hidden = NO;
		cell.imageView.image = icon;
	} else if(indexPath.section == 2) {
		// Or use +[UIImage imageNamed:(NSString *)name inBundle:(NSBundle *)bundle
		NSString *imageName = [@"/Library/Application Support/Searchlight/assets/" stringByAppendingString:[_disabledIdentifiers objectAtIndex:indexPath.row]];
		imageName = [imageName stringByAppendingString:@".png"];
		UIImage *icon =  [UIImage imageWithContentsOfFile:imageName];
		NSLog(@"inserting image %@ for %@",imageName,icon);
		cell.imageView.hidden = NO;
		cell.imageView.image = icon;
	}
	tableView.allowsSelectionDuringEditing = YES; 
	tableView.editing = YES;
	[super setEditingButtonHidden:NO animated:NO];
	[super setEditButtonEnabled:NO];

	if(indexPath.section == 0 && indexPath.row == 0 && !NSClassFromString(@"LASettingsViewController")) {
		//cell.userInteractionEnabled = NO;
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.editingAccessoryType = UITableViewCellAccessoryNone;
		cell.textLabel.textColor = [UIColor grayColor];
		cell.detailTextLabel.text = @"n/a";
	}

	return cell;
}
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	NSLog(@"getting number of sections");
	return 5;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSLog(@"getting number of rows");
	if(section == 0) return 3; // system search
	if(section == 1) return [_enabledIdentifiers count]; //count of enabled
	if(section == 2) return [_disabledIdentifiers count]; //count of disabled
	if(section == 3) return 1; // save
	if(section == 4) return 3; // about
	if(section == 5) return 1;  // advanced
	return 0; 
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	tableView.allowsSelectionDuringEditing = YES; 

	if(indexPath.section == 1) { // enabled 
		NSString *spec = [_enabledIdentifiers objectAtIndex:indexPath.row];
		NSString *classString = [@"LL" stringByAppendingString:[[[spec componentsSeparatedByString:@" "] objectAtIndex:0] stringByAppendingString:@"Controller"]];
		LLFavoritesAddController *_controller = [[NSClassFromString(classString) alloc] init];
		_controller.sortedDisplayIdentifiers = [self sortedDisplayIdentifiers];
		_controller.applicationList = [self applicationList];
		if (_controller) {
			[self.navigationController pushViewController:_controller animated:YES];
		}
	} else if(indexPath.section == 2) { // disabled
		NSString *spec = [_disabledIdentifiers objectAtIndex:indexPath.row];
		NSString *classString = [@"LL" stringByAppendingString:[[[spec componentsSeparatedByString:@" "] objectAtIndex:0] stringByAppendingString:@"Controller"]];
		LLFavoritesAddController *_controller = [[NSClassFromString(classString) alloc] init];
		_controller.sortedDisplayIdentifiers = [self sortedDisplayIdentifiers];
		_controller.applicationList = [self applicationList];
		if (_controller) {
			[self.navigationController pushViewController:_controller animated:YES];
		}
	} else if(indexPath.section == 0 && indexPath.row == 0 && !NSClassFromString(@"LASettingsViewController")) {
		NSLog(@"Activator not installed. Class not found! Do something here!");
		UIAlertController *alertController = [UIAlertController
                              alertControllerWithTitle:@"libactivator missing!"
                              message:@"The libactivator package is missing. Please install it if you would like to assign an Activator event to Searchlight."
                              preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *cancelAction = [UIAlertAction 
            actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                      style:UIAlertActionStyleCancel
                    handler:^(UIAlertAction *action)
                    {
                      NSLog(@"Cancel action");

                    }];

		UIAlertAction *okAction = [UIAlertAction 
            actionWithTitle:NSLocalizedString(@"Get", @"OK action")
                      style:UIAlertActionStyleDefault
                    handler:^(UIAlertAction *action)
                    {
                      NSLog(@"OK action");
                      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/libactivator"]];
                      //[self deselectRowAtIndexPath:indexPath animated:YES];
                    }];
		[self.table deselectRowAtIndexPath:indexPath animated:YES];
		[alertController addAction:cancelAction];
		[alertController addAction:okAction];
		//http://useyourloaf.com/blog/2014/09/05/uialertcontroller-changes-in-ios-8.html
		[self presentViewController:alertController animated:YES completion:nil];
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
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.coinbase.com/checkouts/07509aa1e4bd4d82c7f0b82138b51a3a"]];
}

-(void)generateAppList {
	NSString *plistPath = @"/var/mobile/Library/Preferences/org.thebigboss.searchlight.applist.plist";
	NSMutableDictionary *appsettings = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];

	if(!appsettings) {
			appsettings = [NSMutableDictionary dictionary];
			[appsettings writeToFile:plistPath atomically:YES];
	}

	_applicationList = [ALApplicationList sharedApplicationList];

	_sortedDisplayIdentifiers =  [[[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/org.thebigboss.searchlight.applist.plist"] valueForKey:@"applications"] ?: [[_applicationList.applications allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
	    return [[_applicationList.applications objectForKey:obj1] caseInsensitiveCompare:[_applicationList.applications objectForKey:obj2]];}];
	

	[appsettings setValue:_sortedDisplayIdentifiers forKey:@"applications"];
	[appsettings writeToFile:plistPath atomically:YES];
}

-(ALApplicationList *)applicationList {
	if(!_applicationList) {
		[self generateAppList];
	}
	return _applicationList;
}

-(NSArray *)sortedDisplayIdentifiers {
	if(!_sortedDisplayIdentifiers) [self generateAppList];
	return _sortedDisplayIdentifiers;
}

@end

// vim:ft=objc

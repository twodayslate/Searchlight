
#import "Preferences.h"

static NSString *plistPath = @"/var/mobile/Library/Preferences/org.thebigboss.listlauncher7.plist";
static NSString *name = @"Favorites";
static CFStringRef aCFString = CFStringCreateWithCString(NULL, "org.thebigboss.listlauncher7/reloadTable", kCFStringEncodingMacRoman);

@implementation LLFavoritesController
- (id)specifiers {
	NSLog(@"inside specifiers");
	if(_specifiers == nil) {

		NSMutableDictionary *settings = [[[NSMutableDictionary alloc] initWithContentsOfFile:plistPath] retain];
		[settings writeToFile:plistPath atomically:YES];

		_specifiers = [[self loadSpecifiersFromPlistName:@"LLFavoritesPref" target:self] retain];

		PSSpecifier* firstSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Enabled" target:self set:@selector(setValue:forSpecifier:) get:@selector(getValueForSpecifier:) detail:nil cell:[PSTableCell cellTypeFromString:@"PSSwitchCell"] edit:1];
		[_specifiers insertObject:firstSpecifier atIndex:0];
		//[firstSpecifier release];
		
		
		_favoriteList = (NSMutableArray *) [settings valueForKey:@"favorites"];
		
		if(!_favoriteList) {
			_favoriteList = [[NSMutableArray alloc] init];
			
			[settings setValue:_favoriteList forKey:@"favorites"];
			[settings writeToFile:plistPath atomically:YES];
		}

		_favoriteList =  [[_favoriteList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
	    return 	[[_favoriteList objectAtIndex:[_favoriteList indexOfObject:obj1]] objectAtIndex:1] > [[_favoriteList objectAtIndex:[_favoriteList indexOfObject:obj2]] objectAtIndex:1]	;}] mutableCopy];
	

		
		//NSLog(@"favoriteList = %@",favoriteList);
		int count = 0;
		for(int i = 0; i < [_favoriteList count]; i++) {
			id spec = [_favoriteList objectAtIndex:i];
			int index = [_favoriteList indexOfObject:spec];
			[_favoriteList removeObjectAtIndex:index];
			[_favoriteList insertObject:@[ [spec objectAtIndex:0],[[NSNumber alloc] initWithInt:count] ] atIndex:index];
			PSSpecifier* appSpecifier = [PSSpecifier preferenceSpecifierNamed:[_applicationList valueForKey:@"displayName" forDisplayIdentifier:[spec objectAtIndex:0]] target:self set:nil get:nil detail:nil cell:[PSTableCell cellTypeFromString:@"PSTitleCell"] edit:1];
			[appSpecifier setIdentifier:[spec objectAtIndex:0]];
			[_specifiers insertObject:appSpecifier atIndex:[_specifiers count]];
			//[appSpecifier release];
			count++;
		}


		if(!self.navigationItem.rightBarButtonItem) {
			UIBarButtonItem *addButton = [[UIBarButtonItem alloc]      
				initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
	    		target:self action:@selector(addButtonPressed:)];
			self.navigationItem.rightBarButtonItem = addButton;
			[addButton release];
		}

		//[settings release];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFavoritesTable:) name:@"reloadFavoritesTable" object:nil];
	}

	

	NSLog(@"done with specifiers");

	return _specifiers;
}
- (void)dealloc {	
	[_favoriteList release];
	[_applicationList release];
	[_sortedDisplayIdentifiers release];
	[super dealloc];
}

-(void)addButtonPressed:(id)arg1 {
	LLFavoritesAddController *_controller = [[LLFavoritesAddController alloc] init];
	_controller.sortedDisplayIdentifiers = _sortedDisplayIdentifiers;
	_controller.applicationList = _applicationList;
		if (_controller) {
			[self.navigationController pushViewController:_controller animated:YES];
		}
	//[_controller release];
}

- (id)getValueForSpecifier:(PSSpecifier*)specifier {
	@autoreleasepool {
		NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
		if([(NSMutableArray *) [settings valueForKey:@"enabledSections"] containsObject:name]) {
			return @YES;
		} 

		return @NO;
	}
}

- (void)setValue:(id)value forSpecifier:(PSSpecifier *)specifier {
	NSLog(@"value = %@",value);
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
	NSMutableArray *enabledIdentifiers = (NSMutableArray *) [settings valueForKey:@"enabledSections"];
	NSMutableArray *disabledIdentifiers = (NSMutableArray *) [settings valueForKey:@"disabledSections"];

	if([value boolValue]) { //set to enable
		[enabledIdentifiers insertObject:name atIndex:0];
		[disabledIdentifiers removeObject:name];
	} else {
		[disabledIdentifiers insertObject:name atIndex:0];
		[enabledIdentifiers removeObject:name];
	}
	[settings writeToFile:plistPath atomically:YES];
	//[enabledIdentifiers release];
	//[disabledIdentifiers release];
	//[settings release];
	NSLog(@"settings = %@",settings);

	[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTable" object:self userInfo:nil];

}

-(void)reloadFavoritesTable:(NSNotification *)notification {
	NSLog(@"Reloading Favorites table");
	//[self reload];
	if(self) {
		[self flushSettings];
		[self reloadSpecifiers];
		//[[self table] reloadData];
	}
	//[[self table] reloadData];
}

-(void)flushSettings {
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
	_favoriteList = (NSMutableArray *) [settings valueForKey:@"favorites"];
	//[settings release];
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	tableView.allowsSelectionDuringEditing = YES;	
    if(indexPath.section == 2) return YES;
    return NO;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}

- (BOOL) tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath { 
	return NO;
}
-(id)_editButtonBarItem { 
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc]      
				initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
	    		target:self action:@selector(addButtonPressed:)];
			self.navigationItem.rightBarButtonItem = addButton;
	return [addButton autorelease];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	if (proposedDestinationIndexPath.section != 2) {
	    NSInteger row = 0;
	    if (sourceIndexPath.section < proposedDestinationIndexPath.section) {
	      row = [tableView numberOfRowsInSection:sourceIndexPath.section] - 1;
	    }
	    return [NSIndexPath indexPathForRow:row inSection:sourceIndexPath.section];     
	  }

  return proposedDestinationIndexPath;
}

-(void)tableView: (UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndex toIndexPath:(NSIndexPath *)toIndex {
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
	[settings writeToFile:plistPath atomically:YES];
	NSLog(@"inside moveRow message");
	NSString *name = [_favoriteList objectAtIndex:fromIndex.row];
	[_favoriteList removeObjectAtIndex:fromIndex.row];
	[_favoriteList insertObject:name atIndex:toIndex.row];

	int count = 0;
		for(int i = 0; i < [_favoriteList count]; i++) {
			id spec = [[_favoriteList objectAtIndex:i] retain];
			int index = [_favoriteList indexOfObject:spec];
			[_favoriteList removeObjectAtIndex:index];
			[_favoriteList insertObject:@[ [spec objectAtIndex:0],[[NSNumber alloc] initWithInt:count] ] atIndex:index];
			count++;
		}

	[settings setValue:_favoriteList forKey:@"favorites"];
	NSLog(@"After changes in settings = %@",settings);
	[settings writeToFile:plistPath atomically:YES];
	//[name release];
	tableView.allowsSelectionDuringEditing = YES; 
	tableView.editing = YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:@"CellIdentifier@"];
    }
	NSLog(@"indexPath = (%d,%d)",(int)indexPath.row,(int)indexPath.section);
	if(indexPath.section == 2) {
		NSLog(@"accessoryType = %d",(int)cell.accessoryType);
		UIImage *icon = [_applicationList iconOfSize:59 forDisplayIdentifier:[[_favoriteList objectAtIndex:indexPath.row] objectAtIndex:0]];
		cell.imageView.image = icon;
	} else {
		cell.editingAccessoryView = cell.accessoryView;
	}
	tableView.allowsSelectionDuringEditing = YES; 
	tableView.editing = YES;

	return cell;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section == 0) return  1;
	if(section == 1) return 1;
	if(section == 2) {
		NSLog(@"favoriteList = %@",_favoriteList);
		return [_favoriteList count]; //count
	}
	return 0; 
}

@end


@implementation LLFavoritesAddController
 - (id)specifiers {
	if(_specifiers == nil) {
		//_specifiers = [[self loadSpecifiersFromPlistName:@"LLFavoritesPref" target:self] retain];
		_specifiers = [@[] mutableCopy];

		// ALApplicationList *apps = [ALApplicationList sharedApplicationList];

		// //displayIdentifiers = [NSClassFromString(@"ListLauncherPref") sortedDisplayIdentifiers];

		// NSLog(@"displayIdentifiers = %@",displayIdentifiers);

		NSLog(@"_sortedDisplayIdentifiers = %@",_sortedDisplayIdentifiers);

		for(id spec in _sortedDisplayIdentifiers) {
			PSSpecifier* firstSpecifier = [PSSpecifier preferenceSpecifierNamed:[_applicationList valueForKey:@"displayName" forDisplayIdentifier:spec] target:self set:@selector(setValue:forSpecifier:) get:@selector(getValueForSpecifier:) detail:nil cell:[PSTableCell cellTypeFromString:@"PSSwitchCell"] edit:1];
			[firstSpecifier setIdentifier:spec];
			[_specifiers insertObject:firstSpecifier atIndex:[_specifiers count]];
		}
	}
	return _specifiers;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:@"CellIdentifier@"];
    }
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	UIImage *icon = [_applicationList iconOfSize:59 forDisplayIdentifier:[_sortedDisplayIdentifiers objectAtIndex:indexPath.row]];
	cell.imageView.image = icon;
	//[cell setImage:icon];
	//[cell setHasImage:YES];
	return cell;
}

- (id)getValueForSpecifier:(PSSpecifier*)specifier {
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
	NSLog(@"specifier = %@",specifier);
	NSLog(@"specifier id = %@",[specifier identifier]);
	NSMutableArray *favoriteList = (NSMutableArray *) [settings valueForKey:@"favorites"];
	for(id spec in favoriteList) {
		if([[spec objectAtIndex:0] isEqual:[specifier identifier]]) return @YES;
	}
	return @NO;
}

- (void)setValue:(id)value forSpecifier:(PSSpecifier *)specifier {
	NSLog(@"value = %@",value);
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
	NSMutableArray *favoriteList = (NSMutableArray *) [settings valueForKey:@"favorites"];

	if([value boolValue]) {
		[favoriteList addObject:@[[specifier identifier],[[NSNumber alloc] initWithInt:[favoriteList count]]]];

	} else {
		for(int i = 0; i < [favoriteList count]; i++) {
			id spec = [[favoriteList objectAtIndex:i] retain];
			if([[spec objectAtIndex:0] isEqual:[specifier identifier]]) {
				[favoriteList removeObject:spec];
			}
		}
		//[favoriteList removeObject:[specifier identifier]];
	}
	[settings writeToFile:plistPath atomically:YES];

	NSLog(@"settings = %@",settings);
	[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadFavoritesTable" object:self userInfo:nil];

}
@end
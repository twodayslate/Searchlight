
#import "Preferences.h"

static NSString *plistPath = @"/var/mobile/Library/Preferences/org.thebigboss.searchlight.plist";
#define exampleTweakPreferencePath @"/var/mobile/Library/Preferences/org.thebigboss.searchlight.plist"
static NSString *name = @"Favorites";
static CFStringRef aCFString = CFStringCreateWithCString(NULL, "org.thebigboss.searchlight/reloadTable", kCFStringEncodingMacRoman);
//extern NSString* PSDeletionActionKey;

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
		
		
		_favoriteList = (NSMutableArray *) [settings valueForKey:@"myfavorites"];
		
		if(!_favoriteList) {
			_favoriteList = [[NSMutableArray alloc] init];
			
			[settings setValue:_favoriteList forKey:@"myfavorites"];
			[settings writeToFile:plistPath atomically:YES];
		}

		NSLog(@"favoriteList before sort = %@",_favoriteList);

		// _favoriteList =  [[_favoriteList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
	 //    return 	[[obj1 objectAtIndex:1] integerValue] > [[obj2 objectAtIndex:1] integerValue]	;}] mutableCopy];
	

		
		NSLog(@"favoriteList afer sort = %@",_favoriteList);

		int count = 0;
		for(int i = 0; i < [_favoriteList count]; i++) {
			id spec = [_favoriteList objectAtIndex:i];
			// int index = [_favoriteList indexOfObject:spec];
			// [_favoriteList removeObjectAtIndex:index];
			// [_favoriteList insertObject:@[ [spec objectAtIndex:0],[[NSNumber alloc] initWithInt:count] ] atIndex:index];
			PSSpecifier* appSpecifier = [PSSpecifier preferenceSpecifierNamed:[_applicationList valueForKey:@"displayName" forDisplayIdentifier:spec] target:self set:nil get:nil detail:nil cell:[PSTableCell cellTypeFromString:@"PSTitleCell"] edit:1];
			[appSpecifier setIdentifier:spec];
			//[appSpecifier setProperty:NSStringFromSelector(@selector(removedSpecifier:)) forKey:PSDeletionActionKey];

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

	
	self.title = @"Favorites";
	NSLog(@"done with specifiers");

	return _specifiers;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        NSLog(@"did delete");
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
		[settings writeToFile:plistPath atomically:YES];
		NSString *appname = [_favoriteList objectAtIndex:indexPath.row];
		NSLog(@"deleting = %@",appname);

		NSLog(@"favoriteList before: = %@",_favoriteList);

		[_favoriteList removeObjectAtIndex:indexPath.row];

		NSLog(@"favoriteList right after removal/addition = %@",_favoriteList);

		// NSMutableArray *tempFavorites = [[@[] mutableCopy] retain];
		// NSLog(@"tempFAvorites = %@",tempFavorites);
		// NSLog(@"favoriteList = %@",_favoriteList);
		// _favoriteList = tempFavorites;
		// _favoriteList =  [[[_favoriteList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		//     return 	[[_favoriteList objectAtIndex:[_favoriteList indexOfObject:obj1]] objectAtIndex:1] > [[_favoriteList objectAtIndex:[_favoriteList indexOfObject:obj2]] objectAtIndex:1]	;}] mutableCopy] retain];

		[settings setValue:_favoriteList forKey:@"myfavorites"];
		NSLog(@"After changes in settings = %@",settings);
		[settings writeToFile:plistPath atomically:YES];
		//[name release];
		tableView.allowsSelectionDuringEditing = YES; 
		tableView.editing = YES;
        [self reloadFavoritesTable:nil];
    }    
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
	_favoriteList = (NSMutableArray *) [settings valueForKey:@"myfavorites"];
	//[settings release];
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	tableView.allowsSelectionDuringEditing = YES;	
    if(indexPath.section == 2) return YES;
    return NO;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 2)
		return UITableViewCellEditingStyleDelete;
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
	NSString *appname = [_favoriteList objectAtIndex:fromIndex.row];
	NSLog(@"moving = %@",appname);

	NSLog(@"favoriteList before: = %@",_favoriteList);

	[_favoriteList removeObjectAtIndex:fromIndex.row];
	[_favoriteList insertObject:appname atIndex:toIndex.row];

	NSLog(@"favoriteList right after removal/addition = %@",_favoriteList);

	// NSMutableArray *tempFavorites = [[@[] mutableCopy] retain];
	// NSLog(@"tempFAvorites = %@",tempFavorites);
	// NSLog(@"favoriteList = %@",_favoriteList);
	// _favoriteList = tempFavorites;
	// _favoriteList =  [[[_favoriteList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
	//     return 	[[_favoriteList objectAtIndex:[_favoriteList indexOfObject:obj1]] objectAtIndex:1] > [[_favoriteList objectAtIndex:[_favoriteList indexOfObject:obj2]] objectAtIndex:1]	;}] mutableCopy] retain];

	[settings setValue:_favoriteList forKey:@"myfavorites"];
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
		UIImage *icon = [_applicationList iconOfSize:59 forDisplayIdentifier:[_favoriteList objectAtIndex:indexPath.row]];
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

-(id) readPreferenceValue:(PSSpecifier*)specifier {
	NSDictionary *exampleTweakSettings = [NSDictionary dictionaryWithContentsOfFile:exampleTweakPreferencePath];
	if (!exampleTweakSettings[specifier.properties[@"key"]]) {
		return specifier.properties[@"default"];
	}
	return exampleTweakSettings[specifier.properties[@"key"]];
}
 
-(void) setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
	[defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:exampleTweakPreferencePath]];
	[defaults setObject:value forKey:specifier.properties[@"key"]];
	[defaults writeToFile:exampleTweakPreferencePath atomically:YES];
	NSLog(@"written to file");
	//NSDictionary *exampleTweakSettings = [NSDictionary dictionaryWithContentsOfFile:exampleTweakPreferencePath];
	CFStringRef mikotoPost = (CFStringRef)specifier.properties[@"PostNotification"];
	NSLog(@"created CFStringRef");
	if(mikotoPost)
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), mikotoPost, NULL, NULL, YES);
	NSLog(@"posted notification");
}

@end











@implementation LLFavoritesAddController

NSMutableDictionary *defaults = nil;
NSMutableArray *favoriteList = nil;

 - (id)specifiers {
	if(_specifiers == nil) {
		//_specifiers = [[self loadSpecifiersFromPlistName:@"LLFavoritesPref" target:self] retain];
		_specifiers = [@[] mutableCopy];

		// ALApplicationList *apps = [ALApplicationList sharedApplicationList];

		// //displayIdentifiers = [NSClassFromString(@"ListLauncherPref") sortedDisplayIdentifiers];

		// NSLog(@"displayIdentifiers = %@",displayIdentifiers);

		NSLog(@"_sortedDisplayIdentifiers = %@",_sortedDisplayIdentifiers);

		for(id spec in _sortedDisplayIdentifiers) {
			PSSpecifier* firstSpecifier = [PSSpecifier preferenceSpecifierNamed:[_applicationList valueForKey:@"displayName" forDisplayIdentifier:spec] target:self set:@selector(setPreferenceValue:specifier:) get:@selector(getValueForSpecifier:) detail:nil cell:[PSTableCell cellTypeFromString:@"PSSwitchCell"] edit:1];
			[firstSpecifier setIdentifier:spec];
			[_specifiers insertObject:firstSpecifier atIndex:[_specifiers count]];
		}
	}
	return _specifiers;
}

-(id) readPreferenceValue:(PSSpecifier*)specifier {
	NSDictionary *exampleTweakSettings = [NSDictionary dictionaryWithContentsOfFile:exampleTweakPreferencePath];
	if (!exampleTweakSettings[specifier.properties[@"key"]]) {
		return specifier.properties[@"default"];
	}
	return exampleTweakSettings[specifier.properties[@"key"]];
}
 
-(void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSLog(@"setPreferenceValue specifier = %@",specifier);
	NSLog(@"specifier id = %@",[specifier identifier]);
	NSLog(@"value = %@",value);

	if(!defaults) {
		defaults = [[NSMutableDictionary dictionary] retain];
		[defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:exampleTweakPreferencePath]];
		//[defaults setObject:value forKey:specifier.properties[@"key"]];
	}

	if(!favoriteList) {
		favoriteList = [[NSMutableArray arrayWithArray:[defaults valueForKey:@"myfavorites"]] retain];
		if(!favoriteList) {
			favoriteList = [[[NSMutableArray alloc] init] retain];
		}
	}
	

	NSLog(@"about to set");
	if([value boolValue]) {
		NSLog(@"inserting value %@",[specifier identifier]);
		//if(![favoriteList containsObject:[specifier identifier]])
		[favoriteList addObject:[specifier identifier]];
	} else {
		NSLog(@"removing value %@",[specifier identifier]);
		[favoriteList removeObject:[specifier identifier]];
		//[favoriteList removeObject:[specifier identifier]];
	}

	NSLog(@"setting value");

	[defaults setValue:favoriteList forKey:@"myfavorites"];

	NSLog(@"writing");

	[defaults writeToFile:exampleTweakPreferencePath atomically:YES];
	NSLog(@"written to file");
	//NSDictionary *exampleTweakSettings = [NSDictionary dictionaryWithContentsOfFile:exampleTweakPreferencePath];
	CFStringRef mikotoPost = (CFStringRef)specifier.properties[@"PostNotification"];
	NSLog(@"created CFStringRef");
	if(mikotoPost)
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), mikotoPost, NULL, NULL, YES);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadFavoritesTable" object:self userInfo:nil];

	NSLog(@"posted notification");
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
	NSMutableArray *favoriteList = (NSMutableArray *) [settings valueForKey:@"myfavorites"];
	for(id spec in favoriteList) {
		if([spec isEqual:[specifier identifier]]) return @YES;
	}
	return @NO;
}

// - (void)setValue:(id)value forSpecifier:(PSSpecifier *)specifier {
// 	NSLog(@"value = %@",value);
// 	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
// 	NSMutableArray *favoriteList = (NSMutableArray *) [settings valueForKey:@"myfavorites"];

// 	if([value boolValue]) {
// 		if(![favoriteList containsObject:[specifier identifier]])
// 			[favoriteList addObject:@[[specifier identifier],[[NSNumber alloc] initWithInt:[favoriteList count]]]];

// 	} else {
// 		for(int i = 0; i < [favoriteList count]; i++) {
// 			id spec = [[favoriteList objectAtIndex:i] retain];
// 			if([[spec objectAtIndex:0] isEqual:[specifier identifier]]) {
// 				[favoriteList removeObject:spec];
// 			}
// 		}
// 		//[favoriteList removeObject:[specifier identifier]];
// 	}
// 	[settings writeToFile:plistPath atomically:YES];

// 	NSLog(@"settings = %@",settings);
// 	[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadFavoritesTable" object:self userInfo:nil];
// }
@end

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
		[firstSpecifier release];
		
		
		favoriteList = [(NSMutableArray *) [settings valueForKey:@"favorites"] retain];
		
		if(!favoriteList) {
			favoriteList = [[[NSMutableArray alloc] init] retain];
			
			[settings setValue:favoriteList forKey:@"favorites"];
			[settings writeToFile:plistPath atomically:YES];
		}

		favoriteList =  [[[favoriteList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
	    return 	[[favoriteList objectAtIndex:[favoriteList indexOfObject:obj1]] objectAtIndex:1] > [[favoriteList objectAtIndex:[favoriteList indexOfObject:obj2]] objectAtIndex:1]	;}] mutableCopy] retain];
	

		
		NSLog(@"favoriteList = %@",favoriteList);
		int count = 0;
		for(int i = 0; i < [favoriteList count]; i++) {
			id spec = [favoriteList objectAtIndex:i];
			int index = [favoriteList indexOfObject:spec];
			[favoriteList removeObjectAtIndex:index];
			[favoriteList insertObject:@[ [spec objectAtIndex:0],[[NSNumber alloc] initWithInt:count] ] atIndex:index];
			PSSpecifier* appSpecifier = [PSSpecifier preferenceSpecifierNamed:[_applicationList valueForKey:@"displayName" forDisplayIdentifier:[spec objectAtIndex:0]] target:self set:nil get:nil detail:nil cell:[PSTableCell cellTypeFromString:@"PSTitleCell"] edit:1];
			[appSpecifier setIdentifier:[spec objectAtIndex:0]];
			[_specifiers insertObject:appSpecifier atIndex:[_specifiers count]];
			count++;
		}


		if(!self.navigationItem.rightBarButtonItem) {
			UIBarButtonItem *addButton = [[UIBarButtonItem alloc]      
				initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
	    		target:self action:@selector(addButtonPressed:)];
			self.navigationItem.rightBarButtonItem = addButton;
			[addButton release];
		}

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFavoritesTable:) name:@"reloadFavoritesTable" object:nil];
	}

	return _specifiers;
}

-(void)addButtonPressed:(id)arg1 {
	LLFavoritesAddController *_controller = [[LLFavoritesAddController alloc] init];
	_controller.sortedDisplayIdentifiers = _sortedDisplayIdentifiers;
	_controller.applicationList = _applicationList;
		if (_controller) {
			[self.navigationController pushViewController:_controller animated:YES];
		}
}

- (id)getValueForSpecifier:(PSSpecifier*)specifier {
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
	if([(NSMutableArray *) [settings valueForKey:@"enabledSections"] containsObject:name]) {
		return @YES;
	} 

	return @NO;
}

- (void)setValue:(id)value forSpecifier:(PSSpecifier *)specifier {
	NSLog(@"value = %@",value);
	NSMutableDictionary *settings = [[[NSMutableDictionary alloc] initWithContentsOfFile:plistPath] retain];
	NSMutableArray *enabledIdentifiers = [(NSMutableArray *) [settings valueForKey:@"enabledSections"] retain];
	NSMutableArray *disabledIdentifiers = [(NSMutableArray *) [settings valueForKey:@"disabledSections"] retain];

	if([value boolValue]) { //set to enable
		[enabledIdentifiers insertObject:name atIndex:0];
		[disabledIdentifiers removeObject:name];
	} else {
		[disabledIdentifiers insertObject:name atIndex:0];
		[enabledIdentifiers removeObject:name];
	}
	[settings writeToFile:plistPath atomically:YES];
	[enabledIdentifiers release];
	[disabledIdentifiers release];
	NSLog(@"settings = %@",settings);

	[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTable" object:self userInfo:nil];

}

-(void)reloadFavoritesTable:(NSNotification *)notification {
	NSLog(@"Reloading Favorites table");
	//[self reload];
	if(self) {
		[self flushSettings];
		_specifiers = nil;
		[self specifiers];
		//[[self table] reloadData];
	}
	//[[self table] reloadData];
}

-(void)flushSettings {
	NSMutableDictionary *settings = [[[NSMutableDictionary alloc] initWithContentsOfFile:plistPath] retain];
	favoriteList = [(NSMutableArray *) [settings valueForKey:@"favorites"] retain];
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
	return addButton;
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
	NSMutableDictionary *settings = [[[NSMutableDictionary alloc] initWithContentsOfFile:plistPath] retain];
	[settings writeToFile:plistPath atomically:YES];
	NSLog(@"inside moveRow message");
	NSString *name = [[favoriteList objectAtIndex:fromIndex.row] retain];
	[favoriteList removeObjectAtIndex:fromIndex.row];
	[favoriteList insertObject:name atIndex:toIndex.row];

	int count = 0;
		for(int i = 0; i < [favoriteList count]; i++) {
			id spec = [[favoriteList objectAtIndex:i] retain];
			int index = [favoriteList indexOfObject:spec];
			[favoriteList removeObjectAtIndex:index];
			[favoriteList insertObject:@[ [spec objectAtIndex:0],[[NSNumber alloc] initWithInt:count] ] atIndex:index];
			count++;
		}

	[settings setValue:favoriteList forKey:@"favorites"];
	NSLog(@"After changes in settings = %@",settings);
	[settings writeToFile:plistPath atomically:YES];
	[name release];
	tableView.allowsSelectionDuringEditing = YES; 
	tableView.editing = YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	NSLog(@"indexPath = (%d,%d)",(int)indexPath.row,(int)indexPath.section);
	if(indexPath.section == 2) {
		NSLog(@"accessoryType = %d",(int)cell.accessoryType);
		UIImage *icon = [_applicationList iconOfSize:59 forDisplayIdentifier:[[favoriteList objectAtIndex:indexPath.row] objectAtIndex:0]];
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
		NSLog(@"favoriteList = %@",favoriteList);
		return [favoriteList count]; //count
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
	NSMutableArray *favoriteList = [(NSMutableArray *) [settings valueForKey:@"favorites"] retain];
	for(id spec in favoriteList) {
		if([[spec objectAtIndex:0] isEqual:[specifier identifier]]) return @YES;
	}
	[favoriteList release];
	return @NO;
}

- (void)setValue:(id)value forSpecifier:(PSSpecifier *)specifier {
	NSLog(@"value = %@",value);
	NSMutableDictionary *settings = [[[NSMutableDictionary alloc] initWithContentsOfFile:plistPath] retain];
	NSMutableArray *favoriteList = [(NSMutableArray *) [settings valueForKey:@"favorites"] retain];

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
	[favoriteList release];

	[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadFavoritesTable" object:self userInfo:nil];

}
@end


@interface SRSwitchTableCell : PSSwitchTableCell //our class
@end
 
@implementation SRSwitchTableCell
 
-(id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 { //init method
	self = [super initWithStyle:arg1 reuseIdentifier:arg2 specifier:arg3]; //call the super init method
	if (self) {
		[((UISwitch *)[self control]) setOn:NO animated:NO];
	}
	return self;
}
@end
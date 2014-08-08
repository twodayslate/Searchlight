
#import "Preferences.h"

static NSString *plistPath = @"/var/mobile/Library/Preferences/org.thebigboss.listlauncher7.plist";
static NSString *name = @"Application List";

@implementation LLApplicationController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"LLApplicationPref" target:self] retain];
		NSMutableDictionary *settings = [[[NSMutableDictionary alloc] initWithContentsOfFile:plistPath] retain];
		NSMutableArray *disabledList = [(NSMutableArray *) [settings valueForKey:@"disabled"] retain];

		
		if(!disabledList) {
			disabledList = [[[NSMutableArray alloc] init] retain];
			
			[settings setValue:disabledList forKey:@"disabled"];
			[settings writeToFile:plistPath atomically:YES];
		}

		PSSpecifier* firstSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Enabled" target:self set:@selector(setValue:forSpecifier:) get:@selector(getValueForSpecifier:) detail:nil cell:[PSTableCell cellTypeFromString:@"PSSwitchCell"] edit:1];

		[_specifiers insertObject:firstSpecifier atIndex:0];
	

		for(id spec in _sortedDisplayIdentifiers) {
			PSSpecifier* firstSpecifier = [PSSpecifier preferenceSpecifierNamed:[_applicationList valueForKey:@"displayName" forDisplayIdentifier:spec] target:self set:@selector(setValueApp:forSpecifierApp:) get:@selector(getValueForSpecifierApp:) detail:nil cell:[PSTableCell cellTypeFromString:@"PSSwitchCell"] edit:1];
			[firstSpecifier setIdentifier:spec];
			[_specifiers insertObject:firstSpecifier atIndex:[_specifiers count]];
		}

		[firstSpecifier release];
	}
	return _specifiers;
}

- (id)getValueForSpecifier:(PSSpecifier*)specifier {
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
	if([(NSMutableArray *) [settings valueForKey:@"enabledSections"] containsObject:@"Application List"]) {
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


- (id)getValueForSpecifierApp:(PSSpecifier*)specifier {
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
	NSLog(@"specifier = %@",specifier);
	NSLog(@"specifier id = %@",[specifier identifier]);

	if([(NSMutableArray *) [settings valueForKey:@"disabled"] containsObject:[specifier identifier]]) {
		return @YES;
	} 

	return @NO;
}

- (void)setValueApp:(id)value forSpecifierApp:(PSSpecifier *)specifier {
	NSLog(@"value = %@",value);
	NSMutableDictionary *settings = [[[NSMutableDictionary alloc] initWithContentsOfFile:plistPath] retain];
	NSMutableArray *favoriteList = [(NSMutableArray *) [settings valueForKey:@"disabled"] retain];

	if([value boolValue]) {
		[favoriteList addObject:[specifier identifier]];

	} else {
		[favoriteList removeObject:[specifier identifier]];
	}
	[settings writeToFile:plistPath atomically:YES];

	NSLog(@"settings = %@",settings);
	[favoriteList release];


}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

	NSLog(@"accessoryType = %d",(int)cell.accessoryType);
	if(indexPath.section == 2) {
		UIImage *icon = [_applicationList iconOfSize:59 forDisplayIdentifier:[_sortedDisplayIdentifiers objectAtIndex:indexPath.row]];
		cell.imageView.image = icon;
	}
	return cell;
}

@end
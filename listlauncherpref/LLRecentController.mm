
#import "Preferences.h"

static NSString *plistPath = @"/var/mobile/Library/Preferences/org.thebigboss.listlauncher7.plist";
static NSString *name = @"Recent";

@implementation LLRecentController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"LLRecentPref" target:self] retain];

		PSSpecifier* firstSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Enabled" target:self set:@selector(setValue:forSpecifier:) get:@selector(getValueForSpecifier:) detail:nil cell:[PSTableCell cellTypeFromString:@"PSSwitchCell"] edit:1];

		[_specifiers insertObject:firstSpecifier atIndex:0];
		
		[firstSpecifier release];
	}
	return _specifiers;
}

- (id)getValueForSpecifier:(PSSpecifier*)specifier {
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
	if([(NSMutableArray *) [settings valueForKey:@"enabledSections"] containsObject:@"Recent"]) {

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

@end

@implementation LLBaseController
@end
#import "Preferences.h"

@implementation LLAppearanceController

#define exampleTweakPreferencePath @"/var/mobile/Library/Preferences/org.thebigboss.searchlight.plist"

- (NSArray *)specifiers {
	if (!_specifiers) {
		//NSString *compatibleName = MODERN_IOS ? @"AboutPrefs" : @"AboutPrefs";
		NSString *compatibleName = @"LLAdvancedPref";
		_specifiers = [[self loadSpecifiersFromPlistName:compatibleName target:self] retain];
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

@implementation LLBehaviorController

#define exampleTweakPreferencePath @"/var/mobile/Library/Preferences/org.thebigboss.searchlight.plist"

- (NSArray *)specifiers {
	if (!_specifiers) {
		//NSString *compatibleName = MODERN_IOS ? @"AboutPrefs" : @"AboutPrefs";
		NSString *compatibleName = @"LLBehaviorPref";
		_specifiers = [[self loadSpecifiersFromPlistName:compatibleName target:self] retain];
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
#import "Preferences.h"

@implementation LLAdvancedController

- (NSArray *)specifiers {
	if (!_specifiers) {
		//NSString *compatibleName = MODERN_IOS ? @"AboutPrefs" : @"AboutPrefs";
		NSString *compatibleName = @"LLAdvancedPref";
		_specifiers = [[self loadSpecifiersFromPlistName:compatibleName target:self] retain];
	}

	return _specifiers;
}

@end
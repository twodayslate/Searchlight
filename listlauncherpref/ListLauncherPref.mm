//#import <Preferences/PSListController.h>
@interface PSViewController 
-(void)setPreferenceValue:(id)arg1 specifier:(id)arg2 ;
@end

@interface PSListController : PSViewController { 
	NSArray* _specifiers; 
}
-(id)loadSpecifiersFromPlistName:(id)arg1 target:(id)arg2 ;
-(void)reloadSpecifier:(id)arg1 ;
-(id)specifierForID:(id)arg1 ;
@end

@interface PSSpecifier
@end

@interface ListLauncherPrefListController: PSListController {
}
@end

@implementation ListLauncherPrefListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"ListLauncherPref" target:self] retain];
	}
	return _specifiers;
}

-(void)reset_brightness {
	PSSpecifier *darknessSpecifier = [self specifierForID:@"ListLauncher_darkness"];
	[self setPreferenceValue:@(80) specifier:darknessSpecifier];
	[self reloadSpecifier:darknessSpecifier];
	darknessSpecifier = [self specifierForID:@"ListLauncher_dark"];
	[self setPreferenceValue:@(1) specifier:darknessSpecifier];
	[self reloadSpecifier:darknessSpecifier];
}

-(void)reset_alpha {
	PSSpecifier *darknessSpecifier = [self specifierForID:@"ListLauncher_alpha"];
	[self setPreferenceValue:@(100) specifier:darknessSpecifier];
	[self reloadSpecifier:darknessSpecifier];
}

-(void)respring {
	system("killall -9 SpringBoard");
}
@end

// vim:ft=objc

//#import <Preferences/PSListController.h>
//#include <Preferences/Preferences.h>
#import <CoreFoundation/CoreFoundation.h>

@interface PSViewController 
-(void)setPreferenceValue:(id)arg1 specifier:(id)arg2 ;
@end

@interface PSListController : PSViewController { 
	NSArray* _specifiers; 
}
-(void)loadView;
-(id)loadSpecifiersFromPlistName:(id)arg1 target:(id)arg2 ;
-(void)reloadSpecifier:(id)arg1 ;
-(id)specifierForID:(id)arg1 ;
@end

@interface PSSpecifier
@end

@interface PSTableCell : UITableViewCell
-(id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 ;
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


//static NSString const *nsNotificationString = @"org.thebigboss.listlauncher7/saved";
//static CFStringRef aCFString = CFStringCreateWithCString(NULL, [nsNotificationString UTF8String], NSUTF8StringEncoding);
static CFStringRef aCFString = CFStringCreateWithCString(NULL, "org.thebigboss.listlauncher7/saved", kCFStringEncodingMacRoman);

-(void)save {
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), aCFString, NULL, NULL, YES);
}
@end

@interface AboutListLauncherController : PSListController
@end

@implementation AboutListLauncherController

- (NSArray *)specifiers {
	if (!_specifiers) {
		//NSString *compatibleName = MODERN_IOS ? @"AboutPrefs" : @"AboutPrefs";
		NSString *compatibleName = @"AboutPref";
		_specifiers = [[self loadSpecifiersFromPlistName:compatibleName target:self] retain];
	}

	return _specifiers;
}

- (void)loadView {
	[super loadView];

	// if (![[CRPrefsManager sharedManager] objectForKey:@"signalStyle"]) {
	// 	PSSpecifier *signalStyleSpecifier = [self specifierForID:@"SignalStyle"];
	// 	[self setPreferenceValue:@(1) specifier:signalStyleSpecifier];
	// 	[self reloadSpecifier:signalStyleSpecifier];
	// }
}

- (void)twitter { 
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetbot:///user_profile/twodayslate"]];
	}

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitterrific:///profile?screen_name=twodayslate"]];
	}

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetings:///user?screen_name=twodayslate"]];
	}

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=twodayslate"]];
	}

	else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://mobile.twitter.com/twodayslate"]];
	}
}

-(void)website {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://zac.gorak.us"]];
}

-(void)github {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://zac.gorak.us"]];
}

-(void)paypal {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=2R9WDZCE7CPZ8"]];
}

-(void)bitcoin {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://coinbase.com/checkouts/59ead722b181591150e7de4ed6769cb4"]];
}
@end

@interface CreditCellClass : PSTableCell <UITextViewDelegate> { 
	UITextView *_plainTextView;
}
@end

@implementation CreditCellClass
- (instancetype)initWithStyle:(int)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		NSString *rawCredits = @"ListLauncher7 was created by @twodayslate. Original version (>iOS5) was created by Grant Paul (@chpwn). Developed with permission.  Uses AppList by Ryan Petrich (@rpetrich). Enjoy!";

		CGFloat padding = 5.0, savedHeight = 100.0;

		 _plainTextView = [[UITextView alloc] initWithFrame:CGRectMake(padding, 0.0, self.frame.size.width - (padding * 2.0), savedHeight)];
		self.clipsToBounds = _plainTextView.clipsToBounds = NO;
		_plainTextView.backgroundColor = [UIColor clearColor];
		_plainTextView.userInteractionEnabled = YES;
		_plainTextView.scrollEnabled = NO;
		_plainTextView.editable = NO;
		 _plainTextView.delegate = self;
		 
	
		NSMutableAttributedString *clickable = [[[NSMutableAttributedString alloc] initWithString:rawCredits attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:[UIFont smallSystemFontSize]]}] autorelease];

			[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"http://zac.gorak.us/"]} range:[clickable.string rangeOfString:@"@twodayslate"]];
			[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"http://chpwn.com/"]} range:[clickable.string rangeOfString:@"Grant Paul (@chpwn)"]];
			[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"http://rpetri.ch/"]} range:[clickable.string rangeOfString:@"Ryan Petrich (@rpetrich)"]];
			_plainTextView.linkTextAttributes = @{ NSForegroundColorAttributeName : [UIColor colorWithRed:68/255.0 green:132/255.0 blue:231/255.0 alpha:1.0] };

		_plainTextView.dataDetectorTypes = UIDataDetectorTypeLink;
		_plainTextView.attributedText = clickable;
		[_plainTextView setFont:[UIFont systemFontOfSize:14]];
		[self addSubview:_plainTextView];
	}

	return self;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
	return YES;
}

- (void)dealloc {
	_plainTextView = nil;
	[_plainTextView release];

	[super dealloc];
}
@end
// vim:ft=objc

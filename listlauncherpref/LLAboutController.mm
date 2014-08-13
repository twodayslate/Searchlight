#import "Preferences.h"

@implementation LLTweakListController
- (id)specifiers {
	if(!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"LLTweakListPref" target:self] retain];
	}
	return _specifiers;
}

-(void)anyspot {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/org.thebigboss.anyspot"]];
}

-(void)more {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://apt.thebigboss.org/packagesfordev.php?name=ListLauncher7"]];
}

-(void)searchloader {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/am.theiostre.searchloader"]];
}

-(void)searchamplius {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/org.thebigboss.searchamplius"]];
}

-(void)spotdefine {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.tyhoff.spotdefine"]];
}

-(void)filmsearch {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/me.kirbyk.filmsearch"]];
}

-(void)spotisearch {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/org.thebigboss.spotisearch"]];
}

-(void)omnisearch {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.myrepospace.com/profile/jwu/524319/OmniSearch"]];
}

-(void)spotcmd {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.freeyourapple.spotcmd"]];
}

-(void)spoturl {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.filippobiga.spoturl"]];
}

-(void)customspotlightaction {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.hucent.customspotlightaction"]];
}

-(void)nosearchcancel {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.dekesto.nosearchcancel"]];
}

-(void)openonsearch {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.mattcmultimedia.openonsearch"]];
}

-(void)searchplus {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.clezz.searchplus"]];
}

-(void)searchcommands {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/am.theiostre.searchcommands"]];
}

-(void)clearonopen {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.mattcmultimedia.clearonopen"]];
}
@end
















@implementation LLAboutController

- (NSArray *)specifiers {
	if (!_specifiers) {
		//NSString *compatibleName = MODERN_IOS ? @"AboutPrefs" : @"AboutPrefs";
		NSString *compatibleName = @"LLAboutPref";
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














@implementation CreditCellClass
// - (id)initWithSpecifier:(PSSpecifier *)specifier{
//  	return [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell" specifier:specifier];
// }

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


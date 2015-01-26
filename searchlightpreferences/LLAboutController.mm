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

-(void)browserswipe {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/org.thebigboss.browserswipe"]];
}

-(void)slideback {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.twodayslate.slideback"]];
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

-(void)smartsearchr {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/ca.cykey.smartsearch"]];
}

-(void)meme {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/red.dingo.meme"]];
}

-(void)spotlightgoogle {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.vasuchawla.spotlightgoogle"]];
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
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.coinbase.com/checkouts/07509aa1e4bd4d82c7f0b82138b51a3a"]];
}
@end














@implementation CreditCellClass
// - (id)initWithSpecifier:(PSSpecifier *)specifier{
//  	return [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell" specifier:specifier];
// }

- (instancetype)initWithStyle:(int)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		NSString *rawCredits = @"Searchlight, made by @twodayslate, combines the iOS7 tweaks AnySpot and ListLauncher7 into one and then makes Spotlight even better. The original version of ListLauncher (>iOS5) was created by Grant Paul (@chpwn). Developed with permission.  Uses AppList by Ryan Petrich (@rpetrich). Preference icons from Icons8.com. Tweak icon by Brian Overly. Settings thanks to @DHowett's preferenceloader. Enjoy!";

		CGFloat padding = 5.0, savedHeight = 120.0;

		 _plainTextView = [[UITextView alloc] initWithFrame:CGRectMake(padding, 0.0, self.frame.size.width, savedHeight - padding)];
		self.clipsToBounds = _plainTextView.clipsToBounds = YES;
		_plainTextView.backgroundColor = [UIColor clearColor];
		_plainTextView.userInteractionEnabled = YES;
		_plainTextView.scrollEnabled = YES;
		_plainTextView.editable = NO;
		 _plainTextView.delegate = self;
		 
	
		NSMutableAttributedString *clickable = [[[NSMutableAttributedString alloc] initWithString:rawCredits attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:[UIFont smallSystemFontSize]]}] autorelease];

			[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"http://zac.gorak.us/"]} range:[clickable.string rangeOfString:@"@twodayslate"]];
			[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"http://chpwn.com/"]} range:[clickable.string rangeOfString:@"Grant Paul (@chpwn)"]];
			[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"http://rpetri.ch/"]} range:[clickable.string rangeOfString:@"Ryan Petrich (@rpetrich)"]];
			[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"http://brianoverly.com/"]} range:[clickable.string rangeOfString:@"Brian Overly"]];
			[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"http://icons8.com/"]} range:[clickable.string rangeOfString:@"Icons8.com"]];
			[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"https://twitter.com/DHowett/"]} range:[clickable.string rangeOfString:@"@DHowett"]];
			[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"http://apt.thebigboss.org/onepackage.php?bundleid=org.thebigboss.anyspot"]} range:[clickable.string rangeOfString:@"AnySpot"]];
			[clickable setAttributes:@{ NSLinkAttributeName : [NSURL URLWithString:@"http://apt.thebigboss.org/onepackage.php?bundleid=org.thebigboss.listlauncher7"]} range:[clickable.string rangeOfString:@"ListLauncher7"]];
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


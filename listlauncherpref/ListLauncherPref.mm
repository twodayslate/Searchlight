//#import <Preferences/PSListController.h>
//#include <Preferences/Preferences.h>
#import <CoreFoundation/CoreFoundation.h>

@interface PSViewController : NSObject
-(void)setPreferenceValue:(id)arg1 specifier:(id)arg2 ;
@end

@interface UIPreferencesTable
@end

@interface PSListController : PSViewController { 
	NSMutableArray* _specifiers; 
	UIPreferencesTable* _table;
}
-(void)loadView;
-(id)loadSpecifiersFromPlistName:(id)arg1 target:(id)arg2 ;
-(void)reloadSpecifier:(id)arg1 ;
-(id)specifierForID:(id)arg1 ;
- (id)table;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath; 
@end

@interface PSSpecifier
+ (id)preferenceSpecifierNamed:(id)arg1 target:(id)arg2 set:(id)arg3 get:(id)arg4 detail:(id)arg5 cell:(id)arg6 edit:(int)arg7;

@end

@interface PSTableCell : UITableViewCell
-(id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 ;
+(id)cellTypeFromString:arg1;
@end

@interface PSEditableListController  : PSListController
-(void)setEditingButtonHidden:(BOOL)arg1 animated:(BOOL)arg2 ;
-(void)setEditButtonEnabled:(BOOL)arg1 ;
-(id)_editButtonBarItem;
- (id) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
@end

@interface ListLauncherPrefListController: PSEditableListController <UITableViewDelegate, UITableViewDataSource> {
}
@end

@implementation ListLauncherPrefListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"ListLauncherPref" target:self] retain];
		PSSpecifier* firstSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Recent" target:self set:nil get:nil detail:nil cell:[PSTableCell cellTypeFromString:@"PSLinkCell"] edit:1];
		PSSpecifier* secondSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Favorites" target:self set:nil get:nil detail:nil cell:[PSTableCell cellTypeFromString:@"PSLinkCell"] edit:1];
		PSSpecifier* thirdSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Application List" target:self set:nil get:nil detail:nil cell:[PSTableCell cellTypeFromString:@"PSLinkCell"] edit:1];
		[_specifiers insertObject:thirdSpecifier atIndex:1];
		[_specifiers insertObject:secondSpecifier atIndex:1];
		[_specifiers insertObject:firstSpecifier atIndex:1];
	}

	NSLog(@"_specifiers = %@",_specifiers);
	return _specifiers;

}

-(void)respring {
	system("killall -9 SpringBoard");
}

static CFStringRef aCFString = CFStringCreateWithCString(NULL, "org.thebigboss.listlauncher7/saved", kCFStringEncodingMacRoman);
-(void)save {
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), aCFString, NULL, NULL, YES);
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	tableView.allowsSelectionDuringEditing = YES;	
    if(indexPath.section == 0 || indexPath.section == 1) return YES;
    return NO;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}

- (BOOL) tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath { 
	return NO;
}
-(id)_editButtonBarItem { 
	return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	if (proposedDestinationIndexPath.section > 1) {
	    NSInteger row = 0;
	    if (sourceIndexPath.section < proposedDestinationIndexPath.section) {
	      row = [tableView numberOfRowsInSection:sourceIndexPath.section] - 1;
	    }
	    return [NSIndexPath indexPathForRow:row inSection:sourceIndexPath.section];     
	  }

  return proposedDestinationIndexPath;
}
// - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath 
// {
//     NSString *stringToMove = self.tableData[sourceIndexPath.row];
//     [self.tableData removeObjectAtIndex:sourceIndexPath.row];
//     [self.tableData insertObject:stringToMove atIndex:destinationIndexPath.row];
// }


-(void)tableView: (UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndex toIndexPath:(NSIndexPath *)toIndex {
	NSLog(@"attempted to move");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	NSLog(@"accessoryType = %d",(int)cell.accessoryType);
	cell.editingAccessoryView = cell.accessoryView;
	if(indexPath.section < 2 || indexPath.section > 3)
		cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	tableView.allowsSelectionDuringEditing = YES; 
	tableView.editing = YES;

	[super setEditingButtonHidden:NO animated:NO];
	[super setEditButtonEnabled:NO];

	return cell;
}
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 5;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section == 0) return 3;
	if(section == 1) return 0; //count
	if(section == 2) return 1; //count
	if(section == 3) return 2; 
	if(section == 4) return 1;
	return 0; 
}
- (id) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *header = [super tableView:tableView titleForHeaderInSection:section];
	return header;
}

-(void)github {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/twodayslate"]];
}
-(void)paypal {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=2R9WDZCE7CPZ8"]];
}

-(void)bitcoin {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://coinbase.com/checkouts/59ead722b181591150e7de4ed6769cb4"]];
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

// vim:ft=objc
